-- ================= INFO HUB | by akiev =================
-- ======== SISTEMA DE SONS ========
local SoundService = game:GetService("SoundService")

local SONS = {
    intro     = "rbxassetid://9046850851",
    logo      = "rbxassetid://6895079853",
    notif     = "rbxassetid://4590657391",
    finalizar = "rbxassetid://9114186747",
    click     = "rbxassetid://876939830",
}

local function tocarSom(id, volume)
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = volume or 1
        s.Parent = SoundService
        s:Play()
        s.Ended:Connect(function() s:Destroy() end)
        task.delay(6, function()
            if s and s.Parent then s:Destroy() end
        end)
    end)
end

-- ======== SERVIÇOS ========
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function getParent()
    if gethui then
        local ok, ui = pcall(gethui)
        if ok and ui then return ui end
    end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then
        local ok2 = pcall(function()
            local t = Instance.new("Folder", core)
            t:Destroy()
        end)
        if ok2 then return core end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- aviso de erro na tela (não depende de nenhuma lib)
local function avisoErro(msg)
    local gui = Instance.new("ScreenGui")
    gui.Name = "InfoHubErro"
    gui.Parent = getParent()
    local caixa = Instance.new("TextLabel")
    caixa.Size = UDim2.new(0, 320, 0, 90)
    caixa.Position = UDim2.new(0.5, -160, 0.4, 0)
    caixa.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    caixa.TextColor3 = Color3.fromRGB(255, 120, 120)
    caixa.Font = Enum.Font.GothamBold
    caixa.TextSize = 13
    caixa.TextWrapped = true
    caixa.Text = "INFO HUB - ERRO:\n" .. msg
    caixa.Parent = gui
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = caixa
    tocarSom(SONS.notif, 0.5)
    task.delay(8, function() gui:Destroy() end)
end

-- ======== INTRO ANIMADA ========
local introGui = Instance.new("ScreenGui")
introGui.Name = "InfoHubIntro"
introGui.IgnoreGuiInset = true
introGui.ResetOnSpawn = false
introGui.Parent = getParent()

local fundo = Instance.new("Frame")
fundo.Size = UDim2.new(1, 0, 1, 0)
fundo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fundo.BorderSizePixel = 0
fundo.Parent = introGui

local nome = Instance.new("TextLabel")
nome.Size = UDim2.new(1, 0, 0, 60)
nome.Position = UDim2.new(0, 0, 0.42, 0)
nome.BackgroundTransparency = 1
nome.Text = "INFO HUB"
nome.TextColor3 = Color3.fromRGB(255, 255, 255)
nome.Font = Enum.Font.FredokaOne
nome.TextSize = 42
nome.TextTransparency = 1
nome.Parent = fundo

local autor = Instance.new("TextLabel")
autor.Size = UDim2.new(1, 0, 0, 25)
autor.Position = UDim2.new(0, 0, 0.42, 55)
autor.BackgroundTransparency = 1
autor.Text = "by akiev"
autor.TextColor3 = Color3.fromRGB(160, 160, 160)
autor.Font = Enum.Font.Gotham
autor.TextSize = 16
autor.TextTransparency = 1
autor.Parent = fundo

local spinner = Instance.new("Frame")
spinner.Size = UDim2.new(0, 40, 0, 40)
spinner.Position = UDim2.new(0.5, -20, 0.42, 110)
spinner.BackgroundTransparency = 1
spinner.Parent = fundo

local bolinhas = {}
for i = 1, 8 do
    local angulo = math.rad((i - 1) * 45)
    local b = Instance.new("Frame")
    b.Size = UDim2.new(0, 6, 0, 6)
    b.Position = UDim2.new(0.5, math.cos(angulo) * 16 - 3, 0.5, math.sin(angulo) * 16 - 3)
    b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    b.BackgroundTransparency = 1
    b.BorderSizePixel = 0
    b.Parent = spinner
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = b
    bolinhas[i] = b
end

local introAtiva = true
task.spawn(function()
    local passo = 0
    while introAtiva do
        passo = passo + 1
        for i = 1, 8 do
            local dist = (i - passo) % 8
            bolinhas[i].BackgroundTransparency = math.min(0.1 + dist * 0.12, 0.9)
        end
        task.wait(0.08)
    end
end)

