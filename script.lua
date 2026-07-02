-- [[ YATTA HUB - AUTO CODES (PREMIUM GRADIENT EDITION) ]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Destruir versão antiga se re-executar
if playerGui:FindFirstChild("YattaHubAutoCodes") then
    playerGui.YattaHubAutoCodes:Destroy()
end

-- Instâncias Principais da Interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YattaHubAutoCodes"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Mapeamento dos caminhos exatos do jogo
local topNotificationPasta = playerGui:WaitForChild("TopNotification"):WaitForChild("TopNotification") 
local codesGui = playerGui:WaitForChild("Codes")
local codesFrame = codesGui:WaitForChild("Codes")
local codeRedeem = codesFrame:WaitForChild("CodeRedeem")

local textBoxDestino = codeRedeem:WaitForChild("TextBox")
local botaoConfirmar = codesFrame:WaitForChild("Confirm")

-- Estados do Script
local autoRedeemAtivado = false
local scriptAtivo = false
local tipoSelecionado = "Nenhum"
local historicoNotificacoes = {}

-- Paleta de Cores de Elementos Internos
local CORES = {
    TextoPrincipal = Color3.fromRGB(255, 255, 255),
    TextoContraste = Color3.fromRGB(60, 40, 5),    -- Para textos direto no fundo amarelo
    TextoSecundario = Color3.fromRGB(240, 230, 210),
    Desativado = Color3.fromRGB(255, 0, 0),        -- Vermelho Puro
    DesativadoHover = Color3.fromRGB(220, 30, 30),
    Ativado = Color3.fromRGB(0, 230, 0),           -- Verde Vibrante
    AtivadoHover = Color3.fromRGB(30, 200, 30),
    Botoes = Color3.fromRGB(45, 35, 15),
    BotoesHover = Color3.fromRGB(70, 55, 25)
}

-- Configurações Globais de Transição
local TWEEN_SUAVE = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_REBOTE = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ==========================================
-- FUNÇÃO DE REDEEM ULTRA-ROBUSTA (INALTERADA)
-- ==========================================
local function darFireNoBotao()
    if not botaoConfirmar then return end
    if firesignal then
        pcall(function() firesignal(botaoConfirmar.MouseButton1Click) end)
        pcall(function() firesignal(botaoConfirmar.MouseButton1Down) end)
        pcall(function() firesignal(botaoConfirmar.MouseButton1Up) end)
        pcall(function() firesignal(botaoConfirmar.Activated) end)
    end
    pcall(function() botaoConfirmar:Activate() end)
    if virtualinputmanager or game:GetService("VirtualInputManager") then
        pcall(function()
            local x = botaoConfirmar.AbsolutePosition.X + (botaoConfirmar.AbsoluteSize.X / 2)
            local y = botaoConfirmar.AbsolutePosition.Y + (botaoConfirmar.AbsoluteSize.Y / 2)
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.05)
            vim:SendMouseButtonEvent(x, y, 0, false, game, 1)
        end)
    end
end

-- Helper dinâmico atualizado para gerenciar cores ativas/desativas no hover automaticamente
local function gerenciarHoverEstado(botao, checarEstado)
    local tamanhoOriginal = botao.Size
    
    botao.MouseEnter:Connect(function()
        local ativo = checarEstado()
        local corHover = ativo and CORES.AtivadoHover or CORES.DesativadoHover
        if tipoSelecionado == "Capture all announc." and botao.Name == "AutoRedeem" then
            corHover = Color3.fromRGB(110, 100, 90) -- Trancado
        end
        TweenService:Create(botao, TWEEN_SUAVE, {BackgroundColor3 = corHover}):Play()
        TweenService:Create(botao, TWEEN_SUAVE, {Size = UDim2.new(tamanhoOriginal.X.Scale, tamanhoOriginal.X.Offset + 4, tamanhoOriginal.Y.Scale, tamanhoOriginal.Y.Offset + 4)}):Play()
    end)
    
    botao.MouseLeave:Connect(function()
        local ativo = checarEstado()
        local corNormal = ativo and CORES.Ativado or CORES.Desativado
        if tipoSelecionado == "Capture all announc." and botao.Name == "AutoRedeem" then
            corNormal = Color3.fromRGB(110, 100, 90) -- Trancado
        end
        TweenService:Create(botao, TWEEN_SUAVE, {BackgroundColor3 = corNormal}):Play()
        TweenService:Create(botao, TWEEN_SUAVE, {Size = tamanhoOriginal}):Play()
    end)
