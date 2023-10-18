function Install-Font($fontName, $fontUrl) {
  $fontPath = "./fontInstall"

  # Tenta executar o script
  try {
    # cria diretório temporário
    New-Item -Path $fontPath -ItemType Directory -Force | Out-Null

    # Muda para o diretório temporário
    cd $fontPath

    # Baixa o arquivo zip da fonte para o diretório temporário
    $ZipFile = "./$fontName.zip"
    Invoke-WebRequest -Uri $fontUrl -OutFile $ZipFile

    # Extrai o arquivo zip para o diretório temporário
    Expand-Archive -Path $ZipFile -DestinationPath "./" -Force

    $ttfFiles = Get-ChildItem -Path "./" -Filter "*.ttf"

    # instala a fonte
    foreach ($ttfFile in $ttfFiles) {
      Invoke-Item -Path $ttfFile.FullName
    }

    # Sai do diretório temporário
    cd $fontPath

    # Exibe uma mensagem de sucesso
    Write-Host "A fonte $fontName foi instalada com sucesso." -ForegroundColor Green
  }
  catch {
    # Exibe uma mensagem de erro com os detalhes da exceção
    Write-Host "Ocorreu um erro ao instalar a fonte $fontName." -ForegroundColor Red
    Write-Host $_.Exception.Message
  }
  finally {
    # Remove o diretório temporário e o arquivo zip
    Remove-Item -Path $fontPath -Recurse -Force
  }
}

# Define o nome e a URL da fonte
# $FontName = "Roboto"
# $FontUrl = "https://fonts.google.com/download?family=Roboto"

$FontName = "FiraCode"
$FontUrl = "https://fonts.google.com/download?family=Fira+Code"

Install-Font -fontName "FiraCode" -fontUrl "https://fonts.google.com/download?family=Fira+Code"

