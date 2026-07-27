```powershell
# =========================================================
# GALERÍA DE VIAJES
# GENERADOR DE CATÁLOGO VISUAL DE IMÁGENES
# =========================================================

$ProjectDir = "C:\Proyectos\galeria-viajes-demo"

$ImagesDir = Join-Path `
    $ProjectDir `
    "assets\images\sitio-actual"

$InventoryFile = Join-Path `
    $ProjectDir `
    "assets\images\inventario-imagenes.csv"

$CatalogFile = Join-Path `
    $ProjectDir `
    "assets\images\catalogo-imagenes.html"


# =========================================================
# VALIDAR CARPETA
# =========================================================

if (-not (Test-Path $ImagesDir)) {

    Write-Host ""
    Write-Host "ERROR: No existe la carpeta de imagenes:" `
        -ForegroundColor Red

    Write-Host $ImagesDir

    exit

}


# =========================================================
# OBTENER IMÁGENES
# =========================================================

$Images = Get-ChildItem `
    -Path $ImagesDir `
    -File |
    Where-Object {
        $_.Extension.ToLower() -in @(
            ".jpg",
            ".jpeg",
            ".png",
            ".webp",
            ".gif",
            ".svg"
        )
    } |
    Sort-Object Name


Write-Host ""
Write-Host "==========================================" `
    -ForegroundColor Cyan

Write-Host " GENERADOR DE CATALOGO VISUAL" `
    -ForegroundColor Cyan

Write-Host "==========================================" `
    -ForegroundColor Cyan

Write-Host ""

Write-Host "Imagenes encontradas: $($Images.Count)" `
    -ForegroundColor Green


# =========================================================
# CARGAR INVENTARIO CSV
# =========================================================

$Inventory = @()

