﻿# Storj3Monitor script by Krey
# this script gathers, aggregate displays and monitor all you node thresholds
# if uptime or audit down by [threshold] script send email to you
# https://github.com/Krey81/Storj

$v = "0.7.6"

# Changes:
# v0.0    - 20190828 Initial version, only displays data
# v0.1    - 20190904 
#           Add monitoring 
#               -   lost node connection
#               -   outdate storj version
#               -   new satellite
#               -   audit score
#               -   uptime score
#               -   Warrant canary
#           Add mail senders
#               -   for windows & linux internal powershell mail agent
#               -   for linux via bash -c "cat | mail"
# v0.2    - 20190904 
#               -   Remove [ref] for string buffer
#               -   Move config to external file
# v0.3    - 20190910
#               -   Add warning on new wallet
#               -   Fix usage examples in script
#               -   Fix config path search routines
#               -   Add testmail command
#               -   Add config examples
# v0.4    - 20190919                            - [5 bottles withdraw]
#               -   Changes due new api 0.21.1
#               -   Add node summary
#               -   Add satellite graphs
#               -   Add pips
#               -   Add delete counter
#               -   Add wellknown satellite names in script
#               -   Add wallknow node names (your nodes) in config (please check updated examples)
#               -   Add last ping (older last contact) formated like d:h:m:s
# v0.4.1   - 20190920
#               -   fix for "new satellite" mails, thanks LordMerlin
#               -   replace some in-script symbols and pseudographics symbols with byte array for workaround bad text editors, change encoding to UTF-8 with BOM, thanks underflow17
# v0.4.2   - 20191010
#               -   storj api changes
#               -   Totals
#               -   score counters month based
# v0.4.3   - 20191018
#               -   add per-node info (satellite data grouped by nodes) - ingress, egress, audit, uptime
#               -   change sat and node output order
#               -   extended output in canopy warning
#               -   misc
# v0.4.4   - 20191113
#               -   reorder columns in nodes summary, add disk used column
#               -   revised graph design
#               -   add egress and ingress cmdline params
#               -   traffic daily graph
# v0.4.5   - 20191114
#               -   fix int32 overwlow, fix div by zero 
# v0.5     - 20191115 (first anniversary version)
#               -   revised pips
#               -   powershell 5 (default in win10) compatibility
#               -   fix some bugs 
# v0.5.1   - 20191115
#               -   fix last ping issue from win nodes
#               -   add last ping monitoring, config value LastPingWarningMinutes, default 30
# v0.5.2   - 20191119
#               -   add -d param; -d only current day, -d -10 current-10 day, -d 3 last 3 days
#               -   send mail when last ping restored
# v0.5.3   - 20191120
#               -   add nodes count to timeline caption
# v0.5.4   - 20191121
#               -   group nodes by version in nodes summary
# v0.6.0   - 20191122
#               -   compare node version with version.storj.io
#                   -- Thanks "STORJ Russian Chat" members Sans Kokor to attention and Vladislav Solovei for suggestion.
# v0.6.1   - 20191126
#               -   Output disqualified field value in Comment
#               -   Mail when Comment changed
#               -   Max egress node show in footer
#               -   Max ingress and egress show below timeline graph
#               -   Fixes for windows powershell
#               -   html monospace mails
# v0.6.2   - 20191128
#               -   add statellite url
#               -   add total bandwidth to timeline footer
#               -   add averages to egress, ingress and bandwidth in timeline footer
#               -   add -node cmdline parameter for filter output to specific node
#               -   fix temp file not exists error
# v0.6.3   - 20191129
#               -   change output in nodes summary footer
#               -   fix max ingress value in nodes summary footer, thanks Sans Konor
# v0.6.4   - 20191130
#               -   move trafic summary down below satellite details
#               -   add vetting info in comment field
# v0.6.5   - 20191130
#               -   vetting info audit. totalCount replaced with successCount
#               -   fix Now to UtcNow date, bug on month boundary
# v0.6.6   - 20191204
#               -   fix comment monitoring cause mail storm
#               -   add MonitorFullComment option
#               -   fix mail text cliping in linux
#               -   show node name in mails instead of id
#               -   add HideNodeId config option
#               -   add satellite details to canopy warning
# v0.6.7   - 20191205
#               -   IMPORTANT - fix incorrect supressing graph lines (* N). Not only bottom lines was supressed before fix. Incorrect graphs.
#                   - thanks again to Sans Konor
#               -   Add repair graphs and counters
#               -   Add config option DisplayRepairOption, by default repairs show totals and "by days" graph
# v0.6.8   - 20191205
#               -   fix powershell 5.0 issues
# v0.6.9   - 20191205
#               -   zero base graphs by default
#               -   config option GraphStart [zero, minbandwidth]
# v0.7.0   - 20191213
#               -   parallel nodes quering
# v0.7.1   - 20191216
#               -   Top 5 vetting nodes
#               -   Fix Compat function not included in job scope
# v0.7.2   - 20191217
#               -   add vetting to sat details
#               -   add workaround to job awaiter for linux
#               -   add -np cmdline parameter to ommit parallel queries
#               -   small fixes
# v0.7.3   - 20200211
#               -   fix null call on new satellite, add saltlake satellite
#               -   remove deleted column
#               -   Uptime now meen uptime failed count. Enable uptime monitoring with UptimeThreashold=3 by default.
#               -   Add Runtime column (display count of hours from node start)
# v0.7.4   - 20200214
#               -   Fix Windows powershell compatibility issues
# v0.7.5   - 20200228
#               -   Fix UptimeFail counter calculation (previous version multiplied by 100 because before it was a percentage)
#               -   Change default UptimeThreashold from 10 to 3
#               -   Output sum of uptime failed in node stats
#               -   Short headers from UptimeFail to UptimeF
# v0.7.6   - 20200305
#               -   fix monitor issue when offline nodes replaced with last online in monitor loop
#               -   add "node back online" notice
#               -   add "node updated" notice (for work with new Storj3Updater script)

#TODO-Drink-and-cheers
#               -   Early bird (1-bottle first), greatings for all versions of this script
#               -   Big thanks (10-bottles first), greatings for all versions of this script
#               -   Telegram bot (100-bottles, sum), development telegram bot to send messages
#               -   The service (1000-bottles, sum), full time service for current and past functions on my dedicated servers
#               -   The world's fist bottle-based crypto-currency (1M [1kk for Russians], sum). You and I will create the world's first cryptocurrency, which is really worth something.

#TODO
#               -   MQTT
#               -   SVG graphics
#               -   Script autoupdating

#USAGE          !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
#RUN
#   Display only with default config: one node on 127.0.0.1:14002, no monitoring and mail
#       pwsh ./Storj3Monitor.ps1
#
#
#   Display only for specefied nodes
#       pwsh ./Storj3Monitor.ps1 -c <config-file> [ingress|egress] [-node name] [-np]
#
#
#      Where 
#           ingress     - only ingress traffic
#           egress      - only egress traffic
#           node        - filter output to that node
#           np          - no parallel execution
#   
#   Test config and mail sender
#       pwsh ./Storj3Monitor.ps1 -c <config-file> testmail
#
#
#   Monitor and mail
#       pwsh ./Storj3Monitor.ps1 -c <config-file> monitor
#
#
#   Dump default config to stdout
#       pwsh ./Storj3Monitor.ps1 example
#       also see config examples on github 
#
#   Full installation
#       1. Create config, specify all nodes and mailer configuration. Examples on github.
#       2. Create systemd service specify path to this script and configuration. Examples on github.
#

$repairOptionValues = @(
    "none", 
    "totals", 
    "traffic", 
    "sat"
)

$graphStartOptionValues = @(
    "zero", 
    "minbandwidth"
)

