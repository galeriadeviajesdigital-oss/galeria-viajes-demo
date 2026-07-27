```powershell
# =========================================================
# GALERÍA DE VIAJES
# CRAWLER DE IMÁGENES Y PÁGINAS PÚBLICAS
#
# Propósito:
#   - Recorrer páginas públicas del dominio
#   - Detectar imágenes
#   - Descargar imágenes
#   - Evitar duplicados
#   - Generar inventario CSV
#
# Uso:
#   .\crawler-galeria-viajes.ps1
# =========================================================

$BaseUrl = "https://www.galeriadeviajes.com"

$OutputDir = "C:\Proyectos\galeria-viajes-demo\assets\images\sitio-actual"

$InventoryFile = "C:\Proyectos\galeria-viajes-demo\assets\images\inventario-imagenes.csv"

$VisitedFile = "C:\Proyectos\galeria-viajes-demo\assets\images\paginas-recorridas.csv"


# =========================================================
# CONFIGURACIÓN
# =========================================================

$MaxPages = 250

$DelayMilliseconds = 500

$AllowedExtensions = @(
    ".jpg",
    ".jpeg",
    ".png",
    ".webp",
    ".gif",
    ".svg"
)


# =========================================================
# PREPARAR CARPETAS
# =========================================================

New-Item `
    -ItemType Directory `
    -Force `
    -Path $OutputDir `
    | Out-Null


# =========================================================
# LISTAS DE CONTROL
# =========================================================

$VisitedPages = New-Object System.Collections.Generic.HashSet[string]

$DiscoveredPages = New-Object System.Collections.Generic.Queue[string]

$DownloadedImages = New-Object System.Collections.Generic.HashSet[string]


# =========================================================
# INVENTARIOS
# =========================================================

$ImageInventory = @()

$PageInventory = @()


# =========================================================
# FUNCIONES
# =========================================================


function Normalize-Url {

    param(
        [string]$Url
    )

    try {

        if ([string]::IsNullOrWhiteSpace($Url)) {
            return $null
        }

        $Url = $Url.Trim()

        # Eliminar espacios codificados
        $Url = $Url.Replace("&amp;", "&")

        # Ignorar anchors
        if ($Url.StartsWith("#")) {
            return $null
        }

        # Protocol-relative
        if ($Url.StartsWith("//")) {
            $Url = "https:" + $Url
        }

        # URL relativa
        elseif ($Url.StartsWith("/")) {
            $Url = $BaseUrl.TrimEnd("/") + $Url
        }

        # URL sin protocolo
        elseif (-not $Url.StartsWith("http")) {
            $Url = $BaseUrl.TrimEnd("/") + "/" + $Url.TrimStart("/")
        }

        $Uri = [System.Uri]$Url

        # Solo HTTP / HTTPS
        if ($Uri.Scheme -notin @("http", "https")) {
            return $null
        }

        # Solo dominio Galería de Viajes
        if ($Uri.Host -notlike "*galeriadeviajes.com") {
            return $null
        }

        # Normalizar
        $Builder = New-Object System.UriBuilder($Uri)

        # Eliminar fragmentos
        $Builder.Fragment = ""

        return $Builder.Uri.AbsoluteUri.TrimEnd("/")

    }
    catch {

        return $null

    }

}


function Get-SafeFileName {

    param(
        [string]$Url
    )

    try {

        $Uri = [System.Uri]$Url

        $FileName = [System.IO.Path]::GetFileName(
            $Uri.AbsolutePath
        )

        if ([string]::IsNullOrWhiteSpace($FileName)) {

            $FileName = "imagen"

        }

        # Eliminar caracteres inválidos
        $InvalidChars = [System.IO.Path]::GetInvalidFileNameChars()

        foreach ($Char in $InvalidChars) {

            $FileName = $FileName.Replace(
                $Char,
                "_"
            )

        }

        # Si no tiene extensión
        $Extension = [System.IO.Path]::GetExtension(
            $FileName
        )

        if ([string]::IsNullOrWhiteSpace($Extension)) {

            $FileName = $FileName + ".jpg"

        }

        return $FileName

    }
    catch {

        return "imagen.jpg"

    }

}


function Get-UniqueFileName {

    param(
        [string]$Directory,
        [string]$FileName
    )

    $BaseName = [System.IO.Path]::GetFileNameWithoutExtension(
        $FileName
    )

    $Extension = [System.IO.Path]::GetExtension(
        $FileName
    )

    $Candidate = Join-Path `
        $Directory `
        $FileName

    $Counter = 1

    while (Test-Path $Candidate) {

        $Candidate = Join-Path `
            $Directory `
            "$BaseName-$Counter$Extension"

        $Counter++

    }

    return $Candidate

}


function Get-ImageDimensions {

    param(
        [string]$FilePath
    )

    try {

        Add-Type -AssemblyName System.Drawing

        $Image = [System.Drawing.Image]::FromFile(
            $FilePath
        )

        $Width = $Image.Width

        $Height = $Image.Height

        $Image.Dispose()

        return "$Width x $Height"

    }
    catch {

        return "No disponible"

    }

}


function Get-ImageUrls {

    param(
        [string]$Html
    )

    $Results = New-Object System.Collections.Generic.HashSet[string]


    # =====================================================
    # SRC
    # =====================================================

    $Patterns = @(

        '(?i)src\s*=\s*["'']([^"'']+)["'']',

        '(?i)data-src\s*=\s*["'']([^"'']+)["'']',

        '(?i)data-lazy-src\s*=\s*["'']([^"'']+)["'']',

        '(?i)srcset\s*=\s*["'']([^"'']+)["'']',

        '(?i)data-srcset\s*=\s*["'']([^"'']+)["'']'

    )


    foreach ($Pattern in $Patterns) {

        $Matches = [regex]::Matches(
            $Html,
            $Pattern
        )


        foreach ($Match in $Matches) {

            $Value = $Match.Groups[1].Value

            # srcset puede contener múltiples URLs
            $Parts = $Value.Split(",")

            foreach ($Part in $Parts) {

                $ImageUrl = $Part.Trim()

                # Eliminar descriptor 1x / 2x / 800w
                $ImageUrl = $ImageUrl -replace '\s+\d+w$', ""

                $ImageUrl = $ImageUrl -replace '\s+\d+x$', ""

                if (
                    $ImageUrl -match '\.(jpg|jpeg|png|webp|gif|svg)'
                ) {

                    $Normalized = Normalize-Url `
                        -Url $ImageUrl

                    if ($Normalized) {

                        [void]$Results.Add(
                            $Normalized
                        )

                    }

                }

            }

        }

    }


    return $Results

}


