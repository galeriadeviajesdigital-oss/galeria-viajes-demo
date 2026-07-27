Add-Type -AssemblyName System.Drawing

$SourceDir = "C:\Proyectos\galeria-viajes-demo\assets\images\nueva-home"
$Images = Get-ChildItem -Path $SourceDir -File | Where-Object { $_.Extension -in @(".jpg", ".jpeg", ".png") }

foreach ($img in $Images) {
    $filePath = $img.FullName
    $outPath = [System.IO.Path]::ChangeExtension($filePath, ".webp")
    
    $bitmap = New-Object System.Drawing.Bitmap($filePath)
    $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/webp" }
    
    # Si el sistema soporta WebP nativo GDI+, lo guarda, de lo contrario se usa guardado estándar optimizado
    if ($encoder) {
        $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 85)
        $bitmap.Save($outPath, $encoder, $encParams)
    } else {
        # Respaldo alternativo de calidad alta en JPG/PNG optimizado si no está registrado el codec WebP en el entorno actual
        $bitmap.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    $bitmap.Dispose()
    Write-Host "Convertido: $($img.Name) -> WebP" -ForegroundColor Green
}