tocarSom(SONS.intro, 0.6)
TweenService:Create(nome, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
tocarSom(SONS.logo, 0.5)
task.wait(0.4)
TweenService:Create(autor, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()

-- ======== CARREGA RAYFIELD DURANTE A INTRO ========
local Rayfield
do
    local codigo
    local okHttp, erroHttp = pcall(function()
        codigo = game:HttpGet("https://sirius.menu/rayfield")
    end)
    if not okHttp or not codigo or #codigo < 100 then
        introAtiva = false
        introGui:Destroy()
        avisoErro("HttpGet falhou: " .. tostring(erroHttp))
        return
    end
    local okLoad, resultado = pcall(function()
        return loadstring(codigo)()
    end)
    if not okLoad or type(resultado) ~= "table" or not resultado.CreateWindow then
        introAtiva = false
        introGui:Destroy()
        avisoErro("Rayfield carregou mas retornou invalido: " .. tostring(resultado))
        return
    end
    Rayfield = resultado
end

task.wait(2)

-- fade out da intro
introAtiva = false
TweenService:Create(nome, TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
TweenService:Create(autor, TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
for _, b in ipairs(bolinhas) do
    TweenService:Create(b, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
end
TweenService:Create(fundo, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
tocarSom(SONS.finalizar, 0.6)
task.wait(0.8)
introGui:Destroy()

-- ======== HELPERS ========
local function getExecutor()
    local nomeExec = "Desconhecido"
    if identifyexecutor then
        local ok, result = pcall(identifyexecutor)
        if ok and result then nomeExec = result end
    elseif getexecutorname then
        local ok, result = pcall(getexecutorname)
        if ok and result then nomeExec = result end
    end
    return tostring(nomeExec)
end

local function getPing()
    local ok, ping = pcall(function()
        return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    if ok then return ping .. " ms" end
    return "N/A"
end

local function notificar(titulo, conteudo, duracao, icone)
    tocarSom(SONS.notif, 0.5)
    pcall(function()
        Rayfield:Notify({
            Title = titulo,
            Content = conteudo,
            Duration = duracao or 3,
            Image = icone or "info",
        })
    end)
end

-- ======== JANELA (com verificação) ========
local Window
do
    local ok, resultado = pcall(function()
        return Rayfield:CreateWindow({
            Name = "Info Hub | by akiev",
            LoadingTitle = "Info Hub",
            LoadingSubtitle = "by akiev",
            ConfigurationSaving = { Enabled = false },
        })
    end)
    if not ok or not resultado then
        avisoErro("CreateWindow falhou: " .. tostring(resultado))
        return
    end
    Window = resultado
end

-- ======== ABA: JOGADOR ========
local TabJogador = Window:CreateTab("Jogador", "user")
TabJogador:CreateParagraph({ Title = "Nome", Content = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")" })
TabJogador:CreateParagraph({ Title = "UserId", Content = tostring(LocalPlayer.UserId) })
TabJogador:CreateParagraph({ Title = "Executor", Content = getExecutor() })

-- ======== ABA: SERVIDOR ========
local TabServidor = Window:CreateTab("Servidor", "server")
TabServidor:CreateParagraph({ Title = "JobId", Content = tostring(game.JobId) })
TabServidor:CreateParagraph({ Title = "PlaceId", Content = tostring(game.PlaceId) })
local ParagJogadores = TabServidor:CreateParagraph({ Title = "Jogadores", Content = "..." })
local ParagPing = TabServidor:CreateParagraph({ Title = "Ping", Content = "..." })

TabServidor:CreateButton({
    Name = "Copiar JobId",
    Callback = function()
        if setclipboard then
            local ok = pcall(setclipboard, tostring(game.JobId))
            notificar(ok and "Copiado!" or "Erro",
                ok and "JobId copiado." or "Executor não suporta setclipboard.",
                3, ok and "clipboard-check" or "x")
        else
            notificar("Não suportado", "Seu executor não suporta setclipboard.", 3, "x")
        end
    end
})

-- ======== ABA: TEMPO ========
local TabTempo = Window:CreateTab("Tempo", "clock")
local ParagHorario = TabTempo:CreateParagraph({ Title = "Horário", Content = "..." })
local ParagSessao = TabTempo:CreateParagraph({ Title = "Tempo no servidor", Content = "..." })

-- ======== ABA: VISUAL (GHOST 3D - VÓRTICE DE VENTO) ========
local TabVisual = Window:CreateTab("Visual", "ghost")

local ghostAtivo = false
local ghostCor = Color3.fromRGB(120, 200, 255)
local ghostRainbow = false
local ghostIntensidade = 4      -- quantidade de correntes de vento
local ghostVelocidade = 1       -- multiplicador de velocidade do vórtice
local ghostTransp = 0.85
local highlight, conexaoAnim, conexaoRespawn
local transparenciasOriginais = {}

-- estruturas do vórtice
local correntes = {}   -- { a0, a1, trail, angulo, altura, velAng, velSub, faseRaio }
local extras = {}      -- névoa, brilho, etc (instâncias soltas pra destruir)

local TEXTURA_NEVOA = "rbxassetid://241594419"

local function limparVortice()
    for _, c in ipairs(correntes) do
        pcall(function() c.trail:Destroy() end)
        pcall(function() c.a0:Destroy() end)
        pcall(function() c.a1:Destroy() end)
    end
    correntes = {}
    for _, e in ipairs(extras) do
        pcall(function() e:Destroy() end)
    end
    extras = {}
end

local function restaurarCorpo()
    for parte, original in pairs(transparenciasOriginais) do
        pcall(function() parte.Transparency = original end)
    end
    transparenciasOriginais = {}
end

-- cria uma corrente de vento (par de attachments + trail em hélice)
local function criarCorrente(root, indice, total)
    local a0 = Instance.new("Attachment")
    a0.Name = "VentoA0_" .. indice
    a0.Parent = root
    local a1 = Instance.new("Attachment")
    a1.Name = "VentoA1_" .. indice
    a1.Parent = root

    local trail = Instance.new("Trail")
    trail.Name = "VentoTrail_" .. indice
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.FaceCamera = true
    trail.LightEmission = 0.9
    trail.LightInfluence = 0
    trail.Lifetime = 0.45
    trail.MinLength = 0.05
    trail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.7, 0.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(0.6, 0.6),
        NumberSequenceKeypoint.new(1, 1),
    })
    trail.Color = ColorSequence.new(ghostCor)
    trail.Parent = root

    return {
        a0 = a0,
        a1 = a1,
        trail = trail,
        -- distribui as correntes igualmente ao redor do player
        angulo = (indice / total) * math.pi * 2,
        -- cada corrente começa numa altura diferente da hélice
        altura = (indice / total) * 5.5,
        -- velocidades levemente diferentes = movimento orgânico
        velAng = 4.5 + (indice % 3) * 0.8,
        velSub = 2.2 + (indice % 2) * 0.6,
        faseRaio = indice * 1.7,
    }
end

local function criarVortice(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- correntes de vento em hélice (trails)
    for i = 1, ghostIntensidade do
        table.insert(correntes, criarCorrente(root, i, ghostIntensidade))
    end

    -- névoa girando na base (dá volume ao tornado)
    local nevoaBase = Instance.new("Attachment")
    nevoaBase.Name = "GhostNevoaBase"
    nevoaBase.Position = Vector3.new(0, -2.6, 0)
    nevoaBase.Parent = root

    local nevoa = Instance.new("ParticleEmitter")
    nevoa.Name = "GhostNevoa"
    nevoa.Texture = TEXTURA_NEVOA
    nevoa.Color = ColorSequence.new(ghostCor)
    nevoa.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.2),
        NumberSequenceKeypoint.new(0.5, 2.4),
        NumberSequenceKeypoint.new(1, 3.2),
    })
    nevoa.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.15, 0.75),
        NumberSequenceKeypoint.new(1, 1),
    })
    nevoa.Lifetime = NumberRange.new(1.0, 1.8)
    nevoa.Rate = 12
    nevoa.Speed = NumberRange.new(1, 2)
    nevoa.SpreadAngle = Vector2.new(360, 360)
    nevoa.Rotation = NumberRange.new(0, 360)
    nevoa.RotSpeed = NumberRange.new(-90, 90) -- névoa girando = sensação de vórtice
    nevoa.Acceleration = Vector3.new(0, 2.5, 0)
    nevoa.LightEmission = 0.6
    nevoa.EmissionDirection = Enum.NormalId.Top
    nevoa.Parent = nevoaBase

    -- faíscas de ar subindo pelo corpo (bem sutis, complementam os trails)
    local faiscas = Instance.new("ParticleEmitter")
    faiscas.Name = "GhostFaiscas"
    faiscas.Color = ColorSequence.new(ghostCor)
    faiscas.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.3, 0.12),
        NumberSequenceKeypoint.new(1, 0),
    })
    faiscas.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 1),
    })
    faiscas.Lifetime = NumberRange.new(0.6, 1.2)
    faiscas.Rate = ghostIntensidade * 3
    faiscas.Speed = NumberRange.new(3, 5)
    faiscas.SpreadAngle = Vector2.new(25, 25)
    faiscas.Acceleration = Vector3.new(0, 4, 0)
    faiscas.LightEmission = 1
    faiscas.EmissionDirection = Enum.NormalId.Top
    faiscas.Parent = nevoaBase

    table.insert(extras, nevoaBase)