function Get-InternalLinks {

    param(
        [string]$Html
    )

    $Results = New-Object System.Collections.Generic.HashSet[string]

    $Pattern = '(?i)href\s*=\s*["'']([^"'']+)["'']'

    $Matches = [regex]::Matches(
        $Html,
        $Pattern
    )


    foreach ($Match in $Matches) {

        $Link = $Match.Groups[1].Value

        $Normalized = Normalize-Url `
            -Url $Link


        if ($Normalized) {

            try {

                $Uri = [System.Uri]$Normalized

                # Evitar archivos que no sean páginas
                $Extension = [System.IO.Path]::GetExtension(
                    $Uri.AbsolutePath
                )

                if (
                    $Extension -eq "" -or
                    $Extension -eq ".html" -or
                    $Extension -eq ".htm" -or
                    $Extension -eq ".php"
                ) {

                    [void]$Results.Add(
                        $Normalized
                    )

                }

            }
            catch {

            }

        }

    }


    return $Results

}


# =========================================================
# INICIAR CRAWLER
# =========================================================

Write-Host ""
Write-Host "==========================================" `
    -ForegroundColor Cyan

Write-Host " GALERIA DE VIAJES - CRAWLER" `
    -ForegroundColor Cyan

Write-Host "==========================================" `
    -ForegroundColor Cyan

Write-Host ""

Write-Host "Sitio: $BaseUrl"

Write-Host "Maximo de paginas: $MaxPages"

Write-Host "Directorio de imagenes: $OutputDir"

Write-Host ""


# Agregar página inicial
$DiscoveredPages.Enqueue(
    $BaseUrl
)


# =========================================================
# BUCLE PRINCIPAL
# =========================================================

while (
    $DiscoveredPages.Count -gt 0 -and
    $VisitedPages.Count -lt $MaxPages
) {


    $CurrentUrl = $DiscoveredPages.Dequeue()


    if (
        $VisitedPages.Contains(
            $CurrentUrl
        )
    ) {

        continue

    }


    Write-Host ""
    Write-Host "------------------------------------------" `
        -ForegroundColor DarkGray

    Write-Host "Pagina $($VisitedPages.Count + 1) de $MaxPages" `
        -ForegroundColor Yellow

    Write-Host $CurrentUrl `
        -ForegroundColor White


    try {


        # =================================================
        # DESCARGAR HTML
        # =================================================

        $Response = Invoke-WebRequest `
            -Uri $CurrentUrl `
            -UseBasicParsing `
            -TimeoutSec 30


        $Html = $Response.Content


        # Marcar como visitada
        [void]$VisitedPages.Add(
            $CurrentUrl
        )


        # Registrar página
        $PageInventory += [PSCustomObject]@{

            Fecha = Get-Date

            Url = $CurrentUrl

            Status = $Response.StatusCode

        }


        # =================================================
        # ENCONTRAR IMÁGENES
        # =================================================

        $Images = Get-ImageUrls `
            -Html $Html


        Write-Host "Imagenes encontradas: $($Images.Count)" `
            -ForegroundColor Green


        foreach ($ImageUrl in $Images) {


            if (
                $DownloadedImages.Contains(
                    $ImageUrl
                )
            ) {

                continue

            }


            try {


                $FileName = Get-SafeFileName `
                    -Url $ImageUrl


                $Destination = Get-UniqueFileName `
                    -Directory $OutputDir `
                    -FileName $FileName


                Write-Host "  Descargando: $FileName"


                Invoke-WebRequest `
                    -Uri $ImageUrl `
                    -OutFile $Destination `
                    -UseBasicParsing `
                    -TimeoutSec 30


                # Agregar al registro de descargadas
                [void]$DownloadedImages.Add(
                    $ImageUrl
                )


                # Información del archivo
                $FileInfo = Get-Item `
                    $Destination


                $Dimensions = Get-ImageDimensions `
                    -FilePath $Destination


                # Registrar imagen
                $ImageInventory += [PSCustomObject]@{

                    Nombre = $FileInfo.Name

                    UrlOriginal = $ImageUrl

                    PaginaEncontrada = $CurrentUrl

                    Extension = $FileInfo.Extension

                    TamanoBytes = $FileInfo.Length

                    TamanoKB = [math]::Round(
                        $FileInfo.Length / 1KB,
                        2
                    )

                    Resolucion = $Dimensions

                    RutaLocal = $Destination

                    FechaDescarga = Get-Date

                }


            }
            catch {


                Write-Host "  ERROR imagen: $ImageUrl" `
                    -ForegroundColor Red


            }


        }


        # =================================================
        # ENCONTRAR ENLACES INTERNOS
        # =================================================

        $Links = Get-InternalLinks `
            -Html $Html


        foreach ($Link in $Links) {


            if (
                -not $VisitedPages.Contains(
                    $Link
                )
            ) {

                $DiscoveredPages.Enqueue(
                    $Link
                )

            }

        }


        # =================================================
        # GUARDAR INVENTARIO PARCIAL
        # =================================================

        if (
            $ImageInventory.Count -gt 0
        ) {

            $ImageInventory |
                Export-Csv `
                    -Path $InventoryFile `
                    -NoTypeInformation `
                    -Encoding UTF8

        }


        if (
            $PageInventory.Count -gt 0
        ) {

            $PageInventory |
                Export-Csv `
                    -Path $VisitedFile `
                    -NoTypeInformation `
                    -Encoding UTF8

        }


        Start-Sleep `
            -Milliseconds $DelayMilliseconds


    }
    catch {


        Write-Host "ERROR al procesar pagina:" `
            -ForegroundColor Red

        Write-Host $CurrentUrl `
            -ForegroundColor Red


        $PageInventory += [PSCustomObject]@{

            Fecha = Get-Date

            Url = $CurrentUrl

            Status = "ERROR"

        }


    }


}


# =========================================================
# RESULTADO FINAL
# =========================================================

Write-Host ""
Write-Host ""
Write-Host "==========================================" `
    -ForegroundColor Green

Write-Host " CRAWLER FINALIZADO" `
    -ForegroundColor Green

Write-Host "==========================================" `
    -ForegroundColor Green

Write-Host ""

Write-Host "Paginas recorridas:" `
    -ForegroundColor Cyan

Write-Host $VisitedPages.Count


Write-Host ""

Write-Host "Imagenes descargadas:" `
    -ForegroundColor Cyan

Write-Host $DownloadedImages.Count


Write-Host ""

Write-Host "Inventario:" `
    -ForegroundColor Cyan

Write-Host $InventoryFile


Write-Host ""

Write-Host "Paginas recorridas:" `
    -ForegroundColor Cyan

Write-Host $VisitedFile


Write-Host ""

Write-Host "Las imagenes estan en:" `
    -ForegroundColor Cyan

Write-Host $OutputDir


Write-Host ""
Write-Host "==========================================" `
    -ForegroundColor Green
```
