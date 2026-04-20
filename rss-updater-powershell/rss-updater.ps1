Param(
    [Parameter(Mandatory=$true)]
    [string]$file
)
##########################
### CHANGE THESE FIRST ###
##########################
$rssFile = "$pwd\feed.xml"
$author = "YOUR_AUTHOR_NAME_HERE"
$blogLink = "https://your.blog.link.here"


# check for file existence

if (-not (Test-Path $file)) {
    Write-Error "HTML file not found $file"
}

if (-not (Test-Path $rssFile)) {
    Write-Error "RSS file not found $rssFile"
}

$html = [System.IO.File]::ReadAllText((Resolve-Path $file))

$titleMatch = [regex]::Match($html, '(?is)<title[^>]*>(.*?)</title>')
$descMatch = [regex]::Match($html, '<description[^>]*>(.*?)</description>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::SingleLine)

if (-not $titleMatch.Success) {
    Write-Error "couldn't extract <title> from html file"
    exit 1
}

if (-not $descMatch.Success) {
    Write-Error "couldn't extract <description> from html file"
    exit 1
}

$feed = Get-Content $rssFile -Raw
$title = $titleMatch.Groups[1].Value.Trim()
$description = $descMatch.Groups[1].Value.Trim()
$fileName = [System.IO.Path]::GetFileName($file)
$link = "$blogLink/$fileName"
$pubDate = (Get-Item $file).LastWriteTimeUtc.ToString("ddd. dd MMM yyyy HH:mm:ss +0000")
$itemCount = ([regex]::Matches($feed, '<item>')).Count
$guid = "'$author'_$($itemCount + 1)"

# build new item with a heredoc like thing
$newItem = @"
<item>
    <title>$title</title>
    <description>$description</description>
    <link>$link</link>
    <guid isPermaLink="false">$guid</guid>
    <pubDate>$pubDate</pubDate>
</item>

"@

#insert new item into xml. handle whether this is an empty channel.

if ($feed -notmatch '</channel>') {
    Write-Error "Feed file has no </channel> tag, can't write to feed."
    exit 1
}

if ($feed -match '<item>') {
    $updatedFeed = ([regex]'<item>').Replace($feed, "$newItem <item>", 1)
} else {
    $updatedFeed = $feed -replace '</channel>', "$newItem</channel>"
}

# some rigmarole to make the thing tab correctly
$xmlDoc = [System.Xml.XmlDocument]$updatedFeed
$settings = [System.Xml.XmlWriterSettings]::new()
$settings.Indent = $true
$settings.IndentChars = '  '
$settings.Encoding = [System.Text.UTF8Encoding]::new($false) # no BOM, but UTF8
$writer = [System.Xml.XmlWriter]::Create($rssFile, $settings)
$xmlDoc.Save($writer)
$writer.Close()

Write-Host "Added '$title' to $rssFile"