end

local function aplicarGhost()
    local char = LocalPlayer.Character
    if not char then return end

    transparenciasOriginais = {}
    for _, parte in ipairs(char:GetDescendants()) do
        if (parte:IsA("BasePart") or parte:IsA("Decal")) and parte.Name ~= "HumanoidRootPart" then
            transparenciasOriginais[parte] = parte.Transparency
            parte.Transparency = ghostTransp
        end
    end

    if highlight then highlight:Destroy() end
    highlight = Instance.new("Highlight")
    highlight.Name = "GhostFX"
    highlight.Adornee = char
    highlight.FillColor = ghostCor
    highlight.OutlineColor = ghostCor
    highlight.FillTransparency = 0.9
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char

    limparVortice()
    criarVortice(char)
end

local function pararGhost()
    if conexaoAnim then conexaoAnim:Disconnect() conexaoAnim = nil end
    if conexaoRespawn then conexaoRespawn:Disconnect() conexaoRespawn = nil end
    if highlight then highlight:Destroy() highlight = nil end
    limparVortice()
    restaurarCorpo()
end

local ALTURA_VORTICE = 5.5   -- altura total da hélice (dos pés à cabeça)
local BASE_Y = -2.8          -- começa nos pés

local function iniciarGhost()
    aplicarGhost()
    conexaoRespawn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ghostAtivo then aplicarGhost() end
    end)
    local tempo = 0
    conexaoAnim = RunService.Heartbeat:Connect(function(dt)
        tempo = tempo + dt

        -- cor atual (rainbow ou fixa)
        local corAtual = ghostCor
        if ghostRainbow then
            corAtual = Color3.fromHSV((tempo * 0.1) % 1, 0.7, 1)
        end

        if highlight and highlight.Parent then
            highlight.OutlineTransparency = 0.2 + math.sin(tempo * 1.5) * 0.2
            highlight.FillColor = corAtual
            highlight.OutlineColor = corAtual
        end

        -- ===== animação do vórtice 3D =====
        for _, c in ipairs(correntes) do
            if c.a0.Parent then
                -- gira e sobe
                c.angulo = c.angulo + c.velAng * ghostVelocidade * dt
                c.altura = (c.altura + c.velSub * ghostVelocidade * dt) % ALTURA_VORTICE

                local progresso = c.altura / ALTURA_VORTICE -- 0 nos pés, 1 na cabeça
                -- formato de tornado: mais fechado embaixo, abre em cima
                -- + respiração senoidal pro raio não ficar mecânico
                local raio = 1.4 + progresso * 1.3
                    + math.sin(tempo * 2.5 + c.faseRaio) * 0.25

                local x = math.cos(c.angulo) * raio
                local z = math.sin(c.angulo) * raio
                local y = BASE_Y + c.altura

                c.a0.Position = Vector3.new(x, y, z)
                -- a1 fica um pouco à frente na hélice = fita inclinada (efeito de faixa de vento)
                local ang2 = c.angulo + 0.35
                c.a1.Position = Vector3.new(
                    math.cos(ang2) * raio,
                    y + 0.45,
                    math.sin(ang2) * raio
                )

                -- some suavemente perto do topo (evita "teleporte" visível ao reiniciar a hélice)
                local fade = 1
                if progresso > 0.85 then
                    fade = 1 - (progresso - 0.85) / 0.15
                elseif progresso < 0.08 then
                    fade = progresso / 0.08
                end
                c.trail.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1 - 0.65 * fade),
                    NumberSequenceKeypoint.new(0.6, 1 - 0.4 * fade),
                    NumberSequenceKeypoint.new(1, 1),
                })
                c.trail.Color = ColorSequence.new(corAtual)
            end
        end

        -- atualiza cor da névoa/faíscas
        for _, e in ipairs(extras) do
            if e.Parent then
                for _, filho in ipairs(e:GetChildren()) do
                    if filho:IsA("ParticleEmitter") then
                        filho.Color = ColorSequence.new(corAtual)
                    end
                end
            end
        end
    end)
end

TabVisual:CreateToggle({
    Name = "Ghost (vórtice de vento)",
    CurrentValue = false,
    Flag = "ghost_toggle",
    Callback = function(valor)
        ghostAtivo = valor
        if valor then
            iniciarGhost()
            notificar("Ghost", "O vento envolveu você.", 3, "ghost")
        else
            pararGhost()
        end
    end
})

