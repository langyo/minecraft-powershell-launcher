Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Minecraft Launcher'
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = 'CenterScreen'
$form.ShowIcon = $False
$form.MaximizeBox = $False
$form.FormBorderStyle = 'Fixed3D'

$form.ShowDialog()
$form.Activate()
