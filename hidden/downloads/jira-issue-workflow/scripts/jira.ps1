param(
  [ValidateSet('help','my-open','created','search','get','create')]
  [string]$Operation = 'help',
  [string]$Jql,
  [string]$Key,
  [string]$Summary,
  [string]$Description,
  [string]$Project,
  [string]$IssueType,
  [string]$Priority,
  [string]$Assignee,
  [string]$FixVersion,
  [string[]]$Labels,
  [ValidateRange(0,2147483647)] [int]$StartAt = 0,
  [ValidateRange(1,100)] [int]$MaxResults = 50,
  [string]$ConfigPath
)

$ErrorActionPreference = 'Stop'

if ($Operation -eq 'help') {
  [pscustomobject]@{
    Operations = @('my-open','created','search','get','create')
    Config = 'Private JSON path from -ConfigPath, JIRA_SKILL_CONFIG, or ~/.config/jira-issue-workflow/config.json'
    Token = 'Set JIRA_API_TOKEN in the running process environment'
    API = 'Jira REST API v2 on a compatible site'
  } | ConvertTo-Json -Depth 4
  return
}

if (-not $ConfigPath) { $ConfigPath = $env:JIRA_SKILL_CONFIG }
if (-not $ConfigPath) { $ConfigPath = Join-Path $HOME '.config/jira-issue-workflow/config.json' }
if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) { throw "Missing Jira configuration file: $ConfigPath. Start from config.example.json." }
$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
if (-not $config.site) { throw 'The Jira configuration needs a site URL.' }
$site = [string]$config.site
$uri = $null
if (-not [uri]::TryCreate($site,[UriKind]::Absolute,[ref]$uri)) { throw 'The Jira site URL is invalid.' }
if ($uri.Host -eq 'jira.example.com') { throw 'Replace the example Jira site before running a request.' }
if ($uri.Scheme -ne 'https' -and -not $uri.IsLoopback) { throw 'Use HTTPS for a remote Jira site.' }
if ($config.apiVersion -and [string]$config.apiVersion -ne '2') { throw 'This helper supports Jira REST API v2 only.' }
if (-not $env:JIRA_API_TOKEN) { throw 'Set JIRA_API_TOKEN in the running process environment.' }
$scheme = if ($config.authScheme) { [string]$config.authScheme } else { 'Bearer' }
$headers = @{ Accept='application/json'; 'Content-Type'='application/json' }
switch ($scheme) {
  'Bearer' { $headers.Authorization = "Bearer $($env:JIRA_API_TOKEN)" }
  'Basic' {
    if (-not $config.email) { throw 'Basic authentication needs email in the private Jira configuration.' }
    $pair = '{0}:{1}' -f $config.email,$env:JIRA_API_TOKEN
    $headers.Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($pair))
  }
  default { throw 'authScheme must be Bearer or Basic.' }
}
$base = $site.TrimEnd('/')

function Invoke-JiraGet([string]$path) {
  Invoke-RestMethod -Method Get -Uri "$base$path" -Headers $headers -TimeoutSec 30
}
function Invoke-JiraPost([string]$path,[object]$body) {
  $json = $body | ConvertTo-Json -Depth 16
  Invoke-RestMethod -Method Post -Uri "$base$path" -Headers $headers -Body $json -TimeoutSec 30
}
function Convert-Issue([object]$issue) {
  $created = if ($issue.fields.created) { ([datetime]$issue.fields.created).ToString('yyyy-MM-dd HH:mm') } else { $null }
  $updated = if ($issue.fields.updated) { ([datetime]$issue.fields.updated).ToString('yyyy-MM-dd HH:mm') } else { $null }
  [pscustomobject]@{
    Key=$issue.key
    Url="$base/browse/$($issue.key)"
    Summary=$issue.fields.summary
    Type=$issue.fields.issuetype.name
    Priority=$issue.fields.priority.name
    Status=$issue.fields.status.name
    Created=$created
    Updated=$updated
  }
}
function Search-Issues([string]$query) {
  $body = @{
    jql=$query; startAt=$StartAt; maxResults=$MaxResults
    fields=@('summary','status','priority','issuetype','created','updated')
  }
  $response = Invoke-JiraPost '/rest/api/2/search' $body
  [pscustomobject]@{
    Total=$response.total
    StartAt=$response.startAt
    Returned=@($response.issues).Count
    Issues=@($response.issues | ForEach-Object { Convert-Issue $_ })
  } | ConvertTo-Json -Depth 8
}

