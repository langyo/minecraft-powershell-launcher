Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

$serverScriptCode = {
  param($server)
  while ($server.IsListening) {
    $context = $server.GetContext()
    # $request = $context.Request
    $response = $context.Response

    $str = Get-Date -Format 'hhmmss'
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($str)
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
    $response.OutputStream.Close()
  }
}

$port = 9233
$portIsEffective = $True
do {
  $portIsEffective = $True
  $sockt = New-Object System.Net.Sockets.Socket -ArgumentList 'InterNetwork', 'Stream', 'TCP'
  $ip = (Get-NetIPConfiguration).IPv4Address | Select-Object -First 1 -ExpandProperty IPAddress
  $ipAddress = [Net.IPAddress]::Parse($ip)
  Try {
    $ipEndpoint = New-Object System.Net.IPEndPoint $ipAddress, $port
    $sockt.Bind($ipEndpoint)
    $msg = 'The server is on the port ' + $port
    Write-Output $msg
  }
  Catch [exception] {
    $portIsEffective = $False
    $port += 1
  }
  Finally {
    $sockt.Close()
  }
} while ($portIsEffective -eq $False)

$server = New-Object System.Net.HttpListener
$server.Prefixes.Add('http://*:' + $port + '/')
$server.AuthenticationSchemes = 'Negotiate'

$serverProcess = [PowerShell]::Create().AddScript($serverScriptCode).AddArgument($server)
$server.Start()
$serverProcess.BeginInvoke()

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$page = '
<html>
<body>
<h1>Bootstrap is writing</h1>
</body>
</html>
'

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Minecraft Launcher'
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = 'CenterScreen'
$form.ShowIcon = $False
$form.MaximizeBox = $False
$form.FormBorderStyle = 'Fixed3D'
  
$browserBox = New-Object System.Windows.Forms.WebBrowser
$browserBox.Location = New-Object System.Drawing.Point(0, 0)
$browserBox.Size = New-Object System.Drawing.Size(600, 400)
$browserBox.AllowWebBrowserDrop = $False
$browserBox.IsWebBrowserContextMenuEnabled = $False
$browserBox.WebBrowserShortcutsEnabled = $False
$browserBox.ScriptErrorsSuppressed = $False
$browserBox.DocumentText = $page

$form.Controls.Add($browserBox)
$form.Add_Shown( { $browserBox.Select() })
$form.Add_Closed({ $server.Stop() })
$form.ShowDialog()
