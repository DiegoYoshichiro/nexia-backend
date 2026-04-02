@echo off
title NexIA Setup
color 0A

echo.
echo  ==========================================
echo   NexIA - Setup Automatico
echo  ==========================================
echo.

set NODE=E:\Node_Js\node.exe
set NPM=E:\Node_Js\npm.cmd

:: Passo 1 - Node.js
echo [1/5] Verificando Node.js...
"%NODE%" --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  ERRO: node.exe nao encontrado em E:\Node_Js
    pause
    exit /b 1
)
echo  OK - Node.js encontrado
echo.

:: Passo 2 - npm
echo [2/5] Verificando npm...
if not exist "E:\Node_Js\npm.cmd" (
    echo  ERRO: npm.cmd nao encontrado em E:\Node_Js
    pause
    exit /b 1
)
echo  OK - npm encontrado
echo.

:: Passo 3 - Arquivos do projeto
echo [3/5] Verificando arquivos do projeto...
if not exist "server.js" (
    echo  ERRO: server.js nao encontrado
    echo  Pasta atual: %CD%
    echo  Coloque todos os arquivos na mesma pasta.
    pause
    exit /b 1
)
if not exist "package.json" (
    echo  ERRO: package.json nao encontrado
    echo  Pasta atual: %CD%
    pause
    exit /b 1
)
echo  OK - server.js encontrado
echo  OK - package.json encontrado
echo.

:: Passo 4 - Credenciais
echo [4/5] Configurando credenciais...
echo.
echo  Tenha em maos:
echo   - Chave da Anthropic  (console.anthropic.com)
echo   - URL do Supabase     (supabase.com)
echo   - Chave do Supabase   (supabase.com)
echo.
echo  Pressione qualquer tecla para continuar...
pause >nul
echo.

set /p ANTHROPIC_KEY="  ANTHROPIC_API_KEY: "
echo.
set /p SUPABASE_URL="  SUPABASE_URL: "
echo.
set /p SUPABASE_KEY="  SUPABASE_KEY: "
echo.

(
echo ANTHROPIC_API_KEY=%ANTHROPIC_KEY%
echo SUPABASE_URL=%SUPABASE_URL%
echo SUPABASE_KEY=%SUPABASE_KEY%
echo PORT=3000
) > .env

echo  OK - Arquivo .env criado
echo.

:: Passo 5 - Instalar dependencias
echo [5/5] Instalando dependencias...
echo  Aguarde, pode demorar 1-2 minutos...
echo.

"E:\Node_Js\npm.cmd" install

if %errorlevel% neq 0 (
    echo.
    echo  ERRO: Falha ao instalar dependencias.
    echo  Verifique sua conexao com a internet.
    pause
    exit /b 1
)

echo.
echo  ==========================================
echo   PRONTO! Setup concluido!
echo  ==========================================
echo.
echo  Para testar agora, execute:
echo.
echo    E:\Node_Js\node.exe server.js
echo.
echo  Deve aparecer:
echo    NexIA rodando na porta 3000
echo  ==========================================
echo.
pause
