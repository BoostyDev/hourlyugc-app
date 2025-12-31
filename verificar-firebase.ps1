# Script de Verificación de Firebase

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  VERIFICACIÓN DE CONFIGURACIÓN FIREBASE" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar google-services.json
$googleServices = "android\app\google-services.json"
if (Test-Path $googleServices) {
    $file = Get-Item $googleServices
    Write-Host "✅ google-services.json encontrado" -ForegroundColor Green
    Write-Host "   Última modificación: $($file.LastWriteTime)" -ForegroundColor White
    
    # Leer y verificar project_id
    $content = Get-Content $googleServices | ConvertFrom-Json
    $projectId = $content.project_info.project_id
    $projectNumber = $content.project_info.project_number
    
    Write-Host "   Project ID: $projectId" -ForegroundColor White
    Write-Host "   Project Number: $projectNumber" -ForegroundColor White
    
    if ($projectNumber -eq "586195135805") {
        Write-Host "   ✅ Proyecto correcto" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Proyecto incorrecto" -ForegroundColor Red
    }
} else {
    Write-Host "❌ google-services.json NO encontrado" -ForegroundColor Red
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  SHA FINGERPRINTS A VERIFICAR EN FIREBASE" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "SHA-1:" -ForegroundColor Yellow
Write-Host "54:51:A7:DA:3F:93:CA:E4:48:7B:19:6B:0C:CB:93:05:F1:1D:13:AC" -ForegroundColor White
Write-Host ""
Write-Host "SHA-256:" -ForegroundColor Yellow
Write-Host "52:0A:EE:70:60:90:06:22:42:CA:D8:F1:DE:09:E5:9E:AC:C0:07:9A:40:35:78:D9:D1:A2:08:92:DE:2C:96:46" -ForegroundColor White
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "PASOS A SEGUIR:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Ve a: https://console.firebase.google.com/" -ForegroundColor White
Write-Host "2. Proyecto: postprofit-a4a46" -ForegroundColor White
Write-Host "3. ⚙️ Project Settings > Your apps > Android" -ForegroundColor White
Write-Host "4. Verifica que AMBOS SHA estén agregados" -ForegroundColor White
Write-Host "5. Si no están, agrégalos con 'Add fingerprint'" -ForegroundColor White
Write-Host "6. Espera 2-3 minutos después de agregar" -ForegroundColor White
Write-Host "7. Reinicia la app completamente (no hot reload)" -ForegroundColor White
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si ya agregaste los SHA hace menos de 5 minutos:" -ForegroundColor Yellow
Write-Host "- Espera 2-3 minutos más" -ForegroundColor White
Write-Host "- Firebase necesita tiempo para propagar los cambios" -ForegroundColor White
Write-Host "- Luego reinicia la app completamente" -ForegroundColor White
Write-Host ""

Read-Host "Presiona Enter para continuar..."