end

local function adicionarEfeitosBotao(botao, corFundoNormal, corFundoHover, escalaHover)
    local tamanhoOriginal = botao.Size
    botao.MouseEnter:Connect(function()
        TweenService:Create(botao, TWEEN_SUAVE, {BackgroundColor3 = corFundoHover}):Play()
        if escalaHover then
            TweenService:Create(botao, TWEEN_SUAVE, {Size = UDim2.new(tamanhoOriginal.X.Scale, tamanhoOriginal.X.Offset + 4, tamanhoOriginal.Y.Scale, tamanhoOriginal.Y.Offset + 4)}):Play()
        end
    end)
    botao.MouseLeave:Connect(function()
        TweenService:Create(botao, TWEEN_SUAVE, {BackgroundColor3 = corFundoNormal}):Play()
        if escalaHover then
            TweenService:Create(botao, TWEEN_SUAVE, {Size = tamanhoOriginal}):Play()
        end
    end)
end

-- ==========================================
-- DESIGN DA INTERFACE PRINCIPAL (GRADIENTE)
-- ==========================================

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 250)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

-- Gradiente de Amarelo para Amarelo Escuro
local fundoGradiente = Instance.new("UIGradient")
fundoGradiente.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 210, 96)),       -- Amarelo Yatta
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(185, 145, 40)),     -- Amarelo Médio
    ColorSequenceKeypoint.new(1, Color3.fromRGB(115, 85, 15))         -- Amarelo Meio Escuro
})
fundoGradiente.Rotation = 45
fundoGradiente.Parent = mainFrame

-- Borda elegante que contrasta com o fundo
local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 1.5
uiStroke.Color = Color3.fromRGB(90, 65, 10)
uiStroke.Transparency = 0.2
uiStroke.Parent = mainFrame

-- LOOP ANIMAÇÃO DO GRADIENTE (Efeito suave infinito)
task.spawn(function()
    local tweenInfoGradiente = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
    local tweenGradiente = TweenService:Create(fundoGradiente, tweenInfoGradiente, {Offset = Vector2.new(0.3, 0.3)})
    tweenGradiente:Play()
end)

-- Título (com marcador da v1.2 incluso)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 300, 0, 40)
titleLabel.Position = UDim2.new(0, 20, 0, 15)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Yatta Hub <font color='#FFFFFF'>AutoCodes</font> <font color='#443005' size='11'><b>v1.2</b></font>"
titleLabel.RichText = true
titleLabel.TextColor3 = CORES.TextoContraste
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Botão Minimizar
local btnMinimize = Instance.new("TextButton")
btnMinimize.Size = UDim2.new(0, 30, 0, 30)
btnMinimize.Position = UDim2.new(1, -75, 0, 20)
btnMinimize.BackgroundColor3 = CORES.Botoes
btnMinimize.Text = "—"
btnMinimize.TextColor3 = CORES.TextoPrincipal
btnMinimize.Font = Enum.Font.GothamBold
btnMinimize.TextSize = 12
btnMinimize.Parent = mainFrame
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = btnMinimize
adicionarEfeitosBotao(btnMinimize, CORES.Botoes, CORES.BotoesHover, false)

-- Botão Fechar
local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 30, 0, 30)
btnClose.Position = UDim2.new(1, -40, 0, 20)
btnClose.BackgroundColor3 = CORES.Botoes
btnClose.Text = "✕"
btnClose.TextColor3 = Color3.fromRGB(240, 90, 90)
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 14
btnClose.Parent = mainFrame
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = btnClose
adicionarEfeitosBotao(btnClose, CORES.Botoes, Color3.fromRGB(80, 30, 30), false)

-- Label "Select a type:"
local selectLabel = Instance.new("TextLabel")
selectLabel.Size = UDim2.new(0, 200, 0, 30)
selectLabel.Position = UDim2.new(0, 25, 0, 65)
selectLabel.BackgroundTransparency = 1
selectLabel.Text = "Select Method:"
selectLabel.TextColor3 = CORES.TextoContraste
selectLabel.Font = Enum.Font.GothamBold
selectLabel.TextSize = 14
selectLabel.TextXAlignment = Enum.TextXAlignment.Left
selectLabel.Parent = mainFrame

