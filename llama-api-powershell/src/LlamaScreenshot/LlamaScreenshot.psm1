function Save-Screenshot {
    param(
        [string]$Path = "Screenshot.png"
    )
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
    Write-Host "Screenshot saved to $Path"
}

function Save-ScreenshotRegion {
    param(
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [string]$Path = "ScreenshotRegion.png"
    )
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($X, $Y, 0, 0, [System.Drawing.Size]::new($Width, $Height))
    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
    Write-Host "Region screenshot saved to $Path"
}

function Save-ScreenshotAllMonitors {
    param(
        [string]$Path = "ScreenshotAllMonitors.png"
    )
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $screens = [System.Windows.Forms.Screen]::AllScreens
    $totalWidth = ($screens | Measure-Object -Property Bounds.Width -Sum).Sum
    $maxHeight = ($screens | Measure-Object -Property Bounds.Height -Maximum).Maximum
    $bitmap = New-Object System.Drawing.Bitmap $totalWidth, $maxHeight
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $offset = 0
    foreach ($screen in $screens) {
        $graphics.CopyFromScreen($screen.Bounds.Location, [System.Drawing.Point]::new($offset, 0), $screen.Bounds.Size)
        $offset += $screen.Bounds.Width
    }
    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
    Write-Host "All monitors screenshot saved to $Path"
}

function Start-ScreenshotScheduler {
    param(
        [int]$IntervalSeconds = 60,
        [string]$Folder = "Screenshots",
        [switch]$AllMonitors
    )
    if (!(Test-Path $Folder)) { New-Item -ItemType Directory -Path $Folder | Out-Null }
    while ($true) {
        $file = Join-Path $Folder ("ss_{0:yyyyMMdd_HHmmss}.png" -f (Get-Date))
        if ($AllMonitors) {
            Save-ScreenshotAllMonitors -Path $file
        } else {
            Save-Screenshot -Path $file
        }
        Start-Sleep -Seconds $IntervalSeconds
    }
}

Export-ModuleMember -Function Save-Screenshot, Save-ScreenshotRegion, Save-ScreenshotAllMonitors, Start-ScreenshotScheduler
