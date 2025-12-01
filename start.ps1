# Start A2A System with optional agent selection

$baseDir = Get-Location
Write-Host "🚀 Starting A2A System (Backend + Frontend + Remote Agents)..." -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Array of all remote agent directories
$agents = @(
    "azurefoundry_assessment",
    "azurefoundry_branding",
    "azurefoundry_claims",
    "azurefoundry_classification",
    "azurefoundry_Deep_Search",
    "azurefoundry_fraud",
    "azurefoundry_image_analysis",
    "azurefoundry_image_generator",
    "azurefoundry_legal"
)

# Interactive agent selection menu
Write-Host "Select which agents to start:" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow
Write-Host ""

$agentSelections = @{}
for ($i = 0; $i -lt $agents.Count; $i++) {
    $agentSelections[$agents[$i]] = $false
}

$selectedIndex = 0
$selectedAgents = @()
$proceed = $false

while (-not $proceed) {
    Clear-Host
    Write-Host "🚀 Starting A2A System - Agent Selection" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Use arrow keys to navigate, Space to select/deselect, Enter to start" -ForegroundColor Gray
    Write-Host ""
    
    # Display agent list with checkboxes
    for ($i = 0; $i -lt $agents.Count; $i++) {
        $agent = $agents[$i]
        $isSelected = $agentSelections[$agent]
        $checkbox = if ($isSelected) { "☑️ " } else { "☐ " }
        $highlight = if ($i -eq $selectedIndex) { " ◄ " } else { "   " }
        $color = if ($i -eq $selectedIndex) { "Cyan" } else { "White" }
        
        Write-Host "$checkbox$($i+1). $agent$highlight" -ForegroundColor $color
    }
    
    Write-Host ""
    Write-Host "Selected: $($agentSelections.Values | Where-Object { $_ } | Measure-Object).Count / $($agents.Count) agents" -ForegroundColor Green
    Write-Host ""
    
    # Get keyboard input
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    if ($key.KeyDown) {
        switch ($key.VirtualKeyCode) {
            38 { # Up arrow
                $selectedIndex = if ($selectedIndex -gt 0) { $selectedIndex - 1 } else { $agents.Count - 1 }
            }
            40 { # Down arrow
                $selectedIndex = if ($selectedIndex -lt $agents.Count - 1) { $selectedIndex + 1 } else { 0 }
            }
            32 { # Space - toggle selection
                $agent = $agents[$selectedIndex]
                $agentSelections[$agent] = -not $agentSelections[$agent]
            }
            13 { # Enter - proceed with selected agents
                $selectedAgents = @($agents | Where-Object { $agentSelections[$_] })
                $proceed = $true
            }
        }
    }
}

Clear-Host
Write-Host "🚀 Starting A2A System (Backend + Frontend + Remote Agents)..." -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Start Backend
Write-Host "Starting Backend (FastAPI)..." -ForegroundColor Green
$backendPath = Join-Path $baseDir "backend"
Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; Write-Host 'Starting Backend...'; python.exe backend_production.py" -WindowStyle Normal
Write-Host "✅ Backend started in new window" -ForegroundColor Green
Start-Sleep -Milliseconds 1000
Write-Host ""

# Start Frontend
Write-Host "Starting Frontend (Next.js)..." -ForegroundColor Green
$frontendPath = Join-Path $baseDir "frontend"
Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd '$frontendPath'; Write-Host 'Starting Frontend...'; npm run dev" -WindowStyle Normal
Write-Host "✅ Frontend started in new window" -ForegroundColor Green
Start-Sleep -Milliseconds 1000
Write-Host ""

# Start Selected Remote Agents
if ($selectedAgents.Count -gt 0) {
    Write-Host "Starting selected remote agents..." -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host ""

    $remoteAgentsDir = Join-Path $baseDir "remote_agents"

    foreach ($agent in $selectedAgents) {
        $agentPath = Join-Path $remoteAgentsDir $agent
        
        if (-not (Test-Path $agentPath)) {
            Write-Host "⚠️  Agent directory not found: $agent" -ForegroundColor Yellow
            continue
        }
        
        Write-Host "Starting agent: $agent" -ForegroundColor Cyan
        
        # Start the agent in a new PowerShell window
        Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd '$agentPath'; Write-Host 'Starting $agent...'; uv run . --ui" -WindowStyle Normal
        
        Write-Host "✅ $agent started in new window" -ForegroundColor Green
        
        # Brief delay between starting each agent to avoid overwhelming the system
        Start-Sleep -Milliseconds 500
    }
} else {
    Write-Host "No agents selected." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "✅ All selected services have been started!" -ForegroundColor Green
Write-Host ""
Write-Host "Services running:" -ForegroundColor Cyan
Write-Host "  • Backend (FastAPI): http://localhost:8000" -ForegroundColor Gray
Write-Host "  • Frontend (Next.js): http://localhost:3000" -ForegroundColor Gray
if ($selectedAgents.Count -gt 0) {
    Write-Host "  • Remote Agents ($($selectedAgents.Count)): Each in its own window" -ForegroundColor Gray
}
Write-Host ""
Write-Host "Close individual windows to stop specific services." -ForegroundColor Cyan