-- Card de Notas estilizado
local notesFrame = Instance.new("Frame")
notesFrame.Size = UDim2.new(0, 210, 0, 65)
notesFrame.Position = UDim2.new(0, 25, 0, 160)
notesFrame.BackgroundColor3 = Color3.fromRGB(45, 35, 15)
notesFrame.BackgroundTransparency = 0.3
notesFrame.BorderSizePixel = 0
notesFrame.Parent = mainFrame
local notesCorner = Instance.new("UICorner")
notesCorner.CornerRadius = UDim.new(0, 8)
notesCorner.Parent = notesFrame

local notesLabel = Instance.new("TextLabel")
notesLabel.Size = UDim2.new(1, -20, 1, -10)
notesLabel.Position = UDim2.new(0, 10, 0, 5)
notesLabel.BackgroundTransparency = 1
notesLabel.Text = "<font color='#FF5555'><b>INFO:</b></font> If you use 'Capture all', Auto Redeem will be forced off."
notesLabel.RichText = true
notesLabel.TextColor3 = CORES.TextoPrincipal
notesLabel.Font = Enum.Font.GothamSemibold
notesLabel.TextSize = 11
notesLabel.TextWrapped = true
notesLabel.TextXAlignment = Enum.TextXAlignment.Left
notesLabel.TextYAlignment = Enum.TextYAlignment.Top
notesLabel.Parent = notesFrame

-- Botão Auto Redeem
local btnAutoRedeem = Instance.new("TextButton")
btnAutoRedeem.Name = "AutoRedeem"
btnAutoRedeem.Size = UDim2.new(0, 130, 0, 50)
btnAutoRedeem.Position = UDim2.new(1, -155, 0, 95)
btnAutoRedeem.BackgroundColor3 = CORES.Desativado -- Começa Vermelho
btnAutoRedeem.Text = "Auto Redeem: OFF"
btnAutoRedeem.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAutoRedeem.Font = Enum.Font.GothamBold
btnAutoRedeem.TextSize = 12
btnAutoRedeem.Parent = mainFrame
local arCorner = Instance.new("UICorner")
arCorner.CornerRadius = UDim.new(0, 10)
arCorner.Parent = btnAutoRedeem

-- Botão Start
local btnStart = Instance.new("TextButton")
btnStart.Name = "Start"
btnStart.Size = UDim2.new(0, 130, 0, 50)
btnStart.Position = UDim2.new(1, -155, 0, 155)
btnStart.BackgroundColor3 = CORES.Desativado -- Começa Vermelho
btnStart.Text = "Status: STOPPED"
btnStart.TextColor3 = Color3.fromRGB(255, 255, 255)
btnStart.Font = Enum.Font.GothamBold
btnStart.TextSize = 12
btnStart.Parent = mainFrame
local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 10)
startCorner.Parent = btnStart

-- Ativar os gerenciadores automáticos de hover com base nos estados reais
gerenciarHoverEstado(btnAutoRedeem, function() return autoRedeemAtivado end)
gerenciarHoverEstado(btnStart, function() return scriptAtivo end)

-- ==========================================
-- DROPDOWN ANIMADO FLUIDO
-- ==========================================
local dropdownContainer = Instance.new("Frame")
dropdownContainer.Size = UDim2.new(0, 210, 0, 35)
dropdownContainer.Position = UDim2.new(0, 25, 0, 95)
dropdownContainer.BackgroundColor3 = CORES.Botoes
dropdownContainer.BorderSizePixel = 0
dropdownContainer.ClipsDescendants = true
dropdownContainer.ZIndex = 5
dropdownContainer.Parent = mainFrame

local ddCorner = Instance.new("UICorner")
ddCorner.CornerRadius = UDim.new(0, 8)
ddCorner.Parent = dropdownContainer

local dropdownStroke = Instance.new("UIStroke")
dropdownStroke.Thickness = 1
dropdownStroke.Color = Color3.fromRGB(90, 70, 20)
dropdownStroke.Parent = dropdownContainer