$code = @'
using System;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace InProcess
{
    public class InMemoryJob : System.Management.Automation.Job
    {
        private static int _InMemoryJobNumber = 0;
        private PowerShell _PowerShell;
        private bool _IsDisposed = false;
        private IAsyncResult _AsyncResult = null;

        public override bool HasMoreData 
        {
            get 
            {
                return (Output.Count > 0);
            }
        }
        public override string Location 
        {
            get
            {
                return "In Process";
            }
        }
        public override string StatusMessage
        {
            get
            {
                return String.Empty;
            }
        }

        public InMemoryJob(PowerShell powerShell, string name)
        {
            _PowerShell = powerShell;
            Init(name);
        }
        private void Init(string name)
        {
            int id = System.Threading.Interlocked.Add(ref _InMemoryJobNumber, 1);

            if (!string.IsNullOrEmpty(name)) Name = name;
            else Name = "InProcessJob" + id;

            _PowerShell.Streams.Information = Information;
            _PowerShell.Streams.Progress = Progress;
            _PowerShell.Streams.Verbose = Verbose;
            _PowerShell.Streams.Error = Error;
            _PowerShell.Streams.Debug = Debug;
            _PowerShell.Streams.Warning = Warning;
            _PowerShell.Runspace.AvailabilityChanged += new EventHandler<RunspaceAvailabilityEventArgs>(Runspace_AvailabilityChanged);
        }

        void Runspace_AvailabilityChanged(object sender, RunspaceAvailabilityEventArgs e)
        {
            if (e.RunspaceAvailability == RunspaceAvailability.Available) SetJobState(JobState.Completed);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing && !_IsDisposed)
            {
                _IsDisposed = true;
                try
                {
                    if (!IsFinishedState()) StopJob();
                    foreach (Job job in ChildJobs) job.Dispose();
                }
                finally { base.Dispose(disposing); }
            }
        }

        public bool IsFinishedState()
        {
           return (JobStateInfo.State == JobState.Completed || JobStateInfo.State == JobState.Failed || JobStateInfo.State == JobState.Stopped);
        }

        public void Start()
        {
            _AsyncResult = _PowerShell.BeginInvoke<PSObject, PSObject>(null, Output);
            SetJobState(JobState.Running);
        }

        public override void StopJob()
        {
            _PowerShell.Stop();
            _PowerShell.EndInvoke(_AsyncResult);
            SetJobState(JobState.Stopped);
        }

        public bool WaitJob(TimeSpan timeout)
        {
            return _AsyncResult.AsyncWaitHandle.WaitOne(timeout);
        }
    }
}
'@
Add-Type -TypeDefinition $code
function Start-QueryNode
{
  [CmdletBinding()]
  param
  (
    $Name,
    [scriptblock] $InitializationScript,
    $Address,
    $Config,
    $Query
  )
  $PowerShell = [PowerShell]::Create().AddScript($InitializationScript)
  $PowerShell.Invoke()
  $PowerShell.AddCommand("QueryNode").AddParameter("address", $Address).AddParameter("config", $Config).AddParameter("query", $Query) | Out-Null
  $MemoryJob = New-Object InProcess.InMemoryJob $PowerShell, $Name
  $MemoryJob.Start()
  $MemoryJob
}
function StartWebRequest
{
  [CmdletBinding()]
  param
  (
    $Name,
    $Address,
    $Timeout
  )
  $PowerShell = [PowerShell]::Create().AddScript("(Invoke-WebRequest -Uri $address -TimeoutSec $timeout).Content | ConvertFrom-Json").AddParameter("address", $Address).AddParameter("timeout", $Timeout)
  $MemoryJob = New-Object InProcess.InMemoryJob $PowerShell, $Name
  $MemoryJob.Start()
  $MemoryJob
}

function CheckRepairDisplay{
    param($config, $where)
    return ($repairOptionValues.IndexOf($config.DisplayRepairOption) -ge $repairOptionValues.IndexOf($where))
}
    
function IsAnniversaryVersion {
    param($vstr)
    $standardBootleVolumeLitters = 0.5
    $vstr = [String]::Join(".", ($vstr.Split('.') | Select-Object -First 2) )
    $vdec = [Decimal]::Parse($vstr, [CultureInfo]::InvariantCulture)
    if (($vdec % $standardBootleVolumeLitters) -eq 0.0) { return $true }
    else { return $false }
}

 function Preamble{
    Write-Host ""
    Write-Host -NoNewline ("Storj3Monitor script by Krey ver {0}" -f $v)
    if (IsAnniversaryVersion($v)) { Write-Host -ForegroundColor Green "`t- Anniversary version: Astrologers proclaim the week of incredible bottled income" }
    else { Write-Host }
    Write-Host "mail-to: krey@irinium.ru"
    Write-Host ""
    Write-Host -ForegroundColor Yellow "I work on beer. If you like my scripts please donate bottle of beer in STORJ or ETH to 0x7df3157909face2dd972019d590adba65d83b1d8"
    Write-Host -ForegroundColor Gray "Why should I send bootles if everything works like that ?"
    Write-Host -ForegroundColor Gray "... see TODO comments in the script body"
    Write-Host ""
    Write-Host "Thanks Sans Kokor for bug hunting"
    Write-Host "Thanks underflow17"
    Write-Host ""
}

function GetFullPath($file)
{
    # full path
    if ([System.IO.File]::Exists($file)) { return $file }

    # full path fixed
    $file2 = [System.IO.Path]::GetFullPath($file)
    if ([System.IO.File]::Exists($file2)) { return $file2 }    

    #current dir
    $file3 = [System.IO.Path]::Combine(((Get-Location).Path), $file)
    if ([System.IO.File]::Exists($file3)) { return $file3 }
    
    # from script path
    $scriptPath = ((Get-Variable MyInvocation -Scope 2).Value).InvocationName | Split-Path -Parent
    $file4 = [System.IO.Path]::Combine($scriptPath, $file)
    if ([System.IO.File]::Exists($file4)) { return $file4 }

    return $null
}

function DefaultConfig{
    $config = @{
        Nodes = "127.0.0.1:14002"
        WaitSeconds = 300
        Threshold = 0.2
        MonitorFullComment = $false
        HideNodeId = $false
        DisplayRepairOption = "traffic"
        GraphStart = "zero"
        Mail = @{
            MailAgent = "none"
        }
    }
    return $config
}

function LoadConfig{
    param ($cmdlineArgs)
    $idx = $cmdlineArgs.IndexOf("-c")
    

    if ($idx -lt 0 -or ($cmdlineArgs.Length -le ($idx + 1)) ) {
        Write-Host -ForegroundColor Red "Please specify config file"
        Write-Host "Example: Storj3Monitor.ps1 -c Storj3Monitor.conf"

        Write-Host
        Write-Host -ForegroundColor Red "No config was specified. Use defaults."
        Write-Host "Run 'Storj3Monitor.ps1 example' to retrieve default config"
        $config = DefaultConfig        
    }
    else {
        $argfile = $cmdlineArgs[$idx + 1]
        $file = GetFullPath -file $argfile
        if ([String]::IsNullOrEmpty($file) -or (-not [System.IO.File]::Exists($file))) {
            Write-Host -ForegroundColor Red ("config file {0} not found" -f $argfile)
            return $false
        }
        
        $config = Get-Content -Path $file | ConvertFrom-Json
    }

    $config | Add-Member -NotePropertyName StartTime -NotePropertyValue ([System.DateTimeOffset]::Now)
    $config | Add-Member -NotePropertyName Canary -NotePropertyValue $null
    
    if ($null -eq $config.LastPingWarningMinutes) { 
        $config | Add-Member -NotePropertyName LastPingWarningMinutes -NotePropertyValue 30
    }

    if ($null -eq $config.MonitorFullComment) { 
        $config | Add-Member -NotePropertyName MonitorFullComment -NotePropertyValue $false
    }

    if ($null -eq $config.HideNodeId) { 
        $config | Add-Member -NotePropertyName HideNodeId -NotePropertyValue $false
    }

    if ($null -eq $config.DisplayRepairOption) { 
        $config | Add-Member -NotePropertyName DisplayRepairOption -NotePropertyValue "traffic"
    }
    elseif ($repairOptionValues -notcontains $config.DisplayRepairOption) {
        throw ("Bad DisplayRepairOption value in config")
    }

    if ($null -eq $config.GraphStart) { 
        $config | Add-Member -NotePropertyName GraphStart -NotePropertyValue "zero"
    }
    elseif ($graphStartOptionValues -notcontains $config.GraphStart) {
        throw ("Bad GraphStart value in config")
    }

    if ($null -eq $config.UptimeThreshold) { 
        $config | Add-Member -NotePropertyName UptimeThreshold -NotePropertyValue 3
    }

    return $config
}

function GetJson
{
    param($uri, $timeout)

    #RAW
    # ((Invoke-WebRequest -Uri http://192.168.157.2:14002/api/dashboard).content | ConvertFrom-Json).data
    # ((Invoke-WebRequest -Uri http://192.168.157.2:14002/api/satellite/118UWpMCHzs6CvSgWd9BfFVjw5K9pZbJjkfZJexMtSkmKxvvAW).content | ConvertFrom-Json).data

    $resp = Invoke-WebRequest -Uri $uri -TimeoutSec $timeout
    if ($resp.StatusCode -ne 200) { throw $resp.StatusDescription }
    $json = ConvertFrom-Json $resp.Content
    if (-not [System.String]::IsNullOrEmpty($json.Error)) { throw $json.Error }
    else { $json = $json.data }
    return $json
}

# For powershell v5 compatibility
function FixDateSat {
    param($sat)
    for ($i=0; $i -lt $sat.bandwidthDaily.Length; $i++) {
        $sat.bandwidthDaily[$i].intervalStart = [DateTimeOffset]$sat.bandwidthDaily[$i].intervalStart
    }
}

function FixNode {
    param($node)
    try {
        if ($node.lastPinged.GetType().Name -eq "String") { $node.lastPinged = [DateTimeOffset]::Parse($node.lastPinged)}
        elseif ($node.lastPinged.GetType().Name -eq "DateTime") { $node.lastPinged = [DateTimeOffset]$node.lastPinged }
        
        if ($node.lastPinged -gt [DateTimeOffset]::Now) { $node.lastPinged = [DateTimeOffset]::Now }

        if ($node.startedAt.GetType().Name -eq "DateTime") { $node.startedAt = [DateTimeOffset]$node.startedAt }
    }
    catch { Write-Host -ForegroundColor Red $_.Exception.Message }
}

