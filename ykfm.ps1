Set-Alias ykcd yk-cd
Set-Alias ykfv yk-GoFav
Set-Alias ykbk yk-Back
Set-Alias ykfw yk-Forward
Set-Alias ykii yk-InvokeItem

# キーは拡張子
$file_profiles = @{
    pptx = @{ Icon = [char]0x26BE; Content = "powerpoint" }
    txt = @{ Icon = [char]0x2712; Content = "text" }
}

function yk-InvokeItem($item){
    $extention = ($item -split "\.")[-1]
    if($file_profiles.ContainsKey($extention)){
        switch($file_profiles[$extention].Content){
            powerpoint{
                $isnew = Read-Host "new?[y/]"
                if($isnew -eq "y"){
                    Start-Process -FilePath "C:\***\PowerPoint.exe" -ArgumentList "/N "+$item
                }else{
                    Invoke-Item $item
                }
            }
            text{
                $Sakura_or_VS = Read-Host "Sakura or VS?[S/V]"
                if($Sakura_or_VS -eq "S"){
                    Start-Process -FilePath "C:\***\SakuraEditor.exe" -ArgumentList ("-R " + $item)
                }elseif($Sakura_or_VS -eq "V"){
                    Start-Process -FilePath "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" -ArgumentList ( $item)
                }
            }
        }
    }else{
        Invoke-Item $item
    }
}

function yk-cd($path){
    # YaKitori cd
    Go-Dir $path
    Clear-Host #オプショナル
    $items = Get-ChildItem
    $folders = $items | Where-Object { $_.PSIsContainer } | Sort-Object Name
    $files   = $items | Where-Object { -not $_.PSIsContainer } | Sort-Object Name
    # アイコンを設定
    $file_icons=@()
    for($i=0;$i -lt $files.Count;$i++){
        $extention= ($files[$i] -split "\.")[-1]
        if($file_profiles.ContainsKey($extention)){
            $file_icons += $file_profiles[$extention].Icon
        }else{
            $file_icons+="  "
        }
    }
    Write-output $folders.Name
    for ($i = 0; $i -lt $files.Count; $i++) {
        Write-Output ($file_icons[$i] + $files[$i])
    }

    Write-Favorite
}

function yk-Back(){
    Back-Dir
    Clear-Host #オプショナル
    Get-ChildItem
    Write-Favorite
}

function yk-Forward(){
    Forward-Dir
    Clear-Host #オプショナル
    Get-ChildItem
    Write-Favorite
}

# キーはアクセス子
$favorites = @{
    s = @{ Title = "Source"; Path = "C:\Users\***\Documents\source" }
    e = @{ Title = "Env";    Path = "C:\Env\***v312" }
}

function Write-Favorite(){
    Write-Host "favorite: Source, Env"
}

function yk-GoFav($var){
    # Yakitori Favorite
    if ($favorites.ContainsKey($var)) {
        yk-cd $favorites[$var].Path
    } else {
        Write-Host "nothing found"
    }
}

############履歴管理###############
$global:backStack = @()
$global:forwardStack = @()

function Go-Dir($path) {
    if (Test-Path $path) {
        $global:backStack += (Get-Location)
        Set-Location $path
        $global:forwardStack = @()  # 進む履歴をクリア
    } else {
        Write-Host "Path not found: $path"
    }
}

function Back-Dir {
    if ($global:backStack.Count -gt 0) {
        $global:forwardStack += (Get-Location)
        Set-Location ($global:backStack[-1])
        $global:backStack = $global:backStack[0..($global:backStack.Count - 2)]
    } else {
        Write-Host "No back history"
    }
}

function Forward-Dir {
    if ($global:forwardStack.Count -gt 0) {
        $global:backStack += (Get-Location)
        Set-Location ($global:forwardStack[-1])
        $global:forwardStack = $global:forwardStack[0..($global:forwardStack.Count - 2)]
    } else {
        Write-Host "No forward history"
    }
}