local btnDropdownToggle = Instance.new("TextButton")
btnDropdownToggle.Size = UDim2.new(1, 0, 0, 35)
btnDropdownToggle.BackgroundTransparency = 1
btnDropdownToggle.Text = "Select Option  ▼"
btnDropdownToggle.TextColor3 = CORES.TextoPrincipal
btnDropdownToggle.Font = Enum.Font.GothamBold
btnDropdownToggle.TextSize = 12
btnDropdownToggle.ZIndex = 6
btnDropdownToggle.Parent = dropdownContainer

local ddListLayout = Instance.new("UIListLayout")
ddListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ddListLayout.Parent = dropdownContainer

local spacer = Instance.new("Frame")
spacer.Size = UDim2.new(1, 0, 0, 35)
spacer.BackgroundTransparency = 1
spacer.LayoutOrder = 1
spacer.Parent = dropdownContainer

local opcoes = {"Capture all announc.", "3 Words Code", "1 announc. code"}
local dropdownAberto = false

local function criarOpcaoDropdown(nome, ordem)
    local btnOpcao = Instance.new("TextButton")
    btnOpcao.Size = UDim2.new(1, 0, 0, 30)
    btnOpcao.BackgroundColor3 = CORES.Botoes
    btnOpcao.BorderSizePixel = 0
    btnOpcao.Text = "  " .. nome
    btnOpcao.TextColor3 = CORES.TextoSecundario
    btnOpcao.Font = Enum.Font.GothamSemibold
    btnOpcao.TextSize = 11
    btnOpcao.TextXAlignment = Enum.TextXAlignment.Left
    btnOpcao.LayoutOrder = ordem
    btnOpcao.ZIndex = 6
    btnOpcao.Parent = dropdownContainer
    
    adicionarEfeitosBotao(btnOpcao, CORES.Botoes, CORES.BotoesHover, false)
    
    btnOpcao.MouseButton1Click:Connect(function()
        tipoSelecionado = nome
        btnDropdownToggle.Text = nome .. "  ▲"
        
        if tipoSelecionado == "Capture all announc." then
            autoRedeemAtivado = false
            TweenService:Create(btnAutoRedeem, TWEEN_SUAVE, {BackgroundColor3 = Color3.fromRGB(110, 100, 90)}):Play()
            btnAutoRedeem.Text = "Auto Redeem: LOCKED"
        else
            local corAlvo = autoRedeemAtivado and CORES.Ativado or CORES.Desativado
            TweenService:Create(btnAutoRedeem, TWEEN_SUAVE, {BackgroundColor3 = corAlvo}):Play()
            btnAutoRedeem.Text = autoRedeemAtivado and "Auto Redeem: ON" or "Auto Redeem: OFF"
        end
        
        dropdownAberto = false
        TweenService:Create(dropdownContainer, TWEEN_SUAVE, {Size = UDim2.new(0, 210, 0, 35)}):Play()
        TweenService:Create(dropdownStroke, TWEEN_SUAVE, {Color = Color3.fromRGB(90, 70, 20)}):Play()
    end)
end

for i, opcao in ipairs(opcoes) do
    criarOpcaoDropdown(opcao, i + 1)
end

btnDropdownToggle.MouseButton1Click:Connect(function()
    dropdownAberto = not dropdownAberto
    local alturaAlvo = dropdownAberto and 130 or 35
    local icone = dropdownAberto and "  ▲" or "  ▼"
    btnDropdownToggle.Text = tipoSelecionado == "Nenhum" and ("Select Option" .. icone) or (tipoSelecionado .. icone)
    
    TweenService:Create(dropdownContainer, TWEEN_SUAVE, {Size = UDim2.new(0, 210, 0, alturaAlvo)}):Play()
    TweenService:Create(dropdownStroke, TWEEN_SUAVE, {Color = dropdownAberto and Color3.fromRGB(255,255,255) or Color3.fromRGB(90, 70, 20)}):Play()
end)

-- ==========================================
-- INTERAÇÃO DOS BOTÕES LIGA/DESLIGA
-- ==========================================

