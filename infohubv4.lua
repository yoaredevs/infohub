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

-- ======== ABA: AIM ASSIST (soft aim estilo console, universal) ========
local TabAim = Window:CreateTab("Aim Assist", "crosshair")

local aimAtivo = false
local aimForca = 0.6          -- 0.4 / 0.6 / 0.8 / 1.0 (40% a 100%)
local aimSuavidade = 10       -- quanto maior, mais suave/lento o puxão
local aimFovRaio = 120        -- raio do FOV em pixels
local aimDistMax = 300        -- distância máxima em studs
local aimParte = "Head"       -- parte do corpo mirada
local aimChecarTime = true    -- ignora aliados do mesmo time
local aimSomenteVisivel = false -- só mira alvos com linha de visão
local aimMostrarCirculo = true

local aimAlvo = nil
local aimLoop

-- círculo de FOV desenhado com GUI (funciona em qualquer executor/mobile)
local aimTela = Instance.new("ScreenGui")
aimTela.Name = "InfoHubAim"
aimTela.IgnoreGuiInset = true
aimTela.DisplayOrder = 6
aimTela.Enabled = false
aimTela.Parent = getParent()

local aimCirculo = Instance.new("Frame")
aimCirculo.AnchorPoint = Vector2.new(0.5, 0.5)
aimCirculo.BackgroundTransparency = 1
aimCirculo.BorderSizePixel = 0
aimCirculo.Parent = aimTela
local aimCirculoCanto = Instance.new("UICorner")
aimCirculoCanto.CornerRadius = UDim.new(1, 0)
aimCirculoCanto.Parent = aimCirculo
local aimCirculoStroke = Instance.new("UIStroke")
aimCirculoStroke.Color = Color3.fromRGB(255, 255, 255)
aimCirculoStroke.Thickness = 1.5
aimCirculoStroke.Transparency = 0.25
aimCirculoStroke.Parent = aimCirculo

-- resolve a parte do corpo mirada, com fallbacks
local function obterParteAlvo(char)
    if not char then return nil end
    local p = char:FindFirstChild(aimParte)
    if p then return p end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Head")
        or char:FindFirstChildWhichIsA("BasePart")
end

-- checa linha de visão entre a câmera e o alvo
local function temVisao(char, parte)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    local origem = Camera.CFrame.Position
    local dir = parte.Position - origem
    local resultado = workspace:Raycast(origem, dir, params)
    if not resultado then return true end
    return resultado.Instance:IsDescendantOf(char)
end

-- encontra o melhor alvo dentro do FOV, mais próximo do centro da tela
local function encontrarAlvo()
    local meuChar = LocalPlayer.Character
    local meuRoot = meuChar and meuChar:FindFirstChild("HumanoidRootPart")
    if not meuRoot then return nil end

    local viewport = Camera.ViewportSize
    local centro = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local melhor, menorDist = nil, aimFovRaio

    for _, jogador in ipairs(Players:GetPlayers()) do
        if jogador ~= LocalPlayer then
            local char = jogador.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local parte = obterParteAlvo(char)

            -- filtros: vivo, distância, time
            if char and hum and hum.Health > 0 and parte then
                local mesmoTime = aimChecarTime and jogador.Team
                    and LocalPlayer.Team and jogador.Team == LocalPlayer.Team
                local dist3D = (parte.Position - meuRoot.Position).Magnitude

                if not mesmoTime and dist3D <= aimDistMax then
                    local pos, naTela = Camera:WorldToViewportPoint(parte.Position)
                    if naTela then
                        local dist2D = (Vector2.new(pos.X, pos.Y) - centro).Magnitude
                        if dist2D < menorDist then
                            if not aimSomenteVisivel or temVisao(char, parte) then
                                melhor = parte
                                menorDist = dist2D
                            end
                        end
                    end
                end
            end
        end
    end
    return melhor
end

