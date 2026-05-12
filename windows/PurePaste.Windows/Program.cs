using System.Runtime.InteropServices;
using System.Text.Json;
using System.Windows.Forms;

namespace PurePaste.Windows;

internal static class Program
{
    [STAThread]
    static void Main()
    {
        ApplicationConfiguration.Initialize();
        Application.Run(new PurePasteApplicationContext());
    }
}

internal sealed class PurePasteApplicationContext : ApplicationContext
{
    private readonly NotifyIcon notifyIcon;
    private readonly ToolStripMenuItem statusMenuItem;
    private readonly ToolStripMenuItem preserveFormattingMenuItem;
    private readonly ClipboardMonitorWindow monitorWindow;
    private readonly SettingsStore settingsStore;
    private bool preserveFormatting;
    private bool suppressNextClipboardUpdate;

    public PurePasteApplicationContext()
    {
        settingsStore = new SettingsStore();
        preserveFormatting = settingsStore.Load().PreserveFormatting;

        statusMenuItem = new ToolStripMenuItem("PurePaste: Initializing") { Enabled = false };
        preserveFormattingMenuItem = new ToolStripMenuItem("Preserve Formatting")
        {
            Checked = preserveFormatting,
            CheckOnClick = false
        };
        preserveFormattingMenuItem.Click += (_, _) => TogglePreserveFormatting();

        var quitMenuItem = new ToolStripMenuItem("Quit PurePaste");
        quitMenuItem.Click += (_, _) => ExitThread();

        var menu = new ContextMenuStrip();
        menu.Items.Add(statusMenuItem);
        menu.Items.Add(preserveFormattingMenuItem);
        menu.Items.Add(new ToolStripSeparator());
        menu.Items.Add(quitMenuItem);

        notifyIcon = new NotifyIcon
        {
            Icon = SystemIcons.Application,
            Visible = true,
            Text = "PurePaste",
            ContextMenuStrip = menu
        };

        monitorWindow = new ClipboardMonitorWindow();
        monitorWindow.ClipboardUpdated += OnClipboardUpdated;

        UpdateStatusUi();
    }

    protected override void ExitThreadCore()
    {
        monitorWindow.Dispose();
        notifyIcon.Visible = false;
        notifyIcon.Dispose();
        base.ExitThreadCore();
    }

    private void TogglePreserveFormatting()
    {
        preserveFormatting = !preserveFormatting;
        settingsStore.Save(new AppSettings { PreserveFormatting = preserveFormatting });
        UpdateStatusUi();
    }

    private void UpdateStatusUi()
    {
        statusMenuItem.Text = preserveFormatting ? "PurePaste: Bypass On" : "PurePaste: Stripping On";
        preserveFormattingMenuItem.Checked = preserveFormatting;
        notifyIcon.Text = preserveFormatting
            ? "PurePaste is preserving clipboard formatting"
            : "PurePaste is stripping rich clipboard formatting";
    }

    private void OnClipboardUpdated(object? sender, EventArgs e)
    {
        if (suppressNextClipboardUpdate)
        {
            suppressNextClipboardUpdate = false;
            return;
        }

        if (preserveFormatting)
        {
            return;
        }

        try
        {
            if (!Clipboard.ContainsText(TextDataFormat.UnicodeText))
            {
                return;
            }

            if (!ContainsRichText())
            {
                return;
            }

            var text = Clipboard.GetText(TextDataFormat.UnicodeText);
            if (string.IsNullOrEmpty(text))
            {
                return;
            }

            suppressNextClipboardUpdate = true;
            Clipboard.SetText(text, TextDataFormat.UnicodeText);
        }
        catch
        {
            suppressNextClipboardUpdate = false;
        }
    }

    private static bool ContainsRichText()
    {
        return Clipboard.ContainsData(DataFormats.Rtf)
               || Clipboard.ContainsData(DataFormats.Html);
    }
}

internal sealed class ClipboardMonitorWindow : NativeWindow, IDisposable
{
    private const int WmClipboardUpdate = 0x031D;

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool AddClipboardFormatListener(IntPtr hwnd);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool RemoveClipboardFormatListener(IntPtr hwnd);

    public event EventHandler? ClipboardUpdated;

    public ClipboardMonitorWindow()
    {
        CreateHandle(new CreateParams());
        AddClipboardFormatListener(Handle);
    }

    protected override void WndProc(ref Message m)
    {
        if (m.Msg == WmClipboardUpdate)
        {
            ClipboardUpdated?.Invoke(this, EventArgs.Empty);
        }

        base.WndProc(ref m);
    }

    public void Dispose()
    {
        if (Handle != IntPtr.Zero)
        {
            RemoveClipboardFormatListener(Handle);
            DestroyHandle();
        }
    }
}

internal sealed class AppSettings
{
    public bool PreserveFormatting { get; set; }
}

internal sealed class SettingsStore
{
    private readonly string filePath;

    public SettingsStore()
    {
        var baseDirectory = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "PurePaste");
        Directory.CreateDirectory(baseDirectory);
        filePath = Path.Combine(baseDirectory, "settings.json");
    }

    public AppSettings Load()
    {
        if (!File.Exists(filePath))
        {
            return new AppSettings();
        }

        try
        {
            var json = File.ReadAllText(filePath);
            return JsonSerializer.Deserialize<AppSettings>(json) ?? new AppSettings();
        }
        catch
        {
            return new AppSettings();
        }
    }

    public void Save(AppSettings settings)
    {
        var json = JsonSerializer.Serialize(settings, new JsonSerializerOptions
        {
            WriteIndented = true
        });
        File.WriteAllText(filePath, json);
    }
}
