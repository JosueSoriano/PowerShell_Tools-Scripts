<#
.SYNOPSIS
    Script para conectar las unidades de red SMB de un NAS en una red local a un equipo Windows por Powershell

.DESCRIPTION
    Este script recoge los datos de las rutas SMB de un NAS local para poder conectarlas como unidades de red
    en el equipo local donde se ejecute este script

.EXAMPLE
    .\Connect-NAS-SMB.ps1

.NOTES
    Autor: Josué Soriano
    Fecha: 27-06-2024
    Version: 1.0.0 - Version Inicial
#>


# ... VARIABLES ..................................................................... #

# IP del NAS
$ipsmb = "192.168.0.50"
# Letras para asignar las unidades, deben coincidir con las letras del Diccionario
$arrayletras = @("U","V")
# Diccionario de letras de unidades y rutas. Las letras deben coincidir con el array anterior
$dict = [ordered]@{
    U="\\$ipsmb\Principal";
    V="\\$ipsmb\Secundario";
}


# ... FUNCIONES ...................................................................... #
function Invoke-MontarUnidadesNAS {
    param (
        [string]$ipsmb,
        [array]$arrayletras,
        [hashtable]$dict,
        [pscredential]$cred
    )

    Begin{
        Write-Host -ForegroundColor Cyan "INFO - FUNCION: Comienza funcion de montaje de unidades del NAS..."
    }
    Process{
        do{
            $checkuds = 0 # Control que se activa a 1 cuando no ha podido encontrar las unidades y se reintenta el proceso
            $lista = Get-PSDrive | Where-Object DisplayRoot -like "\\$ipsmb\*"
            if (!$lista) {
                Try{
                    Write-host -ForegroundColor Yellow "[INFO] Instalando Unidades..."
                    foreach ($letra in $arrayletras){
                        Write-Host -ForegroundColor Yellow "[INFO] Montando: "$dict.$letra
                        New-PSDrive -Name $letra -PSProvider FileSystem -Root $dict.$letra -Persist -Credential $cred -ErrorAction Stop -Scope Global
                    }
                }Catch{
                    Write-Host -ForegroundColor Red "[ERROR] : $_ "
                    $checkuds = 1
                    Write-host -ForegroundColor Yellow "[INFO] Espere 5 segundos... Reintentar mapeo de unidades..."
                    Start-Sleep -Seconds 5
                }
            } else {
                Write-Host -ForegroundColor Blue "INFO: Hay unidades montadas... $lista"
            }
        } while ($checkuds -eq 1)
    }
    End{
        Write-Host -ForegroundColor Cyan "INFO - FUNCION: Terminada funcion de montaje de unidades del NAS..."
    }
}



# ... EJECUCION ...................................................................... #

if (!$cred){
    # Si no existen credenciales se crean para conectar todas las unidades
    $defaultUsername = "usuario_predeterminado"
    $mensajeCred = "Por favor, introduzca las credenciales para conectar las unidades de red"
    $cred = Get-Credential -Message $mensajeCred  -UserName $defaultUsername
}

Invoke-MontarUnidadesNAS -ipsmb $ipsmb -arrayletras $arrayletras -dict $dict -cred $cred