-- puxa suavemente a câmera na direção do alvo (soft aim)
local function passoAim(delta)
    if not aimMostrarCirculo then
        aimCirculo.Visible = false
    else
        local viewport = Camera.ViewportSize
        aimCirculo.Visible = true
        aimCirculo.Position = UDim2.new(0, viewport.X / 2, 0, viewport.Y / 2)
        aimCirculo.Size = UDim2.new(0, aimFovRaio * 2, 0, aimFovRaio * 2)
    end

    aimAlvo = encontrarAlvo()
    if not aimAlvo then return end

    local camCF = Camera.CFrame
    local desejado = CFrame.new(camCF.Position, aimAlvo.Position)
    -- alpha normalizado por framerate: força maior e suavidade menor = puxão mais forte
    local alpha = math.clamp((aimForca / aimSuavidade) * (delta * 60), 0, 1)
    Camera.CFrame = camCF:Lerp(desejado, alpha)
end

local function ligarAim()
    aimTela.Enabled = true
    aimLoop = RunService.RenderStepped:Connect(function(delta)
        pcall(passoAim, delta)
    end)
end

local function desligarAim()
    if aimLoop then
        pcall(function() aimLoop:Disconnect() end)
        aimLoop = nil
    end
    aimAlvo = nil
    aimTela.Enabled = false
end

TabAim:CreateToggle({
    Name = "Aim Assist Ativado",
    CurrentValue = false,
    Flag = "aim_toggle",
    Callback = function(valor)
        aimAtivo = valor
        if valor then
            ligarAim()
            notificar("Aim Assist", "Aim assist ativado.", 3, "crosshair")
        else
            desligarAim()
        end
    end
})

TabAim:CreateDropdown({
    Name = "Força do aim",
    Options = { "40%", "60%", "80%", "100%" },
    CurrentOption = { "60%" },
    Flag = "aim_forca",
    Callback = function(opcao)
        local escolha = type(opcao) == "table" and opcao[1] or opcao
        local mapa = { ["40%"] = 0.4, ["60%"] = 0.6, ["80%"] = 0.8, ["100%"] = 1.0 }
        aimForca = mapa[escolha] or 0.6
    end
})

TabAim:CreateSlider({
    Name = "Suavidade (smoothness)",
    Range = { 1, 25 },
    Increment = 1,
    Suffix = "",
    CurrentValue = 10,
    Flag = "aim_suavidade",
    Callback = function(valor) aimSuavidade = valor end
})

TabAim:CreateSlider({
    Name = "FOV (raio em pixels)",
    Range = { 40, 500 },
    Increment = 5,
    Suffix = " px",
    CurrentValue = 120,
    Flag = "aim_fov",
    Callback = function(valor) aimFovRaio = valor end
})

TabAim:CreateSlider({
    Name = "Distância máxima",
    Range = { 50, 2000 },
    Increment = 50,
    Suffix = " studs",
    CurrentValue = 300,
    Flag = "aim_dist",
    Callback = function(valor) aimDistMax = valor end
})

TabAim:CreateDropdown({
    Name = "Parte mirada",
    Options = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" },
    CurrentOption = { "Head" },
    Flag = "aim_parte",
    Callback = function(opcao)
        aimParte = type(opcao) == "table" and opcao[1] or opcao
    end
})

TabAim:CreateToggle({
    Name = "Ignorar mesmo time",
    CurrentValue = true,
    Flag = "aim_time",
    Callback = function(valor) aimChecarTime = valor end
})

TabAim:CreateToggle({
    Name = "Somente alvos visíveis",
    CurrentValue = false,
    Flag = "aim_visivel",
    Callback = function(valor) aimSomenteVisivel = valor end
})

