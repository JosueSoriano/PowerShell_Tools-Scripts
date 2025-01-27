# Script para crear arquitectura de carpetas automaticamente con Powershell
# By: Josué Soriano

# Validamos parámetros necesarios
Param(
[Parameter(Mandatory=$true,Position=0)]
[ValidateNotNullOrEmpty()]
[string]$RutaFicheroCSV)

# FUNCIONES
function Write-UserInfo {
    Param (
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$mensaje,
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$color
    )
    
    $fechahora = Get-Date -Format "[dd.MM.yyyy hh:mm:ss:ffff] "
    Write-Host -ForegroundColor $color "$fechahora $mensaje"
}

# EJECUCION
$ficheroCSV = try{
    Import-Csv $RutaFicheroCSV -Encoding utf8 -ErrorAction Stop
    Write-UserInfo -color Green -mensaje "INFO: FICHERO IMPORTADO OK"
}catch{
    Write-UserInfo -color Red -mensaje "ERROR: $_"
}

If (!$($ficheroCSV.RutaCompletaCarpetas)) {
    Write-UserInfo -color Red -mensaje "ERROR: No existe la columna 'RutaCompletaCarpetas' en el fichero CSV"
    Exit
}

Clear-Host
Write-UserInfo -color yellow -mensaje "--- SCRIPT CREACION AUTOMATICA DE CARPETAS ---"
foreach ($carpeta in $ficheroCSV.RutaCompletaCarpetas){
    try {
        New-Item -Path $carpeta -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Write-UserInfo -color Green -mensaje "CREADA: $carpeta"
    }
    catch {
        Write-UserInfo -color Red -mensaje "ERROR $carpeta ::: $_"
    }
}
Write-UserInfo -color yellow -mensaje "--- SCRIPT FINALIZADO ---`n"