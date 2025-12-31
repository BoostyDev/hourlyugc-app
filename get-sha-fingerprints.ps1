# Script para obtener SHA-1 y SHA-256 fingerprints
# Para Firebase Authentication

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  OBTENIENDO SHA FINGERPRINTS PARA FIREBASE" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Ruta del debug keystore
$keystorePath = "$env:USERPROFILE\.android\debug.keystore"

Write-Host "Buscando keystore en: $keystorePath" -ForegroundColor Yellow
Write-Host ""

if (-Not (Test-Path $keystorePath)) {
    Write-Host "❌ ERROR: No se encontró el debug keystore" -ForegroundColor Red
    Write-Host "   Ubicación esperada: $keystorePath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Solución:" -ForegroundColor Yellow
    Write-Host "1. Ejecuta la app al menos una vez con 'flutter run'" -ForegroundColor White
    Write-Host "2. El keystore se creará automáticamente" -ForegroundColor White
    exit 1
}

Write-Host "✅ Keystore encontrado" -ForegroundColor Green
Write-Host ""

# Buscar keytool en ubicaciones comunes
$keytoolLocations = @(
    "$env:JAVA_HOME\bin\keytool.exe",
    "C:\Program Files\Java\jdk-17\bin\keytool.exe",
    "C:\Program Files\Java\jdk-11\bin\keytool.exe",
    "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
    "C:\Program Files\Android\Android Studio\jre\bin\keytool.exe",
    "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\keytool.bat"
)

$keytool = $null
foreach ($location in $keytoolLocations) {
    if (Test-Path $location) {
        $keytool = $location
        break
    }
}

if ($null -eq $keytool) {
    Write-Host "❌ ERROR: No se encontró keytool" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, usa uno de estos métodos alternativos:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "MÉTODO 1: Android Studio" -ForegroundColor Cyan
    Write-Host "  1. Abre Android Studio" -ForegroundColor White
    Write-Host "  2. Abre: C:\Mobileprofit\hourlyugc\android" -ForegroundColor White
    Write-Host "  3. Ve a: Gradle panel > Tasks > android > signingReport" -ForegroundColor White
    Write-Host "  4. Doble click en signingReport" -ForegroundColor White
    Write-Host ""
    Write-Host "MÉTODO 2: Instalar Java" -ForegroundColor Cyan
    Write-Host "  1. Descarga: https://adoptium.net/temurin/releases/?version=17" -ForegroundColor White
    Write-Host "  2. Instala Java 17" -ForegroundColor White
    Write-Host "  3. Ejecuta este script nuevamente" -ForegroundColor White
    Write-Host ""
    Write-Host "MÉTODO 3: Firebase Console" -ForegroundColor Cyan
    Write-Host "  1. Compila la app y prueba phone auth" -ForegroundColor White
    Write-Host "  2. Firebase mostrará el SHA-1 correcto en el error" -ForegroundColor White
    Write-Host "  3. Copia ese SHA-1 a Firebase Console" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "✅ Keytool encontrado en:" -ForegroundColor Green
Write-Host "   $keytool" -ForegroundColor White
Write-Host ""
Write-Host "Obteniendo fingerprints..." -ForegroundColor Yellow
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan

try {
    # Ejecutar keytool
    $output = & $keytool -list -v -keystore $keystorePath -alias androiddebugkey -storepass android -keypass android 2>&1
    
    # Extraer SHA-1 y SHA-256
    $sha1 = ""
    $sha256 = ""
    
    foreach ($line in $output) {
        if ($line -match "SHA1:\s*(.+)") {
            $sha1 = $matches[1].Trim()
        }
        if ($line -match "SHA256:\s*(.+)") {
            $sha256 = $matches[1].Trim()
        }
    }
    
    if ($sha1 -and $sha256) {
        Write-Host ""
        Write-Host "✅ ¡FINGERPRINTS OBTENIDOS!" -ForegroundColor Green
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "📋 COPIA ESTOS VALORES A FIREBASE CONSOLE:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "SHA-1:" -ForegroundColor Cyan
        Write-Host $sha1 -ForegroundColor White
        Write-Host ""
        Write-Host "SHA-256:" -ForegroundColor Cyan
        Write-Host $sha256 -ForegroundColor White
        Write-Host ""
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "📝 PASOS SIGUIENTES:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1. Ve a: https://console.firebase.google.com/" -ForegroundColor White
        Write-Host "2. Proyecto: postprofit-a4a46" -ForegroundColor White
        Write-Host "3. Project Settings (⚙️) > Your apps > Android" -ForegroundColor White
        Write-Host "4. Click 'Add fingerprint'" -ForegroundColor White
        Write-Host "5. Pega el SHA-1 y guarda" -ForegroundColor White
        Write-Host "6. Click 'Add fingerprint' nuevamente" -ForegroundColor White
        Write-Host "7. Pega el SHA-256 y guarda" -ForegroundColor White
        Write-Host "8. Descarga el nuevo google-services.json" -ForegroundColor White
        Write-Host "9. Reemplázalo en: android\app\google-services.json" -ForegroundColor White
        Write-Host "10. Ejecuta: flutter clean && flutter run" -ForegroundColor White
        Write-Host ""
        Write-Host "==================================================" -ForegroundColor Cyan
        
        # Guardar en archivo
        $outputFile = "SHA_FINGERPRINTS.txt"
        @"
Firebase SHA Fingerprints
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

SHA-1:
$sha1

SHA-256:
$sha256

Next Steps:
1. Go to: https://console.firebase.google.com/
2. Project: postprofit-a4a46
3. Project Settings > Your apps > Android app
4. Click "Add fingerprint" and add SHA-1
5. Click "Add fingerprint" and add SHA-256
6. Download new google-services.json
7. Replace: android\app\google-services.json
8. Run: flutter clean && flutter run
"@ | Out-File -FilePath $outputFile -Encoding UTF8
        
        Write-Host "✅ Fingerprints guardados en: $outputFile" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "❌ No se pudieron extraer los fingerprints" -ForegroundColor Red
        Write-Host "Output completo:" -ForegroundColor Yellow
        Write-Host $output
    }
} catch {
    Write-Host "❌ ERROR al ejecutar keytool:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

