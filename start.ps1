# Start all services: backend, frontend, and remote agents

$baseDir = Get-Location
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

# Start Remote Agents
Write-Host "Starting all remote agents..." -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
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

$remoteAgentsDir = Join-Path $baseDir "remote_agents"

foreach ($agent in $agents) {
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

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "✅ All services have been started!" -ForegroundColor Green
Write-Host ""
Write-Host "Services running:" -ForegroundColor Cyan
Write-Host "  • Backend (FastAPI): http://localhost:8000" -ForegroundColor Gray
Write-Host "  • Frontend (Next.js): http://localhost:3000" -ForegroundColor Gray
Write-Host "  • Remote Agents: Each in its own window" -ForegroundColor Gray
Write-Host ""
Write-Host "Close individual windows to stop specific services." -ForegroundColor Cyan