function FilterBandwidth {
    param ($bw, $query)
    if ($null -eq $query.Days) { return $bw }
    elseif ($query.Days -le 0) {
        $is = ($bw[$bw.Count - 1 + $query.Days]).IntervalStart
        return $bw | Where-Object { ($_.IntervalStart.Year -eq $is.Year) -and ($_.IntervalStart.Month -eq $is.Month) -and ($_.IntervalStart.Day -eq $is.Day) }
    }
    elseif ($query.Days -gt 0) {
        $is = ($bw[$bw.Count - 1]).IntervalStart
        $from = ($bw[$bw.Count - $query.Days]).IntervalStart.Day
        $to = $is.Day
        return $bw | Where-Object { 
            ($_.IntervalStart.Year -eq $is.Year) -and 
            ($_.IntervalStart.Month -eq $is.Month) -and 
            ($_.IntervalStart.Day -ge $from) -and
            ($_.IntervalStart.Day -le $to)
        }
    }
}

function GetNodeName{
    param ($config, $id)
    $name = ($config.WellKnownNodes | Select-Object -ExpandProperty $id)
    if ([String]::IsNullOrEmpty($name)) { $name = Compact($id) }
    elseif (-not $config.HideNodeId) {$name+= " (" + (Compact($id)) + ")"}
    return $name
}

function GetSatName{
    param ($config, $id, $url)

    $wellKnownSat = @{
        "118UWpMCHzs6CvSgWd9BfFVjw5K9pZbJjkfZJexMtSkmKxvvAW" = "stefan-benten";
        "12EayRS2V1kEsWESU9QMRseFhdxYxKicsiFmxrsLZHeLUtdps3S" = "us-central-1";
        "121RTSDpyNZVcEU84Ticf2L1ntiuUimbWgfATz21tuvgk3vzoA6" = "asia-east-1";
        "12L9ZFwhzVpuEKMUNUqkaTLGzwY9G24tbiigLiXpmZWKwmcNDDs" = "europe-west-1"
        "1wFTAgs9DP5RSnCqKV1eLf6N9wtk4EAtmN5DpSxcs8EjT69tGE"  = "saltlake"
    }
    
    $name = $wellKnownSat[$id] 
    if (($null -eq $name) -and ($null -ne $url)) {
        $point = $url.IndexOf(":")
        if ($point -gt 0) { $name = $url.Substring(0, $point) }
    }
    
    if ($null -eq $name) { $name = Compact($id) }
    elseif (-not $config.HideNodeId) {$name+= " (" + (Compact($id)) + ")"}
    Write-Output $name
}

function GetJobResultNormal {
    param ([System.Collections.Generic.List[[InProcess.InMemoryJob]]] $waitList, $timeoutSec)

    $start = [System.DateTimeOffset]::Now
    while (($waitList.Count -gt 0) -and (([System.DateTimeOffset]::Now - $start).TotalSeconds -le $timeoutSec)) {
        $completed = $waitList | Where-Object { $_.IsFinishedState() }
        $completed | ForEach-Object {
            if ($_.Error.Count -gt 0 ) { Write-Error $_.Error[0] }
            elseif( $_.Output.Count -eq 1 ) { Write-Output $_.Output[0] }
            else { Write-Error ("Bad output from {0}" -f $_.Name) }
            $waitList.Remove($_) | Out-Null
        }
    }
    if ($waitList.Count -gt 0) { Write-Error "Some jobs hang" }
}

function GetJobResultFailSafe {
    param ([System.Collections.Generic.List[[InProcess.InMemoryJob]]] $waitList, $timeoutSec)
    
    $start = [System.DateTimeOffset]::Now
    $timeoutTry =  [TimeSpan]::FromSeconds(([double]$timeoutSec) / $waitList.Count) 
    
    while (($waitList.Count -gt 0) -and (([System.DateTimeOffset]::Now - $start).TotalSeconds -le $timeoutSec)) {
        for($i=$waitList.Count-1; $i -ge 0; $i--)
        {
            $job = $waitList[$i]
            if ($job.WaitJob($timeoutTry)) {
                $waitList.Remove($job) | Out-Null
                if ($job.Error.Count -gt 0 ) { Write-Error $job.Error[0] -ErrorAction Continue }
                elseif( $job.Output.Count -eq 1 ) { Write-Output $job.Output[0] }
                else { Write-Error ("Bad output from {0}" -f $_.Name) -ErrorAction Continue }
            }
        }
    }
    if ($waitList.Count -gt 0) { Write-Error "Some jobs hang" }
}

#Debug 
#$t = QueryNode -address "51.89.68.95:4416" -config $config -query $query
function QueryNode
{
    param($address, $config, $query)
    $timeoutSec = 30

    try {
        if ($null -eq $config) {Write-Error "Bad config in QueryNode"}
        $dash = GetJson -uri ("http://{0}/api/dashboard" -f $address) -timeout $timeoutSec

        $name = GetNodeName -config $config -id $dash.nodeID
        if ($null -ne $query.Node) {
            if (-not ($name -match $query.Node)) { return }
        }

        FixNode($dash)
        $dash | Add-Member -NotePropertyName Address -NotePropertyValue $address
        $dash | Add-Member -NotePropertyName Name -NotePropertyValue $name
        $dash | Add-Member -NotePropertyName Sat -NotePropertyValue ([System.Collections.Generic.List[PSCustomObject]]@())
        $dash | Add-Member -NotePropertyName BwSummary -NotePropertyValue $null
        $dash | Add-Member -NotePropertyName Audit -NotePropertyValue $null
        $dash | Add-Member -NotePropertyName Uptime -NotePropertyValue $null
        $dash | Add-Member -NotePropertyName LastPingWarningValue -NotePropertyValue 0
        $dash | Add-Member -NotePropertyName LastVersion -NotePropertyValue $null
        $dash | Add-Member -NotePropertyName MinimalVersion -NotePropertyValue $null
        $dash | Add-Member -NotePropertyName LastVerWarningValue -NotePropertyValue $null

        $satResult = [System.Collections.Generic.List[PSCustomObject]]@()

        if ($query.Parallel) {
            $waitList = New-Object System.Collections.Generic.List[[InProcess.InMemoryJob]]
            $dash.satellites | ForEach-Object {
                $satid = $_.id
                $job = StartWebRequest -Name "SatQueryJob" -Address ("http://{0}/api/satellite/{1}" -f $address, $satid) -Timeout $timeoutSec
                $waitList.Add($job)
            }
            GetJobResultFailSafe -waitList $waitList -timeoutSec $timeoutSec | ForEach-Object { $satResult.Add($_.data) }
        }
        else {
            $dash.satellites | ForEach-Object {
                $satid = $_.id
                try 
                {
                    Write-Host -NoNewline ("query {0}..." -f $address)
                    $sat = GetJson -uri ("http://{0}/api/satellite/{1}" -f $address, $satid) -timeout $timeoutSec
                    $satResult.Add($sat)
                    Write-Host "completed"
                }
                catch {
                    WriteError ($_.Exception.Message)
                }
            }
        }

        $satResult | ForEach-Object {
            $sat = $_
            $dashSat = $dash.satellites | Where-Object { $_.id -eq $sat.id }
            if ($sat.bandwidthDaily.Length -gt 0) {
                if ($sat.bandwidthDaily[0].intervalStart.GetType().Name -eq "String") { FixDateSat -sat $sat }
                elseif ($sat.bandwidthDaily[0].intervalStart.GetType().Name -eq "DateTime") { FixDateSat -sat $sat }
                $sat.bandwidthDaily = FilterBandwidth -bw $sat.bandwidthDaily -query $query
            }
            $sat | Add-Member -NotePropertyName Url -NotePropertyValue ($dashSat.url)
            $sat | Add-Member -NotePropertyName Name -NotePropertyValue (GetSatName -config $config -id $sat.id -url $sat.url)
            $sat | Add-Member -NotePropertyName NodeName -NotePropertyValue $name
            $sat | Add-Member -NotePropertyName Dq -NotePropertyValue ($dashSat.disqualified)
            $dash.Sat.Add($sat)
        }

        $dash.PSObject.Properties.Remove('satellites')            
    }
    catch {
        Write-Error ("Node on address {0} fail: {1}" -f $address, $_.Exception.Message )
    }
    Write-Output $dash
}