if (Test-Path $InventoryFile) {

    $Inventory = Import-Csv `
        -Path $InventoryFile

}


# =========================================================
# CREAR HTML
# =========================================================

$Html = @"
<!DOCTYPE html>

<html lang="es">

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Catálogo de imágenes - Galería de Viajes</title>


<style>

* {
    box-sizing: border-box;
}


body {

    margin: 0;

    font-family:
        Arial,
        Helvetica,
        sans-serif;

    background: #f3f5f7;

    color: #1f2933;

}


header {

    position: sticky;

    top: 0;

    z-index: 100;

    padding: 24px 40px;

    background:
        rgba(255,255,255,0.96);

    backdrop-filter:
        blur(10px);

    border-bottom:
        1px solid #e5e7eb;

}


.header-content {

    max-width: 1600px;

    margin: 0 auto;

    display: flex;

    align-items: center;

    justify-content: space-between;

    gap: 20px;

}


h1 {

    margin: 0;

    font-size: 24px;

}


.stats {

    color: #667085;

    font-size: 14px;

}


.controls {

    max-width: 1600px;

    margin: 24px auto 0;

    display: flex;

    gap: 12px;

    flex-wrap: wrap;

}


input {

    flex: 1;

    min-width: 280px;

    padding: 12px 16px;

    border:

        1px solid #d0d5dd;

    border-radius: 8px;

    font-size: 15px;

}


select {

    padding: 12px 16px;

    border:

        1px solid #d0d5dd;

    border-radius: 8px;

    background: white;

}


main {

    max-width: 1600px;

    margin: 0 auto;

    padding: 32px 40px 80px;

}


.grid {

    display: grid;

    grid-template-columns:
        repeat(
            auto-fill,
            minmax(280px, 1fr)
        );

    gap: 24px;

}


.card {

    background: white;

    border-radius: 12px;

    overflow: hidden;

    border:
        1px solid #e5e7eb;

    box-shadow:
        0 4px 15px
        rgba(0,0,0,0.05);

    transition:
        transform 0.2s ease,
        box-shadow 0.2s ease;

}


.card:hover {

    transform:
        translateY(-4px);

    box-shadow:
        0 12px 30px
        rgba(0,0,0,0.12);

}


.image-container {

    height: 220px;

    background: #e5e7eb;

    overflow: hidden;

    cursor: pointer;

}


.image-container img {

    width: 100%;

    height: 100%;

    object-fit: cover;

    display: block;

    transition:
        transform 0.3s ease;

}


.card:hover
.image-container img {

    transform:
        scale(1.04);

}


.info {

    padding: 16px;

}


.filename {

    font-weight: 600;

    font-size: 14px;

    word-break: break-word;

    margin-bottom: 10px;

}


.metadata {

    font-size: 12px;

    color: #667085;

    line-height: 1.7;

}


.source {

    margin-top: 10px;

    font-size: 11px;

    color: #98a2b3;

    word-break: break-all;

}


.badge {

    display: inline-block;

    margin-top: 10px;

    padding:
        4px 8px;

    border-radius: 20px;

    background: #eef2f6;

    font-size: 11px;

}


.empty {

    text-align: center;

    padding: 80px 20px;

    color: #667085;

}


.modal {

    display: none;

    position: fixed;

    z-index: 1000;

    inset: 0;

    background:
        rgba(0,0,0,0.88);

    align-items: center;

    justify-content: center;

    padding: 30px;

}


.modal.active {

    display: flex;

}


.modal-content {

    max-width: 95vw;

    max-height: 90vh;

    position: relative;

}


.modal-image {

    max-width: 95vw;

    max-height: 85vh;

    object-fit: contain;

    border-radius: 6px;

}


.close {

    position: absolute;

    top: -45px;

    right: 0;

    color: white;

    font-size: 34px;

    cursor: pointer;

}


.modal-caption {

    color: white;

    text-align: center;

    margin-top: 10px;

    font-size: 14px;

}


@media
(max-width: 700px) {

    header {

        padding: 20px;

    }


    main {

        padding:
            24px 20px 60px;

    }


    .header-content {

        display: block;

    }


    .stats {

        margin-top: 8px;

    }


    .grid {

        grid-template-columns:
            1fr;

    }

}

</style>

</head>


<body>


<header>

<div class="header-content">

<div>

<h1>
Catálogo Visual — Galería de Viajes
</h1>

<div class="stats">

Imágenes descargadas del sitio actual:
<strong>$($Images.Count)</strong>

</div>

</div>

</div>


<div class="controls">

<input
    type="text"
    id="search"
    placeholder="Buscar por nombre de imagen..."
>


<select id="extensionFilter">

<option value="">
Todas las extensiones
</option>

<option value=".jpg">
JPG
</option>

<option value=".jpeg">
JPEG
</option>

<option value=".png">
PNG
</option>

<option value=".webp">
WEBP
</option>

<option value=".gif">
GIF
</option>

<option value=".svg">
SVG
</option>

</select>

</div>

</header>


<main>

<div class="grid" id="gallery">

"@


# =========================================================
# GENERAR TARJETAS
# =========================================================

foreach ($Image in $Images) {


    $RelativePath = "sitio-actual/$($Image.Name)"

    $RelativePath = $RelativePath.Replace(
        "\",
        "/"
    )


    $InventoryItem = $Inventory |
        Where-Object {
            $_.Nombre -eq $Image.Name
        } |
        Select-Object -First 1


    $Resolution = ""

    $SizeKB = ""

    $SourcePage = ""


    if ($InventoryItem) {

        $Resolution =
            $InventoryItem.Resolucion

        $SizeKB =
            $InventoryItem.TamanoKB

        $SourcePage =
            $InventoryItem.PaginaEncontrada

    }


    $Extension =
        $Image.Extension.ToLower()


    $Html += @"

<article
    class="card"
    data-name="$($Image.Name.ToLower())"
    data-extension="$Extension"
>


<div
    class="image-container"
    onclick="openModal('$RelativePath', '$($Image.Name)')"
>

<img
    src="$RelativePath"
    alt="$($Image.Name)"
    loading="lazy"
>


</div>


<div class="info">


<div class="filename">

$($Image.Name)

</div>


<div class="metadata">

<strong>Extensión:</strong>
$Extension

<br>

<strong>Resolución:</strong>
$Resolution

<br>

<strong>Tamaño:</strong>
$SizeKB KB

</div>


"@


    if ($SourcePage) {

        $Html += @"

<div class="source">

<strong>Encontrada en:</strong>

<br>

$SourcePage

</div>

"@

    }


    $Html += @"

<span class="badge">

Imagen del sitio actual

</span>


</div>

</article>

"@

}


# =========================================================
# CERRAR HTML
# =========================================================

$Html += @"

</div>


<div
    class="empty"
    id="empty"
    style="display:none;"
>

No se encontraron imágenes
con los filtros seleccionados.

</div>

</main>


<div
    class="modal"
    id="modal"
    onclick="closeModal()"
>


<div
    class="modal-content"
    onclick="event.stopPropagation()"
>


<span
    class="close"
    onclick="closeModal()"
>
&times;
</span>


<img
    id="modalImage"
    class="modal-image"
    src=""
    alt=""
>


<div
    id="modalCaption"
    class="modal-caption"
>
</div>


</div>

</div>


<script>


const search =
    document.getElementById("search");


const extensionFilter =
    document.getElementById(
        "extensionFilter"
    );


const cards =
    document.querySelectorAll(
        ".card"
    );


const empty =
    document.getElementById(
        "empty"
    );


function filterGallery() {


    const searchValue =
        search.value
            .toLowerCase()
            .trim();


    const extensionValue =
        extensionFilter.value;


    let visible = 0;


    cards.forEach(card => {


        const name =
            card.dataset.name;


        const extension =
            card.dataset.extension;


        const matchesSearch =
            name.includes(
                searchValue
            );


        const matchesExtension =
            !extensionValue ||
            extension ===
                extensionValue;


        if (
            matchesSearch &&
            matchesExtension
        ) {

            card.style.display =
                "";

            visible++;

        }

        else {

            card.style.display =
                "none";

        }

    });


    empty.style.display =
        visible === 0
            ? "block"
            : "none";

}


search.addEventListener(
    "input",
    filterGallery
);


extensionFilter.addEventListener(
    "change",
    filterGallery
);


function openModal(
    image,
    caption
) {


    const modal =
        document.getElementById(
            "modal"
        );


    const modalImage =
        document.getElementById(
            "modalImage"
        );


    const modalCaption =
        document.getElementById(
            "modalCaption"
        );


    modalImage.src =
        image;


    modalImage.alt =
        caption;


    modalCaption.textContent =
        caption;


    modal.classList.add(
        "active"
    );

}


function closeModal() {


    const modal =
        document.getElementById(
            "modal"
        );


    modal.classList.remove(
        "active"
    );


}


document.addEventListener(
    "keydown",
    function(event) {

        if (
            event.key ===
            "Escape"
        ) {

            closeModal();

        }

    }
);


</script>


</body>

</html>

"@


# =========================================================
# GUARDAR ARCHIVO
# =========================================================

$Html |
    Out-File `
        -FilePath $CatalogFile `
        -Encoding UTF8


# =========================================================
# RESULTADO
# =========================================================

Write-Host ""

Write-Host "==========================================" `
    -ForegroundColor Green

Write-Host " CATALOGO GENERADO CORRECTAMENTE" `
    -ForegroundColor Green

Write-Host "==========================================" `
    -ForegroundColor Green

Write-Host ""

Write-Host "Imagenes:" `
    -ForegroundColor Cyan

Write-Host $Images.Count

Write-Host ""

Write-Host "Catalogo:" `
    -ForegroundColor Cyan

Write-Host $CatalogFile

Write-Host ""

Write-Host "Abriendo catalogo..." `
    -ForegroundColor Cyan


# =========================================================
# ABRIR EN NAVEGADOR
# =========================================================

Start-Process `
    $CatalogFile
```