TabVisual:CreateColorPicker({
    Name = "Cor do Ghost",
    Color = ghostCor,
    Flag = "ghost_cor",
    Callback = function(cor) ghostCor = cor end
})

TabVisual:CreateToggle({
    Name = "Modo Rainbow",
    CurrentValue = false,
    Flag = "ghost_rainbow",
    Callback = function(valor) ghostRainbow = valor end
})

TabVisual:CreateSlider({
    Name = "Correntes de vento",
    Range = { 2, 10 },
    Increment = 1,
    Suffix = "x",
    CurrentValue = 4,
    Flag = "ghost_correntes",
    Callback = function(valor)
        ghostIntensidade = valor
        -- recria o vórtice com a nova quantidade de correntes
        if ghostAtivo and LocalPlayer.Character then
            limparVortice()
            criarVortice(LocalPlayer.Character)
        end
    end
})

TabVisual:CreateSlider({
    Name = "Velocidade do vento",
    Range = { 50, 300 },
    Increment = 10,
    Suffix = "%",
    CurrentValue = 100,
    Flag = "ghost_velocidade",
    Callback = function(valor)
        ghostVelocidade = valor / 100
    end
})

TabVisual:CreateSlider({
    Name = "Transparência do corpo",
    Range = { 50, 100 },
    Increment = 5,
    Suffix = "%",
    CurrentValue = 85,
    Flag = "ghost_transp",
    Callback = function(valor)
        ghostTransp = valor / 100
        if ghostAtivo then
            for parte in pairs(transparenciasOriginais) do
                if parte:IsA("BasePart") and parte.Parent then
                    parte.Transparency = ghostTransp
                end
            end
        end
    end
})

-- ======== ABA: ESP (compatível com mobile: Delta, Codex, Arceus X) ========
-- Box 2D e Tracer desenhados com Frames em ScreenGui via WorldToViewportPoint.
-- NÃO usa Drawing API (não funciona/trava em executores mobile).
local TabESP = Window:CreateTab("ESP", "eye")
local Camera = workspace.CurrentCamera

local espAtivo = false
local espBox = true
local espTracer = true
local espChams = false
local espNome = true
local espVida = true
local espDist = true
local espCor = Color3.fromRGB(255, 80, 80)
local espUsarCorTime = false
local espDistMax = 1000 -- studs

local espObjetos = {}     -- [player] = { chams, billboard, box, boxStroke, tracer, labels... }
local espConexoes = {}    -- conexões pra desconectar ao desligar
local espLoop

-- ScreenGui onde as boxes 2D e tracers são desenhados
local espTela = Instance.new("ScreenGui")
espTela.Name = "InfoHubESP"
espTela.IgnoreGuiInset = true
espTela.DisplayOrder = 5
espTela.Enabled = false
espTela.Parent = getParent()

local function corDoJogador(jogador)
    if espUsarCorTime and jogador.Team and jogador.TeamColor then
        return jogador.TeamColor.Color
    end
    return espCor
end

local function removerESPDe(jogador)
    local obj = espObjetos[jogador]
    if obj then
        pcall(function() obj.chams:Destroy() end)
        pcall(function() obj.billboard:Destroy() end)
        pcall(function() obj.box:Destroy() end)
        pcall(function() obj.tracer:Destroy() end)
        espObjetos[jogador] = nil
    end
end

local function criarESPPara(jogador)
    if jogador == LocalPlayer then return end
    removerESPDe(jogador)

    local char = jogador.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local cor = corDoJogador(jogador)

    -- BOX: Highlight (funciona em qualquer executor, inclusive mobile)
    local hl = Instance.new("Highlight")
    hl.Name = "ESPBox"
    hl.Adornee = char
    hl.FillColor = cor
    hl.FillTransparency = 0.92
    hl.OutlineColor = cor
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = espBox
    hl.Parent = char

    -- TEXTOS: BillboardGui acima da cabeça
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESPInfo"
    bb.Adornee = root
    bb.Size = UDim2.new(0, 160, 0, 54)
    bb.StudsOffset = Vector3.new(0, 3.4, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = espDistMax
    bb.Parent = root

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 1)
    layout.Parent = bb

    local function criarLabel(ordem, tamanho, corTexto)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, tamanho)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold
        l.TextSize = tamanho - 2
        l.TextColor3 = corTexto
        l.TextStrokeTransparency = 0.3
        l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        l.LayoutOrder = ordem
        l.Text = ""
        l.Parent = bb
        return l
    end

    local labelNome = criarLabel(1, 15, cor)
    local labelDist = criarLabel(3, 12, Color3.fromRGB(220, 220, 220))

    -- BARRA DE VIDA (horizontal, abaixo do nome)
    local barraFundo = Instance.new("Frame")
    barraFundo.Size = UDim2.new(0, 90, 0, 5)
    barraFundo.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    barraFundo.BorderSizePixel = 0
    barraFundo.LayoutOrder = 2
    barraFundo.Parent = bb
    local cantoF = Instance.new("UICorner")
    cantoF.CornerRadius = UDim.new(1, 0)
    cantoF.Parent = barraFundo

    local barraVida = Instance.new("Frame")
    barraVida.Size = UDim2.new(1, 0, 1, 0)
    barraVida.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
    barraVida.BorderSizePixel = 0
    barraVida.Parent = barraFundo
    local cantoV = Instance.new("UICorner")
    cantoV.CornerRadius = UDim.new(1, 0)
    cantoV.Parent = barraVida

    espObjetos[jogador] = {
        highlight = hl,
        billboard = bb,
        labelNome = labelNome,
        labelDist = labelDist,
        barraVida = barraVida,
        barraFundo = barraFundo,
    }
end

