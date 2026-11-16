# Recomputes the SHA-256 hashes in index.html's Content-Security-Policy after
# you edit the inline <script> or <style>. Works in Windows PowerShell 5.1 and PowerShell 7.
param([string]$Path = (Join-Path $PSScriptRoot '..\index.html'))

$Path = (Resolve-Path $Path).Path
$html = [IO.File]::ReadAllText($Path).Replace("`r`n", "`n")   # browsers hash LF-normalized text

function Get-B64Sha256([string]$s) {
  $sha = [Security.Cryptography.SHA256]::Create()
  [Convert]::ToBase64String($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($s)))
}

$js  = [regex]::Match($html, '(?s)<script>(.*?)</script>').Groups[1].Value
$css = [regex]::Match($html, '(?s)<style>(.*?)</style>').Groups[1].Value
if (-not $js -or -not $css) { throw "Couldn't find the inline <script> and <style> blocks in $Path" }

$csp = "default-src 'none'; script-src 'sha256-$(Get-B64Sha256 $js)'; style-src 'sha256-$(Get-B64Sha256 $css)'; " +
       "connect-src https://api.rach.io; img-src 'none'; base-uri 'none'; form-action 'none'; object-src 'none'"

$pattern = '<meta http-equiv="Content-Security-Policy" content="[^"]*">'
if (-not [regex]::IsMatch($html, $pattern)) { throw "No CSP <meta> tag found in $Path" }
$html = [regex]::Replace($html, $pattern, "<meta http-equiv=`"Content-Security-Policy`" content=`"$csp`">")

[IO.File]::WriteAllText($Path, $html, (New-Object Text.UTF8Encoding($false)))
Write-Host "CSP updated in $Path"
