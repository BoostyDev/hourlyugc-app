# Script para descargar assets de Figma
# Los URLs expiran en 7 dias - ejecutar pronto!

$assetsDir = "$PSScriptRoot\..\assets\icons"

# Crear directorio si no existe
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force
}

# Assets a descargar (del MCP de Figma)
$assets = @{
    # Gender icons (How do you identify?)
    "gender_male.png" = "https://www.figma.com/api/mcp/asset/15429e1e-2d97-471b-a17c-dd2427e27f55"
    "gender_female.png" = "https://www.figma.com/api/mcp/asset/cc199c66-f058-4ea5-86d8-abcb61ff7d34"
    "gender_other.png" = "https://www.figma.com/api/mcp/asset/bb3d6713-d4e0-4108-acbb-f49da8700f57"
    "gender_prefer_not.png" = "https://www.figma.com/api/mcp/asset/c0d250a0-806f-440a-be80-cfd3c5c39d96"
    
    # Social icons
    "instagram.png" = "https://www.figma.com/api/mcp/asset/a06ee044-9d36-4c5c-86bf-c9f8af65eae8"
    "tiktok_layer1.png" = "https://www.figma.com/api/mcp/asset/df6f964b-0c2c-442f-938f-b28ada02191a"
    "tiktok_layer2.png" = "https://www.figma.com/api/mcp/asset/d1c822a1-0f72-454a-b86d-1dafd989e183"
    "youtube.png" = "https://www.figma.com/api/mcp/asset/2257d505-d88b-4900-97c0-351f0855197b"
    "twitter_mask.png" = "https://www.figma.com/api/mcp/asset/7be9ee84-59e9-4a79-80eb-bf461d3b2e28"
    "twitter_content.png" = "https://www.figma.com/api/mcp/asset/635c06e2-eabc-4993-95e1-6f207a7cd643"
    
    # Experience level icons
    "exp_beginner.png" = "https://www.figma.com/api/mcp/asset/52b769e0-5503-402e-9991-eb35ce2761d2"
    "exp_intermediate.png" = "https://www.figma.com/api/mcp/asset/55b582b5-4b5e-4390-bc44-279139c38592"
    "exp_advanced.png" = "https://www.figma.com/api/mcp/asset/c6ffc4d9-b222-4ea0-9645-84643c5b5a29"
    "exp_professional.png" = "https://www.figma.com/api/mcp/asset/a1d9263c-cff7-4464-a90d-e3367159c9c5"
    
    # Profile picture icons
    "image_placeholder1.png" = "https://www.figma.com/api/mcp/asset/e052326c-66c1-4d44-831f-ae5c14221f69"
    "image_placeholder2.png" = "https://www.figma.com/api/mcp/asset/d176308d-5084-4835-ac16-69c7e61df6a6"
    "plus_circle.png" = "https://www.figma.com/api/mcp/asset/e9c10bec-47c2-4d00-878a-2dd5f6dfca53"
    
    # How did you find us icons
    "google_1.png" = "https://www.figma.com/api/mcp/asset/5a9dc688-82e4-45a9-af78-36d4baa1a8f9"
    "google_2.png" = "https://www.figma.com/api/mcp/asset/550fb59d-b50a-41f9-aac3-6bae9691958e"
    "google_3.png" = "https://www.figma.com/api/mcp/asset/2d01201c-bb67-4216-90af-42a4475f08aa"
    "google_4.png" = "https://www.figma.com/api/mcp/asset/3f49a4ef-f839-4bc6-a1d7-6a46834e1177"
    "friends_family.png" = "https://www.figma.com/api/mcp/asset/d4bc4bfc-2959-48f6-bed3-86fcff1e4ffa"
    "globe.png" = "https://www.figma.com/api/mcp/asset/f80aefc6-97b7-4c27-8c6b-14c03e6a309e"
    
    # Arrow icons
    "arrow_back.png" = "https://www.figma.com/api/mcp/asset/215ec1a3-a3af-42a2-b475-34118726309d"
    "arrow_right.png" = "https://www.figma.com/api/mcp/asset/57159479-6414-415a-80d7-df32cf307ee9"
}

Write-Host "Descargando assets de Figma..." -ForegroundColor Cyan
Write-Host "Directorio: $assetsDir" -ForegroundColor Gray

$downloaded = 0
$failed = 0

foreach ($asset in $assets.GetEnumerator()) {
    $filename = $asset.Key
    $url = $asset.Value
    $filepath = Join-Path $assetsDir $filename
    
    Write-Host "  Descargando $filename..." -NoNewline
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $filepath -UseBasicParsing
        Write-Host " OK" -ForegroundColor Green
        $downloaded++
    }
    catch {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Yellow
        $failed++
    }
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Descargados: $downloaded" -ForegroundColor Green
Write-Host "Fallidos: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })
Write-Host ""
Write-Host "Ahora actualiza pubspec.yaml para incluir los nuevos assets:" -ForegroundColor Yellow
Write-Host "  flutter:" -ForegroundColor White
Write-Host "    assets:" -ForegroundColor White
Write-Host "      - assets/icons/" -ForegroundColor White