local function atualizarESP()
    local meuChar = LocalPlayer.Character
    local meuRoot = meuChar and meuChar:FindFirstChild("HumanoidRootPart")

    for _, jogador in ipairs(Players:GetPlayers()) do
        if jogador ~= LocalPlayer then
            local char = jogador.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local obj = espObjetos[jogador]

            -- personagem existe mas ESP ainda não? cria
            if root and not obj then
                criarESPPara(jogador)
                obj = espObjetos[jogador]
            end

            if obj then
                -- personagem sumiu ou morreu? remove
                if not root or not hum or hum.Health <= 0 then
                    removerESPDe(jogador)
                else
                    local cor = corDoJogador(jogador)
                    obj.highlight.Enabled = espBox
                    obj.highlight.FillColor = cor
                    obj.highlight.OutlineColor = cor

                    -- nome
                    obj.labelNome.Visible = espNome
                    if espNome then
                        obj.labelNome.Text = jogador.DisplayName
                        obj.labelNome.TextColor3 = cor
                    end

                    -- vida (barra colorida verde -> vermelho)
                    obj.barraFundo.Visible = espVida
                    if espVida then
                        local frac = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                        obj.barraVida.Size = UDim2.new(frac, 0, 1, 0)
                        obj.barraVida.BackgroundColor3 = Color3.fromRGB(
                            math.floor(255 * (1 - frac)),
                            math.floor(255 * frac),
                            60
                        )
                    end

                    -- distância
                    obj.labelDist.Visible = espDist
                    if espDist and meuRoot then
                        local d = (root.Position - meuRoot.Position).Magnitude
                        obj.labelDist.Text = math.floor(d) .. " studs"
                    end
                end
            end
        end
    end
end

local function ligarESP()
    -- cria pra quem já está no jogo
    for _, jogador in ipairs(Players:GetPlayers()) do
        if jogador ~= LocalPlayer and jogador.Character then
            criarESPPara(jogador)
        end
    end

    -- novos jogadores / respawns
    table.insert(espConexoes, Players.PlayerAdded:Connect(function(jogador)
        table.insert(espConexoes, jogador.CharacterAdded:Connect(function()
            task.wait(0.5)
            if espAtivo then criarESPPara(jogador) end
        end))
    end))
    for _, jogador in ipairs(Players:GetPlayers()) do
        if jogador ~= LocalPlayer then
            table.insert(espConexoes, jogador.CharacterAdded:Connect(function()
                task.wait(0.5)
                if espAtivo then criarESPPara(jogador) end
            end))
        end
    end

    -- jogador saiu
    table.insert(espConexoes, Players.PlayerRemoving:Connect(removerESPDe))

    -- loop de atualização leve (5x por segundo = suave e não pesa no mobile)
    espLoop = task.spawn(function()
        while espAtivo do
            pcall(atualizarESP)
            task.wait(0.2)
        end
    end)
end

local function desligarESP()
    for _, con in ipairs(espConexoes) do
        pcall(function() con:Disconnect() end)
    end
    espConexoes = {}
    if espLoop then
        pcall(function() task.cancel(espLoop) end)
        espLoop = nil
    end
    for jogador in pairs(espObjetos) do
        removerESPDe(jogador)
    end
end

TabESP:CreateToggle({
    Name = "ESP Ativado",
    CurrentValue = false,
    Flag = "esp_toggle",
    Callback = function(valor)
        espAtivo = valor
        if valor then
            ligarESP()
            notificar("ESP", "ESP ativado.", 3, "eye")
        else
            desligarESP()
        end
    end
})

TabESP:CreateToggle({
    Name = "Box",
    CurrentValue = true,
    Flag = "esp_box",
    Callback = function(valor) espBox = valor end
})

TabESP:CreateToggle({
    Name = "Nome",
    CurrentValue = true,
    Flag = "esp_nome",
    Callback = function(valor) espNome = valor end
})

TabESP:CreateToggle({
    Name = "Vida",
    CurrentValue = true,
    Flag = "esp_vida",
    Callback = function(valor) espVida = valor end
})

TabESP:CreateToggle({
    Name = "Distância",
    CurrentValue = true,
    Flag = "esp_dist",
    Callback = function(valor) espDist = valor end
})

TabESP:CreateColorPicker({
    Name = "Cor do ESP",
    Color = espCor,
    Flag = "esp_cor",
    Callback = function(cor) espCor = cor end
})

TabESP:CreateToggle({
    Name = "Usar cor do time",
    CurrentValue = false,
    Flag = "esp_time",
    Callback = function(valor) espUsarCorTime = valor end
})

TabESP:CreateSlider({
    Name = "Distância máxima",
    Range = { 100, 5000 },
    Increment = 100,
    Suffix = " studs",
    CurrentValue = 1000,
    Flag = "esp_distmax",
    Callback = function(valor)
        espDistMax = valor
        for _, obj in pairs(espObjetos) do
            pcall(function() obj.billboard.MaxDistance = valor end)
        end
    end
})

-- ======== ABA: UTILIDADES (mobile: Delta, Codex, Arceus X) ========
local TabUtil = Window:CreateTab("Utilidades", "wrench")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

-- ---- REJOIN ----
TabUtil:CreateButton({
    Name = "Rejoin (mesmo servidor)",
    Callback = function()
        notificar("Rejoin", "Reconectando ao servidor...", 3, "refresh-cw")
        task.wait(0.5)
        local ok = pcall(function()
            if #Players:GetPlayers() <= 1 then
                -- servidor solo: teleporte comum recria a instância
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end)
        if not ok then
            notificar("Erro", "Falha ao reconectar. Tente novamente.", 3, "x")
        end
    end
})

-- ---- SERVER HOP (SERVIDOR MENOR) ----
local function httpGet(url)
    -- compatível com Delta, Codex, Arceus X e executores PC
    if game.HttpGet then
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok then return res end
    end
    local req = (syn and syn.request) or request or http_request or (http and http.request)
    if req then
        local ok, res = pcall(function()
            return req({ Url = url, Method = "GET" })
        end)
        if ok and res and res.Body then return res.Body end
    end
    return nil
end

