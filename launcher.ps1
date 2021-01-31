Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

$path = $env:tmp + '\minecraft-launcher-bootstrap.html'
'
<html>
<body>
<h1>Bootstrap is writing</h1>
</body>
</html>
' > $path

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
$browserBox.Url = $path
$form.Controls.Add($browserBox)

$form.Topmost = $true

$form.Add_Shown( { $browserBox.Select() })
$form.ShowDialog()

Del $path