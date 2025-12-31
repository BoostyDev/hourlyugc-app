# Script para limpiar y ejecutar Flutter después de actualizar Firebase

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  LIMPIANDO Y EJECUTANDO FLUTTER" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Cambiar al directorio del proyecto
Set-Location "C:\Mobileprofit\hourlyugc"

Write-Host "📁 Directorio actual: $PWD" -ForegroundColor Yellow
Write-Host ""

# Verificar que existe google-services.json actualizado
$googleServicesPath = "android\app\google-services.json"
if (Test-Path $googleServicesPath) {
    $fileInfo = Get-Item $googleServicesPath
    Write-Host "✅ google-services.json encontrado" -ForegroundColor Green
    Write-Host "   Última modificación: $($fileInfo.LastWriteTime)" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "❌ ERROR: google-services.json no encontrado" -ForegroundColor Red
    Write-Host "   Ruta esperada: $googleServicesPath" -ForegroundColor Red
    exit 1
}

# Buscar Flutter en ubicaciones comunes
$flutterPaths = @(
    "$env:LOCALAPPDATA\Android\Sdk\flutter\bin\flutter.bat",
    "$env:USERPROFILE\flutter\bin\flutter.bat",
    "C:\flutter\bin\flutter.bat",
    "C:\src\flutter\bin\flutter.bat"
)

$flutter = $null
foreach ($path in $flutterPaths) {
    if (Test-Path $path) {
        $flutter = $path
        break
    }
}

# Si no encontró Flutter, intentar usar el del PATH
if ($null -eq $flutter) {
    $flutter = "flutter"
}

Write-Host "🔍 Usando Flutter: $flutter" -ForegroundColor Yellow
Write-Host ""

# Paso 1: Flutter Clean
Write-Host "🧹 Paso 1/2: Limpiando cache de Flutter..." -ForegroundColor Cyan
Write-Host "Ejecutando: flutter clean" -ForegroundColor Gray
Write-Host ""

try {
    & $flutter clean
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Limpieza completada exitosamente" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "⚠️ Advertencia: flutter clean terminó con código $LASTEXITCODE" -ForegroundColor Yellow
        Write-Host ""
    }
} catch {
    Write-Host "❌ Error ejecutando flutter clean:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Continuando con flutter run de todas formas..." -ForegroundColor Yellow
    Write-Host ""
}

# Paso 2: Flutter Run
Write-Host "🚀 Paso 2/2: Ejecutando Flutter..." -ForegroundColor Cyan
Write-Host "Ejecutando: flutter run" -ForegroundColor Gray
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  INICIANDO APP - ESPERA..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏳ Compilando... (esto puede tomar 1-2 minutos)" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ Busca en los logs:" -ForegroundColor Green
Write-Host "   - Firebase App Check initialized (Debug mode)" -ForegroundColor White
Write-Host "   - SMS verification funcionando sin errores" -ForegroundColor White
Write-Host ""
Write-Host "❌ Si ves errores:" -ForegroundColor Red
Write-Host "   - Verifica que agregaste AMBOS SHA fingerprints" -ForegroundColor White
Write-Host "   - Verifica que descargaste el NUEVO google-services.json" -ForegroundColor White
Write-Host "   - Espera 2-3 minutos después de agregar los SHA" -ForegroundColor White
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

& $flutter run

