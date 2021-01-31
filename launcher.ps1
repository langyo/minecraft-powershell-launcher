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
  $server.Start()
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
  $server.Stop()
}

$server = New-Object System.Net.HttpListener
$server.Prefixes.Add('http://*:9233/')
$server.AuthenticationSchemes = 'Negotiate'

$serverProcess = [PowerShell]::Create().AddScript($serverScriptCode).AddArgument($server)
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
$form.MinimizeBox = $False
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
$form.Topmost = $true
$form.Add_Shown( { $browserBox.Select() })
$form.ShowDialog()
$serverEndCode = {
  $serverProcess.EndEnvoke()
}
$form.Add_Closed($serverEndCode)