TabUtil:CreateButton({
    Name = "Server Hop (menos jogadores)",
    Callback = function()
        notificar("Server Hop", "Procurando servidor menor...", 3, "search")
        task.spawn(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId
                .. "/servers/Public?sortOrder=Asc&limit=100"
            local corpo = httpGet(url)
            if not corpo then
                notificar("Erro", "Seu executor não suporta requisições HTTP.", 4, "x")
                return
            end

            local ok, dados = pcall(function() return HttpService:JSONDecode(corpo) end)
            if not ok or not dados or not dados.data then
                notificar("Erro", "Falha ao ler a lista de servidores.", 4, "x")
                return
            end

            -- procura o servidor com MENOS jogadores (com vaga e diferente do atual)
            local melhor
            for _, sv in ipairs(dados.data) do
                if sv.id ~= game.JobId and sv.playing and sv.maxPlayers
                    and sv.playing < sv.maxPlayers then
                    if not melhor or sv.playing < melhor.playing then
                        melhor = sv
                    end
                end
            end

            if melhor then
                notificar("Server Hop",
                    "Entrando em servidor com " .. melhor.playing .. " jogadores...", 3, "log-in")
                task.wait(0.5)
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, melhor.id, LocalPlayer)
                end)
            else
                notificar("Server Hop", "Nenhum servidor menor encontrado.", 4, "info")
            end
        end)
    end
})

-- ---- SERVIDOR ALEATÓRIO ----
TabUtil:CreateButton({
    Name = "Entrar em servidor aleatório",
    Callback = function()
        notificar("Servidor aleatório", "Procurando servidores...", 3, "shuffle")
        task.spawn(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId
                .. "/servers/Public?sortOrder=Asc&limit=100"
            local corpo = httpGet(url)
            if not corpo then
                notificar("Erro", "Seu executor não suporta requisições HTTP.", 4, "x")
                return
            end

            local ok, dados = pcall(function() return HttpService:JSONDecode(corpo) end)
            if not ok or not dados or not dados.data then
                notificar("Erro", "Falha ao ler a lista de servidores.", 4, "x")
                return
            end

            -- junta todos os servidores válidos (com vaga e diferente do atual)
            local candidatos = {}
            for _, sv in ipairs(dados.data) do
                if sv.id ~= game.JobId and sv.playing and sv.maxPlayers
                    and sv.playing < sv.maxPlayers then
                    table.insert(candidatos, sv)
                end
            end

            if #candidatos == 0 then
                notificar("Servidor aleatório", "Nenhum servidor disponível encontrado.", 4, "info")
                return
            end

            -- escolhe um servidor aleatório
            local escolhido = candidatos[math.random(1, #candidatos)]
            notificar("Servidor aleatório",
                "Entrando em servidor com " .. escolhido.playing .. " jogadores...", 3, "log-in")
            task.wait(0.5)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, escolhido.id, LocalPlayer)
            end)
        end)
    end
})

-- ---- CÂMERA / MOVIMENTO ----
local fovValor = 70
local walkSpeedValor = 16
local jumpPowerValor = 50
local movimentoConexao

-- aplica FOV na câmera atual (reaplica se a câmera trocar)
local function aplicarFov()
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function() cam.FieldOfView = fovValor end)
    end
end

-- aplica velocidade e pulo no humanoide atual
local function aplicarMovimento()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function()
        hum.WalkSpeed = walkSpeedValor
        -- suporta os dois modos de pulo do Roblox
        hum.UseJumpPower = true
        hum.JumpPower = jumpPowerValor
    end)
end

-- garante que velocidade/pulo/FOV sejam reaplicados ao renascer
movimentoConexao = LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.4)
    aplicarMovimento()
    aplicarFov()
end)

TabUtil:CreateSlider({
    Name = "FOV (campo de visão)",
    Range = { 30, 120 },
    Increment = 1,
    Suffix = "°",
    CurrentValue = 70,
    Flag = "util_fov",
    Callback = function(valor)
        fovValor = valor
        aplicarFov()
    end
})

TabUtil:CreateSlider({
    Name = "WalkSpeed (velocidade)",
    Range = { 16, 200 },
    Increment = 1,
    Suffix = " studs/s",
    CurrentValue = 16,
    Flag = "util_walkspeed",
    Callback = function(valor)
        walkSpeedValor = valor
        aplicarMovimento()
    end
})

TabUtil:CreateSlider({
    Name = "JumpPower (força do pulo)",
    Range = { 50, 350 },
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "util_jumppower",
    Callback = function(valor)
        jumpPowerValor = valor
        aplicarMovimento()
    end
})

-- ---- ANTI-AFK ----
local antiAfkConexao

TabUtil:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "util_antiafk",
    Callback = function(valor)
        if valor then
            antiAfkConexao = LocalPlayer.Idled:Connect(function()
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end)
            notificar("Anti-AFK", "Você não será mais kickado por inatividade.", 3, "shield-check")
        else
            if antiAfkConexao then
                antiAfkConexao:Disconnect()
                antiAfkConexao = nil
            end
            notificar("Anti-AFK", "Desativado.", 3, "shield-off")
        end
    end
})

-- ---- FPS BOOST ----
local fpsBoostAtivo = false
local fpsOriginais = {
    materiais = {},     -- [part] = material
    efeitos = {},       -- [efeito] = Enabled (particles, trails, beams)
    luzes = {},         -- [efeito de lighting] = Enabled
    decoracao = nil,    -- Terrain.Decoration
    sombras = nil,      -- Lighting.GlobalShadows
}

