import express from "express";
import fetch from "node-fetch";
import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";

dotenv.config();

const app = express();
app.use(express.json());

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
);

// Rota de saúde — confirma que o servidor está no ar
app.get("/", (req, res) => {
  res.json({ status: "NexIA online", version: "1.0.0" });
});

// Webhook — recebe mensagens do WhatsApp via Z-API
app.post("/webhook/:clientId", async (req, res) => {
  res.sendStatus(200);

  try {
    const { clientId } = req.params;
    const body = req.body;

    if (body.fromMe) return;
    if (body.type !== "ReceivedCallback") return;
    if (!body.text?.message) return;

    const phone = body.phone;
    const message = body.text.message;

    console.log(`[${clientId}] Mensagem de ${phone}: "${message}"`);

    const config = await getClientConfig(clientId);
    if (!config) return console.error(`Cliente ${clientId} não encontrado`);

    const history = await getHistory(clientId, phone);
    const reply = await callClaude(config.system_prompt, history, message);

    await saveMessages(clientId, phone, message, reply);
    await sendWhatsApp(config.zapi_instance, config.zapi_token, phone, reply);

    console.log(`[${clientId}] Resposta enviada para ${phone}`);

  } catch (err) {
    console.error("Erro no webhook:", err.message);
  }
});

// ── Claude API ───────────────────────────────────────────────
async function callClaude(systemPrompt, history, newMessage) {
  const messages = [
    ...history.map(h => [
      { role: "user", content: h.user_message },
      { role: "assistant", content: h.bot_reply }
    ]).flat(),
    { role: "user", content: newMessage }
  ];

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": process.env.ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01"
    },
    body: JSON.stringify({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 500,
      system: systemPrompt,
      messages
    })
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(`Claude API: ${JSON.stringify(data)}`);
  }

  return data.content[0].text;
}

// ── Supabase ─────────────────────────────────────────────────
async function getHistory(clientId, phone) {
  const { data, error } = await supabase
    .from("messages")
    .select("user_message, bot_reply")
    .eq("client_id", clientId)
    .eq("phone", phone)
    .order("created_at", { ascending: true })
    .limit(10);

  if (error) throw error;
  return data ?? [];
}

async function saveMessages(clientId, phone, userMessage, botReply) {
  const { error } = await supabase.from("messages").insert({
    client_id: clientId,
    phone,
    user_message: userMessage,
    bot_reply: botReply
  });

  if (error) throw error;
}

async function getClientConfig(clientId) {
  const { data } = await supabase
    .from("clients")
    .select("system_prompt, zapi_instance, zapi_token")
    .eq("id", clientId)
    .single();

  return data;
}

// ── Z-API ────────────────────────────────────────────────────
async function sendWhatsApp(instance, token, phone, message) {
  const url = `https://api.z-api.io/instances/${instance}/token/${token}/send-text`;

  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone, message })
  });

  if (!response.ok) {
    const err = await response.json();
    throw new Error(`Z-API: ${JSON.stringify(err)}`);
  }
}

// ── Start ────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`NexIA rodando na porta ${PORT}`);
  console.log(`Webhook: POST /webhook/:clientId`);
});