switch ($Operation) {
  'my-open' { Search-Issues 'assignee = currentUser() AND resolution = Unresolved ORDER BY updated DESC' }
  'created' { Search-Issues 'creator = currentUser() ORDER BY created DESC' }
  'search' {
    if (-not $Jql) { throw 'Search needs -Jql.' }
    Search-Issues $Jql
  }
  'get' {
    if (-not $Key) { throw 'Get needs -Key.' }
    $safeKey = [uri]::EscapeDataString($Key)
    $issue = Invoke-JiraGet "/rest/api/2/issue/$safeKey`?fields=summary,status,priority,issuetype,created,updated,fixVersions,labels,assignee,reporter,description"
    $row = Convert-Issue $issue
    $row | Add-Member -NotePropertyName Description -NotePropertyValue $issue.fields.description
    $row | Add-Member -NotePropertyName FixVersions -NotePropertyValue @($issue.fields.fixVersions | ForEach-Object { $_.name })
    $row | Add-Member -NotePropertyName Labels -NotePropertyValue @($issue.fields.labels)
    $row | Add-Member -NotePropertyName Assignee -NotePropertyValue $(if ($issue.fields.assignee) { $issue.fields.assignee.displayName } else { $null })
    $row | Add-Member -NotePropertyName Reporter -NotePropertyValue $(if ($issue.fields.reporter) { $issue.fields.reporter.displayName } else { $null })
    $row | ConvertTo-Json -Depth 10
  }
  'create' {
    if (-not $Project) { $Project = $config.defaults.project }
    if (-not $IssueType) { $IssueType = $config.defaults.issueType }
    if (-not $Priority) { $Priority = $config.defaults.priority }
    if (-not $Assignee) { $Assignee = $config.defaults.assignee }
    if (-not $FixVersion) { $FixVersion = $config.defaults.fixVersion }
    if (-not $Labels) { $Labels = @($config.defaults.labels | Where-Object { $_ }) }
    if (-not $Project -or -not $IssueType -or -not $Summary -or -not $Description) {
      throw 'Create needs project, issue type, summary, and description from arguments or private configuration.'
    }
    if ($Project -eq 'EXAMPLE') { throw 'Replace the example project before creating an issue.' }
    $fields = @{
      project=@{key=$Project}; issuetype=@{name=$IssueType}
      summary=$Summary; description=$Description
    }
    if ($Priority) { $fields.priority = @{name=$Priority} }
    if ($Assignee) { $fields.assignee = @{name=$Assignee} }
    if ($FixVersion) { $fields.fixVersions = @(@{name=$FixVersion}) }
    if (@($Labels).Count -gt 0) { $fields.labels = @($Labels) }
    $created = Invoke-JiraPost '/rest/api/2/issue' @{fields=$fields}
    $safeKey = [uri]::EscapeDataString([string]$created.key)
    $issue = Invoke-JiraGet "/rest/api/2/issue/$safeKey`?fields=summary,status,priority,issuetype,created,updated,fixVersions,labels,assignee,reporter"
    $row = Convert-Issue $issue
    $row | Add-Member -NotePropertyName FixVersions -NotePropertyValue @($issue.fields.fixVersions | ForEach-Object { $_.name })
    $row | Add-Member -NotePropertyName Labels -NotePropertyValue @($issue.fields.labels)
    $row | Add-Member -NotePropertyName Assignee -NotePropertyValue $(if ($issue.fields.assignee) { $issue.fields.assignee.displayName } else { $null })
    $row | Add-Member -NotePropertyName Reporter -NotePropertyValue $(if ($issue.fields.reporter) { $issue.fields.reporter.displayName } else { $null })
    $row | ConvertTo-Json -Depth 8
  }
}