TabAim:CreateToggle({
    Name = "Mostrar círculo de FOV",
    CurrentValue = true,
    Flag = "aim_circulo",
    Callback = function(valor) aimMostrarCirculo = valor end
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

-- ---- TP PARA JOGADOR (teleporte bruto via CFrame) ----
local tpAlvoNome = nil

-- monta a lista de nomes dos outros jogadores
local function listaNomesJogadores()
    local nomes = {}
    for _, jogador in ipairs(Players:GetPlayers()) do
        if jogador ~= LocalPlayer then
            table.insert(nomes, jogador.Name)
        end
    end
    return nomes
end

local tpDropdown = TabUtil:CreateDropdown({
    Name = "Jogador alvo",
    Options = listaNomesJogadores(),
    CurrentOption = {},
    Flag = "tp_alvo",
    Callback = function(opcao)
        tpAlvoNome = type(opcao) == "table" and opcao[1] or opcao
    end
})

TabUtil:CreateButton({
    Name = "Atualizar lista de jogadores",
    Callback = function()
        pcall(function()
            tpDropdown:Refresh(listaNomesJogadores(), false)
        end)
        notificar("TP", "Lista de jogadores atualizada.", 2, "refresh-cw")
    end
})

TabUtil:CreateButton({
    Name = "Teleportar até o jogador",
    Callback = function()
        if not tpAlvoNome then
            notificar("TP", "Selecione um jogador na lista primeiro.", 3, "info")
            return
        end
        local alvo = Players:FindFirstChild(tpAlvoNome)
        if not alvo then
            notificar("TP", "Jogador não encontrado. Atualize a lista.", 3, "x")
            return
        end
        local alvoChar = alvo.Character
        local alvoRoot = alvoChar and alvoChar:FindFirstChild("HumanoidRootPart")
        local meuChar = LocalPlayer.Character
        local meuRoot = meuChar and meuChar:FindFirstChild("HumanoidRootPart")
        if not alvoRoot or not meuRoot then
            notificar("TP", "Personagem indisponível (você ou o alvo).", 3, "x")
            return
        end
        -- teleporte bruto: seta o CFrame direto, com pequeno offset atrás do alvo
        pcall(function()
            meuRoot.CFrame = alvoRoot.CFrame * CFrame.new(0, 0, 3)
        end)
        notificar("TP", "Teleportado até " .. alvo.DisplayName .. ".", 3, "move")
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

-- ======== ABA: LEGIT ========
local TabLegit = Window:CreateTab("Legit", "skull")

-- ---- SPEED (Humanoid / C-Frame) ----
TabLegit:CreateSection("Speed")

local legitSpeedAtivo = false
local legitSpeedValor = 30
local legitSpeedMetodo = "C-Frame (Bypass)"
local legitSpeedLoop = nil

-- restaura o WalkSpeed padrão do personagem
local function legitSpeedRestaurar()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.WalkSpeed = 16 end)
    end
end

local function legitSpeedParar()
    if legitSpeedLoop then
        legitSpeedLoop:Disconnect()
        legitSpeedLoop = nil
    end
    legitSpeedRestaurar()
end

local function legitSpeedIniciar()
    legitSpeedParar()
    if legitSpeedMetodo == "Humanoid" then
        -- método direto: seta o WalkSpeed (jogos sem anti-cheat)
        legitSpeedLoop = RunService.Heartbeat:Connect(function()
            if not legitSpeedAtivo then return end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = legitSpeedValor
            end
        end)
    else
        -- método C-Frame (bypass): WalkSpeed fica em 16, o movimento
        -- extra é aplicado direto no CFrame na direção que o jogador anda
        legitSpeedLoop = RunService.Heartbeat:Connect(function(delta)
            if not legitSpeedAtivo then return end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not hum or not root then return end
            if hum.WalkSpeed ~= 16 then
                pcall(function() hum.WalkSpeed = 16 end)
            end
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then
                root.CFrame = root.CFrame + dir * (legitSpeedValor / 10) * (delta * 60) * 0.1
            end
        end)
    end
end

TabLegit:CreateDropdown({
    Name = "Método",
    Options = { "C-Frame (Bypass)", "Humanoid" },
    CurrentOption = { "C-Frame (Bypass)" },
    Flag = "legit_speed_metodo",
    Callback = function(opcao)
        local anterior = legitSpeedMetodo
        legitSpeedMetodo = type(opcao) == "table" and opcao[1] or opcao
        if legitSpeedAtivo and anterior ~= legitSpeedMetodo then
            legitSpeedIniciar()
        end
    end
})

TabLegit:CreateSlider({
    Name = "Velocidade",
    Range = { 16, 100 },
    Increment = 1,
    Suffix = "",
    CurrentValue = 30,
    Flag = "legit_speed_valor",
    Callback = function(valor)
        legitSpeedValor = valor
        if legitSpeedAtivo and legitSpeedMetodo == "Humanoid" then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.WalkSpeed = valor end) end
        end
    end
})

TabLegit:CreateToggle({
    Name = "Speed ativado",
    CurrentValue = false,
    Flag = "legit_speed_toggle",
    Callback = function(valor)
        legitSpeedAtivo = valor
        if valor then
            legitSpeedIniciar()
            notificar("Speed", "Ativado (" .. legitSpeedMetodo .. ").", 3, "zap")
        else
            legitSpeedParar()
            notificar("Speed", "Desativado. WalkSpeed restaurado.", 3, "zap-off")
        end
    end
})

-- ---- HITBOX EXPANDER (legit) ----
TabLegit:CreateSection("Hitbox Expander")

local hitboxAtivo = false
local hitboxTamanho = 6
local hitboxParte = "HumanoidRootPart"
local hitboxChecarTime = true
local hitboxOriginais = {} -- [BasePart] = { size, massless, cancollide }
local hitboxLoop = nil

-- restaura todas as hitboxes modificadas ao estado original
local function hitboxRestaurar()
    for parte, dados in pairs(hitboxOriginais) do
        pcall(function()
            if parte and parte.Parent then
                parte.Size = dados.size
                parte.Massless = dados.massless
                parte.CanCollide = dados.cancollide
            end
        end)
    end
    hitboxOriginais = {}
end

-- expande a hitbox do inimigo: só altera o Size da parte de colisão
-- e ativa Massless para não quebrar a física do jogo
local function hitboxAplicar()
    for _, jogador in ipairs(Players:GetPlayers()) do
        if jogador ~= LocalPlayer then
            local mesmoTime = hitboxChecarTime and jogador.Team
                and LocalPlayer.Team and jogador.Team == LocalPlayer.Team
            local char = jogador.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local parte = char and char:FindFirstChild(hitboxParte)
            if parte and hum and hum.Health > 0 and not mesmoTime then
                if not hitboxOriginais[parte] then
                    hitboxOriginais[parte] = {
                        size = parte.Size,
                        massless = parte.Massless,
                        cancollide = parte.CanCollide,
                    }
                end
                pcall(function()
                    parte.Size = Vector3.new(hitboxTamanho, hitboxTamanho, hitboxTamanho)
                    parte.Massless = true
                    parte.CanCollide = false
                end)
            end
        end
    end
end

TabLegit:CreateDropdown({
    Name = "Parte expandida",
    Options = { "HumanoidRootPart", "Head" },
    CurrentOption = { "HumanoidRootPart" },
    Flag = "legit_hitbox_parte",
    Callback = function(opcao)
        hitboxRestaurar()
        hitboxParte = type(opcao) == "table" and opcao[1] or opcao
    end
})

TabLegit:CreateSlider({
    Name = "Tamanho da hitbox",
    Range = { 2, 20 },
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 6,
    Flag = "legit_hitbox_tamanho",
    Callback = function(valor)
        hitboxTamanho = valor
    end
})

TabLegit:CreateToggle({
    Name = "Ignorar aliados (time)",
    CurrentValue = true,
    Flag = "legit_hitbox_time",
    Callback = function(valor)
        hitboxChecarTime = valor
        hitboxRestaurar()
    end
})

TabLegit:CreateToggle({
    Name = "Hitbox Expander ativado",
    CurrentValue = false,
    Flag = "legit_hitbox_toggle",
    Callback = function(valor)
        hitboxAtivo = valor
        if valor then
            local acumulado = 0
            hitboxLoop = RunService.Heartbeat:Connect(function(delta)
                if not hitboxAtivo then return end
                acumulado += delta
                if acumulado >= 0.5 then
                    acumulado = 0
                    pcall(hitboxAplicar)
                end
            end)
            notificar("Hitbox", "Expander ativado (" .. hitboxParte .. ").", 3, "target")
        else
            if hitboxLoop then
                hitboxLoop:Disconnect()
                hitboxLoop = nil
            end
            hitboxRestaurar()
            notificar("Hitbox", "Expander desativado. Hitboxes restauradas.", 3, "target")
        end
    end
})

-- ---- STAFF / ADMIN DETECTOR ----
TabLegit:CreateSection("Staff Detector")

local staffDetectorAtivo = false
local staffAcao = "Desligar tudo + fechar GUI"
local staffIgnorarAmigos = false
local staffConexao = nil

-- desliga todos os recursos do hub e destrói a interface
local function staffDesligarTudo()
    pcall(function()
        ghostAtivo = false
        pararGhost()
    end)
    pcall(function()
        espAtivo = false
        desligarESP()
    end)
    pcall(function()
        if aimLoop then aimLoop:Disconnect() end
        aimTela:Destroy()
    end)
    pcall(function()
        legitSpeedAtivo = false
        legitSpeedParar()
    end)
    pcall(function()
        hitboxAtivo = false
        if hitboxLoop then hitboxLoop:Disconnect() end
        hitboxRestaurar()
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
    pcall(function() Window:Destroy() end)
    for _, nome in ipairs({ "InfoHubIntro", "InfoHubErro", "InfoHubAim" }) do
        pcall(function()
            local g = getParent():FindFirstChild(nome)
            if g then g:Destroy() end
        end)
    end
end

-- foge para um servidor aleatório o mais rápido possível
local function staffFugirServidor()
    task.spawn(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId
            .. "/servers/Public?sortOrder=Asc&limit=100"
        local corpo = httpGet(url)
        if corpo then
            local ok, dados = pcall(function() return HttpService:JSONDecode(corpo) end)
            if ok and dados and dados.data then
                local candidatos = {}
                for _, sv in ipairs(dados.data) do
                    if sv.id ~= game.JobId and sv.playing and sv.maxPlayers
                        and sv.playing < sv.maxPlayers then
                        table.insert(candidatos, sv)
                    end
                end
                if #candidatos > 0 then
                    local escolhido = candidatos[math.random(1, #candidatos)]
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, escolhido.id, LocalPlayer)
                    end)
                    return
                end
            end
        end
        -- fallback: teleporte comum para qualquer instância do jogo
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end)
end

-- trava o cliente de propósito (parece queda de internet)
local function staffCrashCliente()
    task.spawn(function()
        task.wait(0.1)
        while true do end
    end)
end

-- verifica se o jogador tem cara de staff/admin do jogo
local function staffVerificarJogador(jogador)
    if jogador == LocalPlayer then return false, nil end

    -- 1) é o próprio criador do jogo (conta pessoal)
    if game.CreatorType == Enum.CreatorType.User and jogador.UserId == game.CreatorId then
        return true, "Criador do jogo"
    end

    -- 2) jogo pertence a um grupo: checa rank e cargo do jogador no grupo
    if game.CreatorType == Enum.CreatorType.Group then
        local okRank, rank = pcall(function()
            return jogador:GetRankInGroup(game.CreatorId)
        end)
        if okRank and rank and rank > 0 then
            -- rank alto no grupo dono do jogo = quase sempre staff
            if rank >= 200 then
                return true, "Rank " .. rank .. " no grupo do jogo"
            end
            -- rank baixo mas cargo com nome suspeito
            local okCargo, cargo = pcall(function()
                return jogador:GetRoleInGroup(game.CreatorId)
            end)
            if okCargo and cargo then
                local c = string.lower(cargo)
                for _, palavra in ipairs({ "admin", "mod", "staff", "dev", "owner", "founder" }) do
                    if string.find(c, palavra, 1, true) then
                        return true, "Cargo \"" .. cargo .. "\" no grupo do jogo"
                    end
                end
            end
        end
    end

    return false, nil
end

local function staffExecutarAcao(jogador, motivo)
    -- amigo detectado como staff: só avisa se o usuário pediu para ignorar
    if staffIgnorarAmigos then
        local okAmigo, amigo = pcall(function()
            return LocalPlayer:IsFriendsWith(jogador.UserId)
        end)
        if okAmigo and amigo then
            notificar("Staff Detector",
                jogador.DisplayName .. " parece staff (" .. motivo .. "), mas é seu amigo. Nenhuma ação tomada.",
                6, "shield-alert")
            return
        end
    end

    notificar("Staff Detector",
        "STAFF DETECTADO: " .. jogador.DisplayName .. " (" .. motivo .. ")!",
        5, "shield-alert")

    if staffAcao == "Desligar tudo + fechar GUI" then
        task.wait(0.2)
        staffDesligarTudo()
    elseif staffAcao == "Fugir para outro servidor" then
        staffDesligarTudo()
        staffFugirServidor()
    elseif staffAcao == "Crash proposital" then
        staffDesligarTudo()
        staffCrashCliente()
    end
end

TabLegit:CreateDropdown({
    Name = "Ação ao detectar staff",
    Options = { "Desligar tudo + fechar GUI", "Fugir para outro servidor", "Crash proposital" },
    CurrentOption = { "Desligar tudo + fechar GUI" },
    Flag = "legit_staff_acao",
    Callback = function(opcao)
        staffAcao = type(opcao) == "table" and opcao[1] or opcao
    end
})

TabLegit:CreateToggle({
    Name = "Ignorar amigos",
    CurrentValue = false,
    Flag = "legit_staff_amigos",
    Callback = function(valor)
        staffIgnorarAmigos = valor
    end
})

TabLegit:CreateToggle({
    Name = "Staff Detector ativado",
    CurrentValue = false,
    Flag = "legit_staff_toggle",
    Callback = function(valor)
        staffDetectorAtivo = valor
        if valor then
            -- monitora quem ENTRAR no servidor a partir de agora
            staffConexao = Players.PlayerAdded:Connect(function(jogador)
                if not staffDetectorAtivo then return end
                task.spawn(function()
                    local suspeito, motivo = staffVerificarJogador(jogador)
                    if suspeito then
                        staffExecutarAcao(jogador, motivo)
                    end
                end)
            end)
            -- varredura inicial: checa quem JÁ ESTÁ no servidor
            task.spawn(function()
                for _, jogador in ipairs(Players:GetPlayers()) do
                    if not staffDetectorAtivo then break end
                    local suspeito, motivo = staffVerificarJogador(jogador)
                    if suspeito then
                        staffExecutarAcao(jogador, motivo)
                        break
                    end
                    task.wait(0.1)
                end
                if staffDetectorAtivo then
                    notificar("Staff Detector", "Varredura concluída. Nenhum staff no servidor.", 3, "shield-check")
                end
            end)
        else
            if staffConexao then
                staffConexao:Disconnect()
                staffConexao = nil
            end
            notificar("Staff Detector", "Desativado.", 3, "shield-off")
        end
    end
})

-- ======== ABA: AVATARES DOS JOGADORES (nativa no Rayfield) ========
local TabAvatares = Window:CreateTab("Avatares", "users")
TabAvatares:CreateSection("Jogadores no servidor")

local avCabecalho = TabAvatares:CreateParagraph({
    Title = "Jogadores",
    Content = "Toque em \"Atualizar\" para carregar a lista."
})

local AV_MAX_SLOTS = 30
local avSlots = {}

-- localiza o frame do elemento recém-criado pelo texto-marcador do título
local function avAcharFrame(marcador)
    local raiz = getParent()
    if not raiz then return nil end
    for _, d in ipairs(raiz:GetDescendants()) do
        if d:IsA("TextLabel") and d.Name == "Title" and d.Text == marcador then
            return d.Parent
        end
    end
    return nil
end

-- pré-cria os slots (Rayfield não permite remover elementos, então reutilizamos)
for i = 1, AV_MAX_SLOTS do
    local marcador = "__avslot_" .. i
    local botao = TabAvatares:CreateButton({
        Name = marcador,
        Callback = function()
            local dados = avSlots[i]
            if dados and dados.player and dados.player.Parent then
                notificar("Avatar",
                    dados.player.DisplayName .. " (@" .. dados.player.Name
                    .. ")  •  UserId " .. dados.player.UserId, 4, "user")
            end
        end
    })

    local frame = avAcharFrame(marcador)
    local img
    if frame then
        img = Instance.new("ImageLabel")
        img.Name = "MiniAvatar"
        img.Size = UDim2.new(0, 34, 0, 34)
        img.Position = UDim2.new(0, 8, 0.5, -17)
        img.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        img.BorderSizePixel = 0
        img.ZIndex = 10
        img.Parent = frame
        local ic = Instance.new("UICorner")
        ic.CornerRadius = UDim.new(0, 6)
        ic.Parent = img
        -- empurra o texto do título para a direita da miniatura
        local titulo = frame:FindFirstChild("Title")
        if titulo then
            pcall(function()
                titulo.Position = UDim2.new(0, 52, titulo.Position.Y.Scale, titulo.Position.Y.Offset)
            end)
        end
        frame.Visible = false
    end

    avSlots[i] = { button = botao, frame = frame, image = img, player = nil }
end

local function atualizarAvatares()
    local jogadores = Players:GetPlayers()
    pcall(function()
        avCabecalho:Set({
            Title = "Jogadores (" .. #jogadores .. ")",
            Content = (#jogadores > AV_MAX_SLOTS)
                and ("Mostrando os primeiros " .. AV_MAX_SLOTS .. " jogadores.")
                or "Toque em um jogador para ver seus dados.",
        })
    end)

    for i = 1, AV_MAX_SLOTS do
        local dados = avSlots[i]
        local jogador = jogadores[i]
        dados.player = jogador

        if jogador then
            local etiqueta = jogador.DisplayName
            if jogador == LocalPlayer then etiqueta = etiqueta .. "  (você)" end
            pcall(function() dados.button:Set(etiqueta) end)
            if dados.frame then dados.frame.Visible = true end
            if dados.image then
                dados.image.Image = ""
                task.spawn(function()
                    local ok, url = pcall(function()
                        return Players:GetUserThumbnailAsync(
                            jogador.UserId,
                            Enum.ThumbnailType.HeadShot,
                            Enum.ThumbnailSize.Size150x150)
                    end)
                    if ok and url and dados.player == jogador then
                        dados.image.Image = url
                    end
                end)
            end
        else
            if dados.frame then
                dados.frame.Visible = false
            else
                -- sem injeção de frame: esconde textualmente o slot vazio
                pcall(function() dados.button:Set("—") end)
            end
        end
    end
end

TabAvatares:CreateButton({
    Name = "Atualizar lista de avatares",
    Callback = function()
        atualizarAvatares()
        notificar("Avatares", "Lista de avatares atualizada.", 2, "refresh-cw")
    end
})

-- sincroniza automaticamente quando alguém entra ou sai
Players.PlayerAdded:Connect(function() task.wait(0.4) atualizarAvatares() end)
Players.PlayerRemoving:Connect(function() task.wait(0.4) atualizarAvatares() end)

-- carrega uma vez ao abrir o hub
task.spawn(function() task.wait(0.6) atualizarAvatares() end)

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
        pcall(function()
            if aimLoop then aimLoop:Disconnect() end
        end)
        pcall(function() aimTela:Destroy() end)
        pcall(function()
            legitSpeedAtivo = false
            legitSpeedParar()
        end)
        pcall(function()
            hitboxAtivo = false
            if hitboxLoop then hitboxLoop:Disconnect() end
            hitboxRestaurar()
        end)
        pcall(function()
            staffDetectorAtivo = false
            if staffConexao then staffConexao:Disconnect() end
        end)

        task.wait(1)
        pcall(function() Window:Destroy() end)
        -- limpa GUIs residuais criadas pelo script
        for _, nome in ipairs({ "InfoHubIntro", "InfoHubErro", "InfoHubAim" }) do
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
