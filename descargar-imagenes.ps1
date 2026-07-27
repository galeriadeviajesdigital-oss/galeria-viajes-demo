$baseUrl = "https://www.galeriadeviajes.com"
$outputDir = "C:\Proyectos\galeria-viajes-demo\assets\images\sitio-actual"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Write-Host "Obteniendo pagina principal..." -ForegroundColor Cyan

$html = Invoke-WebRequest -Uri $baseUrl -UseBasicParsing

# Buscar URLs de imagen
$imageUrls = [regex]::Matches(
    $html.Content,
    '(?i)(?:src|data-src|data-lazy-src|srcset)=["'']([^"'']+\.(?:jpg|jpeg|png|webp|gif)(?:\?[^"'']*)?)["'']'
) | ForEach-Object {
    $_.Groups[1].Value
}

$imageUrls = $imageUrls | Select-Object -Unique

Write-Host "Imagenes encontradas: $($imageUrls.Count)" -ForegroundColor Green

$count = 0

foreach ($imageUrl in $imageUrls) {

    try {

        # Convertir URL relativa a absoluta
        if ($imageUrl.StartsWith("//")) {
            $imageUrl = "https:" + $imageUrl
        }
        elseif ($imageUrl.StartsWith("/")) {
            $imageUrl = $baseUrl + $imageUrl
        }
        elseif (-not $imageUrl.StartsWith("http")) {
            $imageUrl = "$baseUrl/$imageUrl"
        }

        # Limpiar query string
        $cleanUrl = $imageUrl.Split("?")[0]

        # Obtener nombre
        $fileName = [System.IO.Path]::GetFileName(
            ([System.Uri]$cleanUrl).AbsolutePath
        )

        if ([string]::IsNullOrWhiteSpace($fileName)) {
            $fileName = "imagen_$count.jpg"
        }

        $destination = Join-Path $outputDir $fileName

        # Evitar duplicados
        if (Test-Path $destination) {
            $count++
            continue
        }

        Write-Host "Descargando: $fileName"

        Invoke-WebRequest `
            -Uri $imageUrl `
            -OutFile $destination `
            -UseBasicParsing

        $count++

    }
    catch {

        Write-Host "No se pudo descargar: $imageUrl" -ForegroundColor Yellow

    }
}

Write-Host ""
Write-Host "Proceso terminado." -ForegroundColor Green
Write-Host "Imagenes descargadas: $count"
Write-Host "Ubicacion: $outputDir"