local function aplicarFpsBoost()
    -- guarda e desativa efeitos do Lighting (blur, bloom, etc)
    fpsOriginais.sombras = Lighting.GlobalShadows
    Lighting.GlobalShadows = false
    for _, ef in ipairs(Lighting:GetChildren()) do
        if ef:IsA("PostEffect") then
            fpsOriginais.luzes[ef] = ef.Enabled
            ef.Enabled = false
        end
    end

    -- terreno sem decoração
    local terreno = Workspace:FindFirstChildOfClass("Terrain")
    if terreno then
        pcall(function()
            fpsOriginais.decoracao = terreno.Decoration
            terreno.Decoration = false
        end)
    end

    -- simplifica materiais e desativa partículas do mapa
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- não mexe em nada dos personagens (ghost/ESP continuam intactos)
        local modelo = obj:FindFirstAncestorOfClass("Model")
        local ehPersonagem = modelo and Players:GetPlayerFromCharacter(modelo)
        if not ehPersonagem then
            if obj:IsA("BasePart") then
                fpsOriginais.materiais[obj] = obj.Material
                obj.Material = Enum.Material.Plastic
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail")
                or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") then
                fpsOriginais.efeitos[obj] = obj.Enabled
                obj.Enabled = false
            end
        end
    end
end

local function removerFpsBoost()
    if fpsOriginais.sombras ~= nil then
        Lighting.GlobalShadows = fpsOriginais.sombras
    end
    for ef, ativo in pairs(fpsOriginais.luzes) do
        pcall(function() ef.Enabled = ativo end)
    end
    local terreno = Workspace:FindFirstChildOfClass("Terrain")
    if terreno and fpsOriginais.decoracao ~= nil then
        pcall(function() terreno.Decoration = fpsOriginais.decoracao end)
    end
    for parte, mat in pairs(fpsOriginais.materiais) do
        pcall(function() parte.Material = mat end)
    end
    for ef, ativo in pairs(fpsOriginais.efeitos) do
        pcall(function() ef.Enabled = ativo end)
    end
    fpsOriginais = { materiais = {}, efeitos = {}, luzes = {}, decoracao = nil, sombras = nil }
end

TabUtil:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Flag = "util_fpsboost",
    Callback = function(valor)
        fpsBoostAtivo = valor
        if valor then
            notificar("FPS Boost", "Otimizando gráficos...", 2, "zap")
            task.spawn(function()
                pcall(aplicarFpsBoost)
                notificar("FPS Boost", "Gráficos otimizados para desempenho.", 3, "zap")
            end)
        else
            task.spawn(function()
                pcall(removerFpsBoost)
                notificar("FPS Boost", "Gráficos restaurados.", 3, "image")
            end)
        end
    end
})

-- ---- PAINEL DE AVATARES DOS JOGADORES ----
local avatarGui = Instance.new("ScreenGui")
avatarGui.Name = "InfoHubAvatares"
avatarGui.IgnoreGuiInset = true
avatarGui.DisplayOrder = 8
avatarGui.ResetOnSpawn = false
avatarGui.Enabled = false
avatarGui.Parent = getParent()

local avatarPainel = Instance.new("Frame")
avatarPainel.Size = UDim2.new(0, 340, 0, 400)
avatarPainel.Position = UDim2.new(0.5, -170, 0.5, -200)
avatarPainel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
avatarPainel.BorderSizePixel = 0
avatarPainel.Active = true
avatarPainel.Draggable = true
avatarPainel.Parent = avatarGui
local avatarCanto = Instance.new("UICorner")
avatarCanto.CornerRadius = UDim.new(0, 10)
avatarCanto.Parent = avatarPainel

local avatarTopo = Instance.new("Frame")
avatarTopo.Size = UDim2.new(1, 0, 0, 40)
avatarTopo.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
avatarTopo.BorderSizePixel = 0
avatarTopo.Parent = avatarPainel
local avatarTopoCanto = Instance.new("UICorner")
avatarTopoCanto.CornerRadius = UDim.new(0, 10)
avatarTopoCanto.Parent = avatarTopo

local avatarTitulo = Instance.new("TextLabel")
avatarTitulo.Size = UDim2.new(1, -80, 1, 0)
avatarTitulo.Position = UDim2.new(0, 12, 0, 0)
avatarTitulo.BackgroundTransparency = 1
avatarTitulo.Text = "Avatares dos jogadores"
avatarTitulo.TextColor3 = Color3.fromRGB(255, 255, 255)
avatarTitulo.TextXAlignment = Enum.TextXAlignment.Left
avatarTitulo.Font = Enum.Font.GothamBold
avatarTitulo.TextSize = 15
avatarTitulo.Parent = avatarTopo

local avatarFechar = Instance.new("TextButton")
avatarFechar.Size = UDim2.new(0, 32, 0, 28)
avatarFechar.Position = UDim2.new(1, -38, 0.5, -14)
avatarFechar.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
avatarFechar.Text = "X"
avatarFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
avatarFechar.Font = Enum.Font.GothamBold
avatarFechar.TextSize = 14
avatarFechar.Parent = avatarTopo
local avatarFecharCanto = Instance.new("UICorner")
avatarFecharCanto.CornerRadius = UDim.new(0, 6)
avatarFecharCanto.Parent = avatarFechar

local avatarLista = Instance.new("ScrollingFrame")
avatarLista.Size = UDim2.new(1, -16, 1, -52)
avatarLista.Position = UDim2.new(0, 8, 0, 46)
avatarLista.BackgroundTransparency = 1
avatarLista.BorderSizePixel = 0
avatarLista.ScrollBarThickness = 4
avatarLista.CanvasSize = UDim2.new(0, 0, 0, 0)
avatarLista.AutomaticCanvasSize = Enum.AutomaticSize.Y
avatarLista.Parent = avatarPainel

local avatarGrid = Instance.new("UIGridLayout")
avatarGrid.CellSize = UDim2.new(0, 96, 0, 118)
avatarGrid.CellPadding = UDim2.new(0, 8, 0, 8)
avatarGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
avatarGrid.SortOrder = Enum.SortOrder.LayoutOrder
avatarGrid.Parent = avatarLista

local avatarPad = Instance.new("UIPadding")
avatarPad.PaddingTop = UDim.new(0, 4)
avatarPad.PaddingBottom = UDim.new(0, 4)
avatarPad.Parent = avatarLista