$init = 
[scriptblock]::Create(@"
function GetJson {$function:GetJson}
function Compact {$function:Compact}
function GetNodeName {$function:GetNodeName}
function GetSatName {$function:GetSatName}
function FixNode {$function:FixNode}
function FixDateSat {$function:FixDateSat}
function FilterBandwidth {$function:FilterBandwidth}
function GetJobResultNormal {$function:GetJobResultNormal}
function GetJobResultFailSafe {$function:GetJobResultFailSafe}
function StartWebRequest {$function:StartWebRequest}
function QueryNode {$function:QueryNode}
"@)

function GetNodes
{
    param ($config, $query)
    $timeoutSec = 30
    $result = [System.Collections.Generic.List[PSCustomObject]]@()
    
    #Start get storj services versions
    $jobVersion = StartWebRequest -Name "StorjVersionQuery" -Address "https://version.storj.io" -Timeout $timeoutSec

    if ($query.Parallel) {
        $waitList = New-Object System.Collections.Generic.List[[InProcess.InMemoryJob]]
        $config.Nodes | ForEach-Object {
            $address = $_
            $jobNode = Start-QueryNode -Name ("JobQueryNode[{0}]" -f $address) -InitializationScript $init -Address $address -Config $config -Query $query 
            $waitList.Add($jobNode)
        }
        GetJobResultFailSafe -waitList $waitList -timeoutSec $timeoutSec | ForEach-Object { $result.Add($_)}
    }
    else {
        $config.Nodes | ForEach-Object {
            $address = $_
            $dash = QueryNode -address $address -config $config -query $query
            $result.Add($dash)
        }
    }
    
    $jobVersion.WaitJob([TimeSpan]::FromSeconds(1)) | Out-Null
    if (-not $jobVersion.IsFinishedState()) { Write-Error "jobVersion hang" }
    elseif ($jobVersion.Error.Count -gt 0) { Write-Error $jobVersion.Error }
    elseif ($jobVersion.Output.Count -ne 1) { Write-Error "Bad output from jobVersion" }
    else {
        $satVer = $jobVersion.Output[0]
        $latest = $satVer.processes.storagenode.suggested.version
        $minimal = [String]::Join('.',  $satVer.Storagenode.major.ToString(), $satVer.Storagenode.minor.ToString(), $satVer.Storagenode.patch.ToString())
        $time = ($jobVersion.PSEndTime - $jobVersion.PSEndTime).TotalMilliseconds
        Write-Host ("Latest storagenode version is {0}, query time {1}ms" -f $latest, $time)
        $result | ForEach-Object { 
            $_.LastVersion = $latest 
            $_.MinimalVersion = $minimal 
        }
    }
    return $result.ToArray()
}

function AggBandwidth
{
    [CmdletBinding()]
    Param(
          [Parameter(ValueFromPipeline)]
          $item
         )    
    begin {
        [long]$ingress = 0
        [long]$egress = 0
        [long]$delete = 0
        [long]$repairIngress = 0
        [long]$repairEgress = 0
        $from = $null
        $to = $null
    }
    process {
        $ingress+=$item.ingress.usage
        $egress+= $item.egress.usage
        $delete+= $item.delete
        $repairIngress+=$item.ingress.repair
        $repairEgress+=$item.egress.repair

        if ($null -eq $from) { $from = $item.intervalStart}
        elseif ($item.intervalStart -lt $from) { $from = $item.intervalStart}

        if ($null -eq $to) { $to = $item.intervalStart}
        elseif ($item.intervalStart -gt $to) { $to = $item.intervalStart}
    }
    end {
        $p = @{
            'Ingress'  = $ingress
            'Egress'   = $egress
            'TotalBandwidth'= $ingress + $egress
            'MaxBandwidth'= [Math]::Max($ingress, $egress)
            'Delete'   = $delete
            'RepairIngress' = $repairIngress
            'RepairEgress' = $repairEgress
            'MaxRepairBandwidth'= [Math]::Max($repairIngress, $repairEgress)
            'From'     = $from
            'To'       = $to
        }
        Write-Output (New-Object -TypeName PSCustomObject –Prop $p)
    }
}

function ConvertRepair
{
    [CmdletBinding()]
    Param(
          [Parameter(ValueFromPipeline)]
          $item
    )
    process {
        $p = @{
            'Ingress'  = $item.RepairIngress
            'Egress'   = $item.RepairEgress
            'TotalBandwidth'= $item.RepairIngress + $item.RepairEgress
            'MaxBandwidth'= $item.MaxRepairBandwidth
            'From'     = $item.From
            'To'       = $item.To
        }
        Write-Output (New-Object -TypeName PSCustomObject –Prop $p)
    }
}

function AggBandwidth2
{
    [CmdletBinding()]
    Param(
          [Parameter(ValueFromPipeline)]
          $item
         )    
    begin {
        $ingress = 0
        $ingressMax = 0
        $egress = 0
        $egressMax = 0
        $delete = 0
        $deleteMax = 0
        $repairEgress = 0
        $repairIngress = 0
        $from = $null
        $to = $null
    }
    process {
        $ingress+=$item.Ingress
        if ($item.Ingress -gt $ingressMax) { $ingressMax = $item.Ingress }
        
        $egress+= $item.Egress
        if ($item.Egress -gt $egressMax) { $egressMax = $item.Egress }

        $delete+= $item.Delete
        if ($item.Delete -gt $deleteMax) { $deleteMax = $item.Delete }

        $repairEgress+=$item.RepairEgress
        $repairIngress+=$item.RepairIngress

        if ($null -eq $from) { $from = $item.From}
        elseif ($item.From -lt $from) { $from = $item.From}

        if ($null -eq $to) { $to = $item.To}
        elseif ($item.To -gt $to) { $to = $item.To}
    }
    end {
        $p = @{
            'Ingress'       = $ingress
            'IngressMax'    = $ingressMax
            'Egress'        = $egress
            'EgressMax'     = $egressMax
            'Delete'        = $delete
            'DeleteMax'     = $deleteMax
            'RepairEgress'  = $repairEgress
            'RepairIngress' = $repairIngress
            'Bandwidth'     = $ingress + $egress
            'From'          = $from
            'To'            = $to
        }
        Write-Output (New-Object -TypeName PSCustomObject –Prop $p)
    }
}

function GetScore
{
    param($nodes)

    $score = $nodes | Sort-Object nodeID | ForEach-Object {
        $node = $_
        $node.Sat | Sort-Object id | ForEach-Object {
            $sat = $_
            $commentMonitored = @()
            if ($null -ne $sat.Dq) { $commentMonitored += ("disqualified {0}" -f $sat.Dq) }

            $comment = @()
            if ($sat.audit.successCount -lt 100) { $comment += ("vetting {0}" -f $sat.audit.successCount) }
    
            New-Object PSCustomObject -Property @{
                Key = ("{0}-{1}" -f $node.nodeID, $sat.id)
                NodeId = $node.nodeID
                NodeName = $node.Name
                SatelliteId = $sat.id
                SatelliteName = $sat.Name
                Audit = $sat.audit.score
                Uptime = ($sat.uptime.totalCount - $sat.uptime.successCount)
                Bandwidth = ($sat.bandwidthDaily | AggBandwidth)
                CommentMonitored = [String]::Join("; ", $commentMonitored)
                Comment = [String]::Join("; ", $comment)
            }
        }
    }

    #calc per node bandwidth
    $score | Group-Object NodeId | ForEach-Object {
        $nodeId = $_.Name
        $node = $nodes | Where-Object {$_.NodeId -eq $nodeId} | Select-Object -First 1
        $node.BwSummary = ($_.Group | Select-Object -ExpandProperty Bandwidth | AggBandwidth2)
        $node.Audit = ($_.Group | Select-Object -ExpandProperty Audit | Measure-Object -Min).Minimum
        $node.Uptime = ($_.Group | Select-Object -ExpandProperty Uptime | Measure-Object -Sum).Sum
    }

    $score
}

function Compact
{
    param($id)
    return $id.Substring(0,4) + "-" + $id.Substring($id.Length-2)
}

function Round
{
    param($value)
    return [Math]::Round($value * 100, 2)
}

function HumanBytes {
    param ([int64]$bytes)
    $suff = "bytes", "KiB", "MiB", "GiB", "TiB", "PiB"
    $level = 0
    $rest = [double]$bytes
    while ([Math]::Abs($rest/1024) -ge 1) {
        $level++
        $rest = $rest/1024
    }
    #if ($rest -lt 0.001) { return [String]::Empty }
    if ($rest -lt 0.001) { return "0" }
    $mant = [Math]::Max(3 - [Math]::Floor($rest).ToString().Length,0)
    return ("{0} {1}" -f [Math]::Round($rest,$mant), $suff[$level])
}

function HumanTime {
    param ([TimeSpan]$time)
    $str = ("{0:00}:{1:00}:{2:00}:{3:00}" -f $time.Days, $time.Hours, $time.Minutes, $time.Seconds)
    while ($str.StartsWith("00:")) { $str = $str.TrimStart("00:") }
    return $str
}

function CheckNodes{
    param(
        $config, 
        $body,
        $newNodes,
        [ref]$oldNodesRef
    )
    $oldNodes = $oldNodesRef.Value

    #DEBUG drop some satellites and reset update
    #$newNodes = $newNodes | Select-Object -First 2
    #$newNodes[1].upToDate = $false

    # Check absent nodes
    $failNodes = ($oldNodes | Where-Object { ($newNodes | Select-Object -ExpandProperty nodeID) -notcontains $_.nodeID })
    if ($failNodes.Count -gt 0) {
        $failNodes | ForEach-Object {
            $nodeName = (GetNodeName -id $_.nodeID -config $config)
            Write-Output ("Disconnected from node {0}" -f $nodeName) | Tee-Object -Append -FilePath $body
        }
    }

    ;
    # Check versions
    $oldVersion = ($newNodes | Where-Object {-not $_.upToDate})
    if ($oldVersion.Count -gt 0) {
        $oldVersion | ForEach-Object {
            $testNode = $_
            $oldVersionStatus = $oldNodes | Where-Object { $_.nodeID -eq $testNode.nodeID } | Select-Object -First 1 -ExpandProperty upToDate
            if ($oldVersionStatus) {
                Write-Output ("Node {0} is outdated ({1}.{2}.{3})" -f $testNode.nodeID, $testNode.version.major, $testNode.version.minor, $testNode.version.patch) | Tee-Object -Append -FilePath $body
            }
        }
    }
    
    # Check new wallets
    $oldWal = $oldNodes | Select-Object -ExpandProperty wallet -Unique
    $newWal = $newNodes | Select-Object -ExpandProperty wallet -Unique | Where-Object {$oldWal -notcontains $_ }
    if ($newWal.Count -gt 0) {
        $newWal | ForEach-Object {
            Write-Output ("!WARNING! NEW WALLET {0}" -f $_) | Tee-Object -Append -FilePath $body
        }
    }


    # Check new satellites
    $oldSat = $oldNodes.satellites | Select-Object -ExpandProperty id -Unique

    #DEBUG drop some satellites
    #$oldSat = $oldSat | Sort-Object | Select-Object -First 2

    $newSat = $newNodes.satellites | Select-Object -ExpandProperty id -Unique | Where-Object {$oldSat -notcontains $_ }
    if ($newSat.Count -gt 0) {
        $newSat | ForEach-Object {
            Write-Output ("New satellite {0}" -f $_) | Tee-Object -Append -FilePath $body
        }
    }

    #DEBUG
    #$newNodes[0].lastPinged = [System.DateTimeOffset]::Now - [TimeSpan]::FromMinutes(55)

    #Check last ping
    $newNodes | ForEach-Object {
        #restore old values
        $id = $_.nodeID
        $old = $oldNodes | Where-Object {$_.nodeID -eq $id } | Select-Object -First 1
        if ($null -eq $old) { 
            Write-Output ("Node {0} back online" -f $_.Name) | Tee-Object -Append -FilePath $body
            return 
        }
        $_.LastPingWarningValue = $old.LastPingWarningValue 
        $_.LastVerWarningValue = $old.LastVerWarningValue

        $lostMin = [int](([DateTimeOffset]::Now - $_.lastPinged).TotalMinutes)
        if (($_.LastPingWarningValue -eq 0) -and ($lostMin -ge $config.LastPingWarningMinutes)) {
            Write-Output ("Node {0} last ping greater than {1} minutes" -f $_.Name, $lostMin) | Tee-Object -Append -FilePath $body
            $_.LastPingWarningValue = $lostMin
        }
        elseif (($_.LastPingWarningValue -ge $config.LastPingWarningMinutes) -and ($lostMin -lt $config.LastPingWarningMinutes)) {
            $_.LastPingWarningValue = 0
            Write-Output ("Node {0} last ping back to normal ({1} minutes)" -f $_.Name, $lostMin) | Tee-Object -Append -FilePath $body
        }

        if ($null -ne $_.LastVersion) {
            if ($_.version -ne $_.LastVersion) {
                if ($_.LastVerWarningValue -ne $_.LastVersion) {
                    Write-Output ("Node {0} version {1} may be updated to {2}" -f $_.Name, $_.version, $_.LastVersion ) | Tee-Object -Append -FilePath $body
                    $_.LastVerWarningValue = $_.LastVersion
                }
            }
        }

        if ($_.version -ne $old.version) {
            Write-Output ("Node {0} updated from {1} to {2}" -f $_.Name, $old.version, $_.version) | Tee-Object -Append -FilePath $body
        }
    }
    $oldNodesRef.Value = $newNodes
}

function CheckScore{
    param(
        $config, 
        $body,
        $oldScore,
        $newScore
    )

    #DEBUG drop scores
    #$newScore[0].Audit = 0.2
    #$newScore[3].Uptime = 0.6

    $newScore | ForEach-Object {
        $new = $_
        $old = $oldScore | Where-Object { $_.Key -eq $new.Key }
        if ($null -ne $old){
            $idx = $oldScore.IndexOf($old)
            if ($old.Audit -ge ($new.Audit + $config.Threshold)) {
                Write-Output ("Node {0} down audit from {1} to {2} on {3}" -f $new.NodeName, $old.Audit, $new.Audit, $new.SatelliteId) | Tee-Object -Append -FilePath $body
                $oldScore[$idx].Audit = $new.Audit
            }
            elseif ($new.Audit -gt $old.Audit) { $oldScore[$idx].Audit = $new.Audit }

            if (($old.Uptime + $config.UptimeThreshold) -lt $new.Uptime) {
                Write-Output ("Node {0} fail uptime checks. Old value {1}, new {2} on {3}" -f $new.NodeName, $old.Uptime, $new.Uptime, $new.SatelliteId) | Tee-Object -Append -FilePath $body
                $oldScore[$idx].Uptime = $new.Uptime
            }

            if ($old.CommentMonitored -ne $new.CommentMonitored) {
                Write-Output ("Node {0} update comment for {1} to {2}. Old was {3}" -f $new.NodeName, $new.SatelliteName, $new.CommentMonitored, $old.CommentMonitored) | Tee-Object -Append -FilePath $body
                $oldScore[$idx].CommentMonitored = $new.CommentMonitored
            }

            if ($config.MonitorFullComment -and ($old.Comment -ne $new.Comment)) {
                Write-Output ("Node {0} update comment for {1} to {2}. Old was {3}" -f $new.NodeName, $new.SatelliteName, $new.Comment, $old.Comment) | Tee-Object -Append -FilePath $body
                $oldScore[$idx].Comment = $new.Comment
            }
        }
    }
}


function ExecCommand {
    param ($path, $params, [switch]$out)

    $content = $null
    if ($out) { 
    $temp = [System.IO.Path]::GetTempFileName()
    #Write-Host ("Exec {0} {1}" -f $path, $params)
    #Write-Host ("Output redirected to {0}" -f $temp)
    $proc = Start-Process -FilePath $path -ArgumentList $params -RedirectStandardOutput $temp -Wait -PassThru
    #Write-Host done
	$content = Get-Content -Path $temp
	[System.IO.File]::Delete($temp)
	if ($proc.ExitCode -ne 0) { throw $content }
	else { return $content }
    }
    else { 
	$proc = Start-Process -FilePath $path -ArgumentList $params -Wait -PassThru
	if ($proc.ExitCode -ne 0) { return $false }
	else { return $true }
    }
}

function SendMailLinux{
    param(
        $config, 
        $body
    )

    try {
        $header = $body + "_header"
        if (-not [System.IO.File]::Exists($header))
        {
            $sb = New-Object System.Text.StringBuilder
            $sb.AppendLine("<html>") | Out-Null
            $sb.AppendLine("<body>") | Out-Null
            $sb.AppendLine("<pre style='font: monospace; white-space: pre;'>") | Out-Null
            [System.IO.File]::WriteAllText($header, $sb.ToString())
        }

        $footer = $body + "_footer"
        if (-not [System.IO.File]::Exists($footer))
        {
            $sb = New-Object System.Text.StringBuilder
            $sb.AppendLine("</pre>") | Out-Null
            $sb.AppendLine("</body>") | Out-Null
            $sb.AppendLine("</html>") | Out-Null
            [System.IO.File]::WriteAllText($footer, $sb.ToString())
        }
        
        $catParam = "'{0}' '{1}' {2}" -f $header, $body, $footer
        $mailParam = "--mime --content-type text/html -s '{0}' {1}" -f $config.Mail.Subj, $config.Mail.To
        $bashParam = ('-c "cat {0} | mail {1}"' -f $catParam, $mailParam)
        $output = ExecCommand -path $config.Mail.Path -params $bashParam -out

        Write-Host ("Mail sent to {0} via linux agent" -f $config.Mail.To)
        if ($output.Length -gt 0) { Write-Host $output }
    }
    catch {
        Write-Host -ForegroundColor Red ($_.Exception.Message)        
    }
}

function GetMailBody {
    param($body)
    $sb = New-Object System.Text.StringBuilder
    $sb.AppendLine("<html>") | Out-Null
    $sb.AppendLine("<body>") | Out-Null
    $sb.AppendLine("<pre style='font: monospace; white-space: pre;'>") | Out-Null
    $sb.AppendLine([System.IO.File]::ReadAllText($body)) | Out-Null
    $sb.AppendLine("</pre>") | Out-Null
    $sb.AppendLine("</body>") | Out-Null
    $sb.AppendLine("</html>") | Out-Null
    return $sb.ToString()
}
function SendMailPowershell{
    param(
        $config, 
        $body
    )
    try {
        $pd = $config.Mail.AuthPass | ConvertTo-SecureString -asPlainText -Force

        if ([String]::IsNullOrEmpty($config.Mail.AuthUser)) { $user = $config.Mail.From }
        else { $user = $config.Mail.AuthUser }

        $credential = New-Object System.Management.Automation.PSCredential($user, $pd)

        $ssl = $true
        if ($config.Mail.Port -eq 25) { $ssl = $false }

        try {
            Send-MailMessage  `
                -To ($config.Mail.To) `
                -From ($config.Mail.From) `
                -Subject ($config.Mail.Subj) `
                -Body (GetMailBody -body $body) `
                -BodyAsHtml `
                -Encoding utf8 `
                -UseSsl: $ssl `
                -SmtpServer ($config.Mail.Smtp) `
                -Port ($config.Mail.Port) `
                -Credential $credential `
                -ErrorAction Stop 
                
            
            Write-Host ("Mail sent to {0} via powershell agent" -f $config.Mail.To)
        }
        catch 
        {

            if ($config.Mail.From -match "gmail.com") { $msg = ("google is bad mail sender. try other service: {0}" -f $_.Exception.Message) }
            else { $msg = ("Bad mail sender or something wrong in mail config: {0}" -f $_.Exception.Message) }
            throw $msg
        }
    }
    catch {
        Write-Host -ForegroundColor Red ($_.Exception.Message)
    }

}

#SendMail -config $config -sb (sb)
function SendMail{
    param(
        $config, 
        $body
    )

    if ($config.Mail.MailAgent -eq "powershell") { SendMailPowershell -config $config -body $body }
    elseif ($config.Mail.MailAgent -eq "linux") { SendMailLinux -config $config -body $body }
    else {
        Write-Host -ForegroundColor Red "Mail not properly configuried"
    }
}

function Monitor {
    param (
        $config, 
        $body, 
        $oldNodes,
        $oldScore
    )

    #DEBUG canopy
    #$config.Canary = [System.DateTimeOffset]::Now.Subtract([System.TimeSpan]::FromDays(1))

    while ($true) {
        Start-Sleep -Seconds $config.WaitSeconds
        $newNodes = GetNodes -config $config
        $newScore = GetScore -nodes $newNodes
        CheckNodes -config $config -body $body -newNodes $newNodes -oldNodesRef ([ref]$oldNodes)
        CheckScore -config $config -body $body -oldScore $oldScore -newScore $newScore

        # Canopy warning
        #DEBUG check hour, must be 10
        if (($null -eq $config.Canary) -or ([System.DateTimeOffset]::Now.Day -ne $config.Canary.Day -and [System.DateTimeOffset]::Now.Hour -ge 10)) {
            $config.Canary = [System.DateTimeOffset]::Now
            Write-Output ("storj3monitor is alive {0}" -f $config.Canary) | Tee-Object -Append -FilePath $body
            $bwsummary = ($newNodes | Select-Object -ExpandProperty BwSummary | AggBandwidth2)
            DisplayScore -score $newScore -bwsummary $bwsummary >> $body
            DisplayNodes -nodes $newNodes -bwsummary $bwsummary -config $config >> $body
        }
        if (([System.IO.File]::Exists($body)) -and (Get-Item -Path $body).Length -gt 0)
        {
            SendMail -config $config -body $body
            Clear-Content -Path $body
        }
    }
    Write-Host "Stop monitoring"
}

function GetPips {
    param ($width, [int64]$max, [int64]$current, [int64]$maxg = $null)

    if ($max -gt 0) { $val = $current/$max }
    else { $val = 0 }
    $pips = [int]($width * $val )
    $pipsg = 0

    if (($null -ne $maxg) -and ($maxg -gt 0)) {
        $valg = $current/$maxg
        $pipsg = [int]($width * $valg)
        $str = "[" + "".PadRight($pips, "=").PadRight($pipsg, "-").PadRight($width, " ") + "] "
    }
    else {
        $str = "[" + "".PadRight($pips, "-").PadRight($width, " ") + "] "
    }

    return $str
}

function DisplayPips {
    param($width, $bandwidth, $name)
}

function CompareVersion {
    param ($v1, $v2)
    try {
        $v1int = $v1.Split('.') | ForEach-Object {[int]$_}
        $v2int = $v2.Split('.') | ForEach-Object {[int]$_}
        for ($i = 0; $i -lt ([Math]::Min($v1int.Length, $v2int.Length)); $i++ ) {
            if ($v1int[$i] -gt $v2int[$i]) { return 1 }
            elseif ($v1int[$i] -lt $v2int[$i]) { return -1 }
        }
        if ($v1int.Length -gt $v2int.Length) { return 1}
        elseif ($v2int.Length -gt $v1int.Length) { return -1}
        else { return 0 }
    }
    catch {return 0}
}

function DisplayNodes {
    param ($nodes, $bwsummary, $config)
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "N O D E S    S U M M A R Y"

    if ($null -eq $bwsummary) {
        $bwsummary = ($nodes | Select-Object -ExpandProperty BwSummary | AggBandwidth2)
    }

    $used = ($nodes.diskspace.used | Measure-Object -Sum).Sum
    $avail = ($nodes.diskspace.available | Measure-Object -Sum).Sum
    $latest = $nodes | Where-Object {$null -ne $_.LastVersion } | Select-Object -ExpandProperty LastVersion -First 1
    $minimal = $nodes | Where-Object {$null -ne $_.MinimalVersion } | Select-Object -ExpandProperty MinimalVersion -First 1

    $nodes | Group-Object Version | ForEach-Object {
        Write-Host -NoNewline ("storagenode version {0}" -f $_.Name)
        if ($null -ne $latest) {
            if ((CompareVersion -v1 $minimal -v2 $latest) -gt 0) { 
                Write-Host -ForegroundColor Red (" (Something wrong in satellite. Oldest version {0} greater than latest version {1})" -f $minimal, $latest)
            }
            elseif ( ($_.Name -eq $latest) -or ((CompareVersion -v1 $_.Name -v2 $latest) -eq 0)) { 
                Write-Host -ForegroundColor Green " (latest)" 
            }
            elseif ((CompareVersion -v1 $_.Name -v2 $latest) -gt 0) { 
                Write-Host (" (Something wrong in my algorythm or satellite. Node version greater than latest {0})" -f $latest)
            }
            elseif ((CompareVersion -v1 $_.Name -v2 $minimal) -ge 0) { 
                Write-Host -ForegroundColor Yellow (" (not latest but still actual between {0} and {1})" -f $minimal, $latest) 
            }
            elseif ((CompareVersion -v1 $_.Name -v2 $minimal) -lt 0) { 
                Write-Host -ForegroundColor Red (" (obsolete! min {0} max {1} please update quickly)" -f $minimal, $latest) 
            }
        else { Write-Host -ForegroundColor Red "Something wrong in version check" }
        }
        else { Write-Host }

        $_.Group | Sort-Object Name | Format-Table -AutoSize `
        @{n="Node"; e={$_.Name}}, `
        @{n="Runtime"; e={[int](([DateTimeOffset]::Now - [DateTimeOffset]$_.startedAt).TotalHours)}}, `
        @{n="Ping"; e={HumanTime([DateTimeOffset]::Now - $_.lastPinged)}}, `
        @{n="Audit"; e={Round($_.Audit)}}, `
        @{n="UptimeF"; e={$_.Uptime}}, `
        @{n="[ Used  "; e={HumanBytes($_.diskSpace.used)}}, `
        @{n="Disk                  "; e={("{0}" -f ((GetPips -width 20 -max $_.diskSpace.available -current $_.diskSpace.used)))}}, `
        @{n="Free ]"; e={HumanBytes(($_.diskSpace.available - $_.diskSpace.used))}}, `
        @{n="Egress"; e={("{0} ({1})" -f ((GetPips -width 10 -max $bwsummary.Egress -maxg $bwsummary.EgressMax -current $_.BwSummary.Egress)), (HumanBytes($_.BwSummary.Egress)))}}, `
        @{n="Ingress"; e={("{0} ({1})" -f ((GetPips -width 10 -max $bwsummary.Ingress -maxg $bwsummary.IngressMax -current $_.BwSummary.Ingress)), (HumanBytes($_.BwSummary.Ingress)))}}, `
#        @{n="Delete"; e={("{0} ({1})" -f ((GetPips -width 10 -max $bwsummary.Delete -maxg $bwsummary.DeleteMax -current $_.BwSummary.Delete)), (HumanBytes($_.BwSummary.Delete)))}}, `
        @{n="[ Bandwidth"; e={("{0}" -f ((GetPips -width 10 -max $_.bandwidth.available -current $_.bandwidth.used)))}}, `
        @{n="Free ]"; e={HumanBytes(($_.bandwidth.available - $_.bandwidth.used))}} `
        | Out-String -Width 200
    }

    $vetting = $nodes | Select-Object -ExpandProperty Sat `
    | Where-Object { $_.audit.totalCount -lt 100 } `
    | Sort-Object -Descending {$_.audit.totalCount} `
    | Select-Object @{ Name = 'Audit count';  Expression =  { $_.audit.totalCount }}, @{ Name = 'Node'; Expression = { $_.NodeName }}, @{ Name = 'on Sat'; Expression = { $_.Name }}

    if ($vetting.Count -gt 0) {
        $top = $vetting | Select-Object -First 5
        Write-Output ("Top {0} of {1} vettings:" -f $top.Count, $vetting.Count)
        $top | Format-Table
    }

    Write-Output ("Stat time {0:yyyy.MM.dd HH:mm:ss (UTCzzz)}" -f [DateTimeOffset]::Now)

    $today = $nodes | Select-Object -ExpandProperty Sat | Select-Object -ExpandProperty bandwidthDaily | Where-Object {$_.intervalStart.UtcDateTime.Date -eq [DateTimeOffset]::UtcNow.UtcDateTime.Date} | AggBandwidth 
    Write-Output ("Today bandwidth {0} - {1} Egress, {2} Ingress" -f 
        (HumanBytes($today.Egress + $today.Ingress)), 
        (HumanBytes($today.Egress)), 
        (HumanBytes($today.Ingress))
        #,(HumanBytes($today.Delete))
    )

    Write-Output ("Total bandwidth {0} - {1} Egress, {2} Ingress" -f 
    (HumanBytes($bwsummary.Egress + $bwsummary.Ingress)), 
    (HumanBytes($bwsummary.Egress)), 
    (HumanBytes($bwsummary.Ingress))
    #,(HumanBytes($bwsummary.Delete))
    )

    if (CheckRepairDisplay -config $config -where "totals") {
        Write-Output ("Total repair {0} Egress, {1} Ingress" -f 
            (HumanBytes($bwsummary.RepairEgress)), 
            (HumanBytes($bwsummary.RepairIngress))
        )
    }

    Write-Output ("Total storage {0}; used {1}; available {2}" -f (HumanBytes($avail)), (HumanBytes($used)), (HumanBytes($avail-$used)))

    Write-Output ("from {0:yyyy.MM.dd} to {1:yyyy.MM.dd} on {2} nodes" -f 
        $bwsummary.From, 
        $bwsummary.To, 
        $nodes.Count
    )

    $maxEgress = $nodes | Sort-Object -Descending {$_.BwSummary.Egress} | Select-Object -First 1
    Write-Output ("- Max egress {0} at {1}" -f (HumanBytes($maxEgress.BwSummary.Egress)), $maxEgress.Name)

    $maxIngress = $nodes | Sort-Object -Descending {$_.BwSummary.Ingress} | Select-Object -First 1
    Write-Output ("- Max ingress {0} at {1}" -f (HumanBytes($maxIngress.BwSummary.Ingress)), $maxIngress.Name)

    $maxBandwidth = $nodes | Sort-Object -Descending {$_.BwSummary.Bandwidth} | Select-Object -First 1
    Write-Output ("- Max bandwidth {0} at {1}" -f (HumanBytes($maxBandwidth.BwSummary.Bandwidth)), $maxBandwidth.Name)
}

function DisplayScore {
    param ($score, $bwsummary)

    Write-Host
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "S A T E L L I T E S    D E T A I L S"

    $tab = [System.Collections.Generic.List[PSCustomObject]]@()
    $score | Sort-Object SatelliteId, NodeName | ForEach-Object {

        $comment = @() 
        if (-not [String]::IsNullOrEmpty($_.CommentMonitored)) { $comment += $_.CommentMonitored}
        if (-not [String]::IsNullOrEmpty($_.Comment)) { $comment += $_.Comment}

        $p = @{
            'Satellite' = $_.SatelliteName
            'Node'      = $_.NodeName
            'Ingress'   = ("{0} {1}" -f (GetPips -width 10 -max $bwsummary.Ingress -maxg $bwsummary.IngressMax -current $_.Bandwidth.Ingress), (HumanBytes($_.Bandwidth.Ingress)))
            'Egress'    = ("{0} {1}" -f (GetPips -width 10 -max $bwsummary.Egress -maxg $bwsummary.EgressMax -current $_.Bandwidth.Egress), (HumanBytes($_.Bandwidth.Egress)))
#            'Delete'    = ("{0} {1}" -f (GetPips -width 10 -max $bwsummary.Delete -maxg $bwsummary.DeleteMax -current $_.Bandwidth.Delete), (HumanBytes($_.Bandwidth.Delete)))
            'Audit'     = Round($_.Audit)
            'UptimeF'= $_.Uptime
            'Comment'   = "- " + [String]::Join("; ", $comment)
        }
        $tab.Add((New-Object -TypeName PSCustomObject –Prop $p))
    }
    $tab.GetEnumerator() | Format-Table -AutoSize Satellite, Node, Ingress, Egress, Audit, UptimeF, Comment | Out-String -Width 200

    Write-Host
}

function GraphTimelineDirect
{
    param ($title, $decription, [int]$height, $bandwidth, $query, $nodesCount, $config)
    $bd = $bandwidth | Group-Object {$_.intervalStart.Day}
    $timeline = New-Object "System.Collections.Generic.SortedList[int, PSCustomObject]"
    $bd | ForEach-Object { $timeline.Add([Int]::Parse($_.Name), ($_.Group | AggBandwidth)) }
    GraphTimeline -title $title -decription $decription -height $height -timeline $timeline -query $query -nodesCount $nodesCount -config $config
}

function GraphTimelineRepair
{
    param ($title, $decription, [int]$height, $bandwidth, $query, $nodesCount, $config)
    $bd = $bandwidth | Group-Object {$_.intervalStart.Day}
    $timeline = New-Object "System.Collections.Generic.SortedList[int, PSCustomObject]"
    $bd | ForEach-Object { $timeline.Add([Int]::Parse($_.Name), ($_.Group | AggBandwidth | ConvertRepair)) }
    GraphTimeline -title $title -decription $decription -height $height -timeline $timeline -query $query -nodesCount $nodesCount -config $config
}

function GraphTimeline
{
    param ($title, $decription, [int]$height, $timeline, $query, $nodesCount, $config)
    if ($height -eq 0) { $height = 10 }

    #max in groups while min in original data. otherwise min was zero in empty data cells
    $firstCol = ($timeline.Keys | Measure-Object -Minimum).Minimum
    $lastCol = ($timeline.Keys | Measure-Object -Maximum).Maximum
    
    #data bounds
    if ($config.GraphStart -eq "zero") {$dataMin = 0}
    elseif ($config.GraphStart -eq "minbandwidth") {
        $dataMin = ($timeline.Values | Measure-Object -Minimum -Property MaxBandwidth).Minimum
    }
    else {throw "Bad graph start config value"}
    $dataMax = ($timeline.Values | Measure-Object -Maximum -Property MaxBandwidth).Maximum

    if (($null -eq $dataMax) -or ($dataMax -eq 0)) { 
        Write-Host -ForegroundColor Red ("{0}: no traffic data" -f $title)
        return
    }
    elseif ($dataMax -eq $dataMin) { $rowWidth = $dataMax / $height}
    else { $rowWidth = ($dataMax - $dataMin) / $height }

    $graph = New-Object System.Collections.Generic.List[string]

    #workaround for bad text editors
    $pseudoGraphicsSymbols = [System.Text.Encoding]::UTF8.GetString(([byte]226, 148,148,226,148,130,45,226,148,128))
    if ($pseudoGraphicsSymbols.Length -ne 4) { throw "Error with pseudoGraphicsSymbols" }
    $sb = New-Object System.Text.StringBuilder(1)
    $firstCol..$lastCol | ForEach-Object { 
        $sb.Append(("{0:00} " -f $_)) | Out-Null
    } 
    $graph.Add(" " + $sb.ToString())
    $graph.Add($pseudoGraphicsSymbols[0].ToString().PadRight($lastCol*3 + 1, $pseudoGraphicsSymbols[3]))

    $fill1 = "   "
    $fill2 = $pseudoGraphicsSymbols[2] + $pseudoGraphicsSymbols[2] + " "

    $skip = 0
    $first = $null
    $line = $null
    1..$height | ForEach-Object {
        $r = $_
        $line = $pseudoGraphicsSymbols[1]
        $firstCol..$lastCol | ForEach-Object {
            $c = $_
            $agg = $timeline[$c]
            $h = ($agg.MaxBandwidth - $dataMin) / $rowWidth
            if ($h -ge $r ) {
                $hi = ($agg.Ingress - $dataMin) / $rowWidth
                $he = ($agg.Egress - $dataMin) / $rowWidth
                if (-not ($query.Ingress -xor $query.Egress)) {
                    if (($hi -ge $r) -and ($he -ge $r)) { $line+="ie " }
                    elseif ($hi -ge $r) { $line+="i  " }
                    elseif ($he -ge $r) { $line+=" e " }
                }
                else {
                    if (($query.Ingress -and $hi -ge $r) -or ($query.Egress -and $he -ge $r)) { $line+=$fill2 }
                    else {$line+=$fill1}
                }
            }
            else {$line+=$fill1}
        }
        
        if ($null -eq $first) { 
            $graph.Add($line) 
            #allow skips only for full month
            if ($null -eq $query.Days) { $first = $line }
        }
        elseif ($null -ne $first)
        {
            if ($line -eq $first) { $skip++ }
            else {
                $graph.Add($line)
                $first = "xxx"
            }
        }
    }
    if ($skip -gt 0) { $graph[1] = $graph[1] + " * " + $skip.ToString() }
    $graph.Reverse()


    Write-Host $title -NoNewline -ForegroundColor Yellow
    if (-not [String]::IsNullOrEmpty($decription)) {Write-Host (" - {0}" -f $decription) -ForegroundColor Gray -NoNewline}
    Write-Host
    Write-Host ("Y-axis from {0} to {1}; cell = {2}; {3} nodes" -f (HumanBytes($dataMin)), (HumanBytes($dataMax)), (HumanBytes($rowWidth)), $nodesCount) -ForegroundColor Gray
    $graph | ForEach-Object {Write-Host $_}

    $maxEgress = $timeline.Values | Sort-Object -Descending {$_.Egress} | Select-Object -First 1
    $avgEgress = ($timeline.Values | Measure-Object -Average Egress).Average
    Write-Host (" - egress max {0} ({1:yyyy-MM-dd}), average {2}" -f `
        (HumanBytes($maxEgress.Egress)), `
        $maxEgress.To, `
        (HumanBytes($avgEgress)))

    $maxIngress = $timeline.Values | Sort-Object -Descending {$_.Ingress} | Select-Object -First 1
    $avgIngress = ($timeline.Values | Measure-Object -Average Ingress).Average
    Write-Host (" - ingress max {0} ({1:yyyy-MM-dd}), average {2}" -f `
        (HumanBytes($maxIngress.Ingress)), `
        $maxIngress.To, `
        (HumanBytes($avgIngress)))

    $maxBandwidth = $timeline.Values | Sort-Object -Descending {$_.TotalBandwidth} | Select-Object -First 1
    $avgBandwidth = ($timeline.Values | Measure-Object -Average TotalBandwidth).Average
    Write-Host (" - bandwidth max {0} ({1:yyyy-MM-dd}), average {2}" -f `
        (HumanBytes($maxBandwidth.TotalBandwidth)), `
        $maxBandwidth.To, `
        (HumanBytes($avgBandwidth)))

    $totalEgress = ($timeline.Values | Measure-Object -Sum Egress).Sum
    $totalIngress = ($timeline.Values | Measure-Object -Sum Ingress).Sum
    Write-Host (" - bandwidth total {0} egress, {1} ingress" -f (HumanBytes($totalEgress)), (HumanBytes($totalIngress)))
    
    Write-Host
    Write-Host
}

function DisplaySat {
    param ($nodes, $bw, $query, $config)
    Write-Host
    Write-Host -ForegroundColor Yellow -BackgroundColor Black "S A T E L L I T E S   B A N D W I D T H"
    Write-Host "Legenda:"
    Write-Host "`ti `t-ingress"
    Write-Host "`te `t-egress"
    Write-Host "`t= `t-pips from all bandwidth"
    Write-Host "`t- `t-pips from bandwidth of maximum node, or simple percent line"
    Write-Host "`t* n `t-down line supressed n times"
    Write-Host
    $now = [System.DateTimeOffset]::UtcNow
    ($nodes | Select-Object -ExpandProperty Sat) | Group-Object id | ForEach-Object {
        #Write-Host $_.Name
        $sat = $_
        $bw = $sat.Group | Select-Object -ExpandProperty bandwidthDaily | Where-Object { ($_.IntervalStart.Year -eq $now.Year) -and ($_.IntervalStart.Month -eq $now.Month)}
        $title = ("{0} ({1})" -f  $sat.Group[0].Url, $sat.Name)
        if (CheckRepairDisplay -config $config -where "sat") {
            GraphTimelineRepair -title ('Repair ' + $title) -bandwidth $bw -query $query -nodesCount $nodes.Count -config $config
        }
        GraphTimelineDirect -title $title -bandwidth $bw -query $query -nodesCount $nodes.Count -config $config

        $vetting = $sat.Group `
        | Where-Object { $_.audit.totalCount -lt 100 } `
        | Sort-Object -Descending {$_.audit.totalCount} `
        | Select-Object @{ Name = 'Audit count';  Expression =  { $_.audit.totalCount }}, @{ Name = 'Node'; Expression = { $_.NodeName }}
    
        if ($vetting.Count -gt 0) {
            $top = $vetting | Select-Object -First 5
            Write-Output ("Top {0} of {1} vetting nodes:" -f $top.Count, $vetting.Count)
            $top | Format-Table
        }
    
    }
    Write-Host
}
function DisplayTraffic {
    param ($nodes, $query, $config)
    $bw = $nodes | Select-Object -ExpandProperty Sat | Select-Object -ExpandProperty bandwidthDaily
    if (CheckRepairDisplay -config $config -where "traffic") {
        GraphTimelineRepair -title "Repair by days" -height 15 -bandwidth $bw -query $query -nodesCount $nodes.Count -config $config
    }
    GraphTimelineDirect -title "Traffic by days" -height 15 -bandwidth $bw -query $query -nodesCount $nodes.Count -config $config
    

}

function GetQuery {
    param($cmdlineArgs)

    $days = $null
    $index = $cmdlineArgs.IndexOf("-d")
    if ($index -ge 0) {
        if (($cmdlineArgs.Count -ge $index + 1) -and [System.Int32]::TryParse($cmdlineArgs[$index + 1], [ref]$days)) {
            if ($days -eq 0) { Write-Host "Query today" }
            elseif ($days -lt 0) { Write-Host ("Query today {0}" -f $days) }
            elseif ($days -gt 0) { Write-Host ("Query {0} last days" -f $days) }
        }
        else {
            $days = 0
            Write-Host "Query today"
        }
    }

    $node = $null
    $index = $cmdlineArgs.IndexOf("-node")
    if ($index -ge 0) { $node = $cmdlineArgs[$index + 1] }

    if ($cmdlineArgs.IndexOf("-np") -ge 0) { $parallel = $false }
    else { $parallel = $true }

    $query = @{
        Ingress = $cmdlineArgs.Contains("ingress")
        Egress = $cmdlineArgs.Contains("egress")
        Days = $days
        Node = $node
        StartData = [System.DateTimeOffset]::Now
        EndData = $null
        Parallel = $parallel
    }
    return $query
}

Preamble
if ($args.Contains("example")) {
    $config = DefaultConfig
    $config | ConvertTo-Json
    return
}

$config = LoadConfig -cmdlineArgs $args
#DEBUG
#$config = LoadConfig -cmdlineArgs "-c", ".\ConfigSamples\Storj3Monitor.Krey.conf"

if (-not $config) { return }

$query = GetQuery -cmdlineArgs $args
$nodes = GetNodes -config $config -query $query
$score = GetScore -nodes $nodes
$bwsummary = ($nodes | Select-Object -ExpandProperty BwSummary | AggBandwidth2)
$query.EndData = [DateTimeOffset]::Now
;
#DEBUG    
if ($args.Contains("monitor")) {
    $body = [System.IO.Path]::GetTempFileName()
    Write-Output ("Start monitoring {0} entries at {1}, {2} seconds cycle" -f $score.Count, $config.StartTime, $config.WaitSeconds) | Tee-Object -FilePath $body
    Write-Host ("Output to {0}" -f $body)

    Monitor -config $config -body $body -oldNodes $nodes -oldScore $score
    [System.IO.File]::Delete($body)
}
elseif ($args.Contains("testmail")) {
    $body = [System.IO.Path]::GetTempFileName()
    Write-Output ("Test mail. Configured {0} entries" -f $score.Count) | Tee-Object -FilePath $body
    SendMail -config $config -body $body
    [System.IO.File]::Delete($body)
}
elseif ($nodes.Count -gt 0) {
    if ($null -eq $query.Days -or $query.Days -gt 0) {
        DisplaySat -nodes $nodes -query $query -config $config
        DisplayScore -score $score -bwsummary $bwsummary
        DisplayTraffic -nodes $nodes -query $query -config $config
    }
    else 
    {
        DisplayScore -score $score -bwsummary $bwsummary
    }
    DisplayNodes -nodes $nodes -bwsummary $bwsummary -config $config
    Write-Host ("Data collect time {0}s" -f ($query.EndData - $query.StartData).TotalSeconds)
}

#DEBUG
#cd C:\Projects\Repos\Storj
#.\Storj3Monitor\Storj3Monitor.ps1 -c .\Storj3Monitor\ConfigSamples\Storj3Monitor.Krey.conf