btnAutoRedeem.MouseButton1Click:Connect(function()
    if tipoSelecionado == "Capture all announc." then return end
    autoRedeemAtivado = not autoRedeemAtivado
    local corAlvo = autoRedeemAtivado and CORES.Ativado or CORES.Desativado
    local textoAlvo = autoRedeemAtivado and "Auto Redeem: ON" or "Auto Redeem: OFF"
    
    btnAutoRedeem.Text = textoAlvo
    TweenService:Create(btnAutoRedeem, TWEEN_SUAVE, {BackgroundColor3 = corAlvo}):Play()
end)

btnStart.MouseButton1Click:Connect(function()
    scriptAtivo = not scriptAtivo
    local corAlvo = scriptAtivo and CORES.Ativado or CORES.Desativado
    btnStart.Text = scriptAtivo and "Status: ACTIVE" or "Status: STOPPED"
    
    TweenService:Create(btnStart, TWEEN_SUAVE, {BackgroundColor3 = corAlvo}):Play()
    historicoNotificacoes = {}
end)

-- ==========================================
-- CAPTURA DE CÓDIGOS (INALTERADO)
-- ==========================================

local function lidarComNovaNotificacao(objeto)
    if not scriptAtivo or tipoSelecionado == "Nenhum" then return end
    if objeto:IsA("TextLabel") then
        local txt = ""
        local sucesso = pcall(function() txt = objeto.Text end)
        if not sucesso or txt == "" then return end
        
        if txt == "Template" then 
            task.spawn(function()
                for i = 1, 5 do
                    task.wait()
                    if objeto and objeto.Parent and objeto.Text ~= "Template" and objeto.Text ~= "" then
                        txt = objeto.Text
                        break
                    end
                end
                if txt == "Template" or txt == "" then return end
                
                if tipoSelecionado == "Capture all announc." then
                    textBoxDestino.Text = txt
                elseif tipoSelecionado == "3 Words Code" then
                    table.insert(historicoNotificacoes, txt)
                    if #historicoNotificacoes >= 3 then
                        textBoxDestino.Text = historicoNotificacoes[1] .. historicoNotificacoes[2] .. historicoNotificacoes[3]
                        historicoNotificacoes = {}
                        if autoRedeemAtivado then darFireNoBotao() end
                    end
                elseif tipoSelecionado == "1 announc. code" then
                    textBoxDestino.Text = txt
                    if autoRedeemAtivado then darFireNoBotao() end
                end
            end)
            return
        end
        
        if tipoSelecionado == "Capture all announc." then
            textBoxDestino.Text = txt
        elseif tipoSelecionado == "3 Words Code" then
            table.insert(historicoNotificacoes, txt)
            if #historicoNotificacoes >= 3 then
                textBoxDestino.Text = historicoNotificacoes[1] .. historicoNotificacoes[2] .. historicoNotificacoes[3]
                historicoNotificacoes = {}
                if autoRedeemAtivado then darFireNoBotao() end
            end
        elseif tipoSelecionado == "1 announc. code" then
            textBoxDestino.Text = txt
            if autoRedeemAtivado then darFireNoBotao() end
        end
    end
end

topNotificationPasta.ChildAdded:Connect(lidarComNovaNotificacao)

-- ==========================================
-- SISTEMA MINIMIZAR / ARRASTAR COM ARRASTE SUAVE
-- ==========================================
local miniIcon = Instance.new("TextButton")
miniIcon.Name = "MiniIcon"
miniIcon.Size = UDim2.new(0, 60, 0, 60)
miniIcon.Position = UDim2.new(0, 20, 0.5, -30)
miniIcon.BackgroundColor3 = Color3.fromRGB(244, 210, 96)
miniIcon.Text = "Yatta"
miniIcon.Font = Enum.Font.GothamBold
miniIcon.TextColor3 = CORES.TextoContraste
miniIcon.TextSize = 14
miniIcon.Visible = false
miniIcon.Parent = screenGui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(1, 0)
iconCorner.Parent = miniIcon

local iconStroke = Instance.new("UIStroke")
iconStroke.Thickness = 1.5
iconStroke.Color = Color3.fromRGB(90, 65, 10)
iconStroke.Parent = miniIcon

adicionarEfeitosBotao(miniIcon, Color3.fromRGB(244, 210, 96), Color3.fromRGB(215, 180, 70), true)

local function fazerArrastavel(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
 