-- cria uma miniatura para um jogador
local function criarCartaoAvatar(jogador)
    local cartao = Instance.new("Frame")
    cartao.Name = "Cartao_" .. jogador.Name
    cartao.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    cartao.BorderSizePixel = 0
    cartao.Parent = avatarLista
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = cartao

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 80, 0, 80)
    img.Position = UDim2.new(0.5, -40, 0, 8)
    img.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    img.BorderSizePixel = 0
    img.Parent = cartao
    local ci = Instance.new("UICorner")
    ci.CornerRadius = UDim.new(0, 6)
    ci.Parent = img

    -- destaca você mesmo com uma borda
    if jogador == LocalPlayer then
        local borda = Instance.new("UIStroke")
        borda.Color = Color3.fromRGB(120, 200, 255)
        borda.Thickness = 2
        borda.Parent = img
    end

    -- carrega a miniatura do avatar
    task.spawn(function()
        local ok, url = pcall(function()
            return Players:GetUserThumbnailAsync(
                jogador.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
        end)
        if ok and url then
            img.Image = url
        end
    end)

    local nome = Instance.new("TextLabel")
    nome.Size = UDim2.new(1, -6, 0, 26)
    nome.Position = UDim2.new(0, 3, 1, -30)
    nome.BackgroundTransparency = 1
    nome.Text = jogador.DisplayName
    nome.TextColor3 = (jogador == LocalPlayer)
        and Color3.fromRGB(120, 200, 255) or Color3.fromRGB(230, 230, 230)
    nome.Font = Enum.Font.GothamMedium
    nome.TextSize = 11
    nome.TextWrapped = true
    nome.TextTruncate = Enum.TextTruncate.AtEnd
    nome.Parent = cartao
end

local function atualizarAvatares()
    -- limpa cartões antigos
    for _, filho in ipairs(avatarLista:GetChildren()) do
        if filho:IsA("Frame") then filho:Destroy() end
    end
    -- recria para os jogadores atuais
    for _, jogador in ipairs(Players:GetPlayers()) do
        criarCartaoAvatar(jogador)
    end
    avatarTitulo.Text = "Avatares (" .. #Players:GetPlayers() .. ")"
end

avatarFechar.MouseButton1Click:Connect(function()
    avatarGui.Enabled = false
    tocarSom(SONS.click, 0.4)
end)

-- mantém o painel sincronizado quando aberto
Players.PlayerAdded:Connect(function()
    if avatarGui.Enabled then task.wait(0.3) atualizarAvatares() end
end)
Players.PlayerRemoving:Connect(function()
    if avatarGui.Enabled then task.wait(0.3) atualizarAvatares() end
end)

TabUtil:CreateButton({
    Name = "Avatares dos jogadores",
    Callback = function()
        avatarGui.Enabled = not avatarGui.Enabled
        if avatarGui.Enabled then
            atualizarAvatares()
            notificar("Avatares", "Painel de avatares aberto.", 3, "users")
        end
    end
})

TabUtil:CreateButton({
    Name = "Atualizar avatares",
    Callback = function()
        if avatarGui.Enabled then
            atualizarAvatares()
        else
            notificar("Avatares", "Abra o painel de avatares primeiro.", 3, "info")
        end
    end
})

-- ---- DESTROY GUI ----
local destruirConfirmando = false

TabUtil:CreateButton({
    Name = "Destruir GUI",
    Callback = function()
        if not destruirConfirmando then
            destruirConfirmando = true
            notificar("Tem certeza?", "Toque novamente em até 5s para destruir o hub.", 5, "alert-triangle")
            task.delay(5, function() destruirConfirmando = false end)
            return
        end

        tocarSom(SONS.finalizar, 0.8)
        notificar("Info Hub", "Até a próxima, " .. LocalPlayer.DisplayName .. "!", 3, "hand")

        -- desliga tudo antes de destruir
        pcall(function()
            ghostAtivo = false
            pararGhost()
        end)
        pcall(function()
            espAtivo = false
            desligarESP()
        end)
        pcall(function()
            if antiAfkConexao then antiAfkConexao:Disconnect() end
        end)
        pcall(function()
            if fpsBoostAtivo then removerFpsBoost() end
        end)
        pcall(function()
            if movimentoConexao then movimentoConexao:Disconnect() end
        end)
        pcall(function() avatarGui:Destroy() end)

        task.wait(1)
        pcall(function() Window:Destroy() end)
        -- limpa GUIs residuais criadas pelo script
        for _, nome in ipairs({ "InfoHubIntro", "InfoHubErro", "InfoHubAvatares" }) do
            local g = getParent():FindFirstChild(nome)
            if g then pcall(function() g:Destroy() end) end
        end
    end
})

-- ======== ATUALIZAÇÃO EM TEMPO REAL ========
local inicio = os.clock()
task.spawn(function()
    while task.wait(1) do
        local ok = pcall(function()
            ParagJogadores:Set({ Title = "Jogadores", Content = #Players:GetPlayers() .. "/" .. Players.MaxPlayers })
            ParagPing:Set({ Title = "Ping", Content = getPing() })
            ParagHorario:Set({ Title = "Horário", Content = os.date("%H:%M:%S - %d/%m/%Y") })
            local seg = math.floor(os.clock() - inicio)
            ParagSessao:Set({ Title = "Tempo no servidor", Content = string.format("%02d:%02d:%02d", seg / 3600, (seg / 60) % 60, seg % 60) })
        end)
        if not ok then break end
    end
end)

notificar("Info Hub", "Carregado com sucesso, " .. LocalPlayer.DisplayName .. "!", 4, "check")

-- ======== SOM EM TODO CLIQUE/TOQUE NA GUI ========
UserInputService.InputBegan:Connect(function(input, processado)
    if processado and (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
        tocarSom(SONS.click, 0.4)
    end
end)

-- ======== NOTIFICAÇÃO APÓS 15 SEGUNDOS ========
task.delay(15, function()
    notificar("Hmm...", "alguém realmente usa isso?", 5, "help-circle")
end)
