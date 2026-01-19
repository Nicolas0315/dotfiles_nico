param(
  [string]$DotfilesRoot = "$env:USERPROFILE\\dotfiles",
  [string]$ProjectsFile = "",
  [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectsFile)) {
  $ProjectsFile = Join-Path $DotfilesRoot "projects.txt"
}

$source = Join-Path $DotfilesRoot "AGENTS.md"
if (-not (Test-Path -Path $source)) {
  Write-Error "Source AGENTS.md not found: $source"
  exit 1
}

if (-not (Test-Path -Path $ProjectsFile)) {
  Write-Error "Projects file not found: $ProjectsFile"
  exit 1
}

$lines = Get-Content -Path $ProjectsFile
foreach ($rawLine in $lines) {
  $line = $rawLine.Trim()
  if ($line.Length -eq 0 -or $line.StartsWith("#")) {
    continue
  }

  $projectPath = $line
  if ($projectPath.StartsWith("~\\")) {
    $projectPath = Join-Path $HOME $projectPath.Substring(2)
  } elseif ($projectPath.StartsWith("~/")) {
    $projectPath = Join-Path $HOME $projectPath.Substring(2)
  }

  if (-not (Test-Path -Path $projectPath)) {
    Write-Warning "Missing project: $projectPath"
    continue
  }

  $target = Join-Path $projectPath "AGENTS.md"
  if (Test-Path -Path $target) {
    if ($Force) {
      $backup = "$target.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
      Move-Item -Path $target -Destination $backup
    } else {
      Write-Host "Skip existing: $target"
      continue
    }
  }

  try {
    New-Item -ItemType SymbolicLink -Path $target -Target $source -ErrorAction Stop | Out-Null
  } catch {
    New-Item -ItemType HardLink -Path $target -Target $source -ErrorAction Stop | Out-Null
  }

  Write-Host "Linked: $target -> $source"
}
