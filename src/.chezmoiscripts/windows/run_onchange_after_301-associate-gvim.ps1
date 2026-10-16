# Open text files in the running gvim (as a new buffer) from Explorer.
#
# Explorer honours HKCU\...\FileExts\<ext>\UserChoice over the class registry,
# and with no UserChoice it falls back to OEMDefaultAssociations.xml (Notepad
# for .txt, .log and .ini), so registering a ProgId alone is not enough.
# Windows ignores a UserChoice whose Hash it did not write itself; the hash
# below reproduces its algorithm (reverse-engineered, as in SetUserFTA). Each
# association is checked through AssocQueryString afterwards, so a Windows
# update that changes the algorithm fails this script instead of passing
# silently.

$ErrorActionPreference = 'Stop'

$progId = 'r-okm.gvim'
$extensions = @(
  '.txt', '.md', '.log', '.ini', '.conf', '.config', '.cfg',
  '.toml', '.yaml', '.yml', '.json', '.csv', '.env'
)

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Win32;

public static class UserChoice {
    static uint U(byte[] b, int i) { return BitConverter.ToUInt32(b, i); }

    public static string Hash(string baseInfo) {
        byte[] str = Encoding.Unicode.GetBytes(baseInfo.ToLowerInvariant());
        byte[] data = new byte[str.Length + 2];
        Array.Copy(str, data, str.Length);
        byte[] md5;
        using (var m = MD5.Create()) { md5 = m.ComputeHash(data); }
        int length = (((data.Length & 4) <= 1) ? 1 : 0) + (data.Length >> 2) - 1;
        if (length <= 1) { return ""; }
        byte[] buf = new byte[data.Length + 8];
        Array.Copy(data, buf, data.Length);
        int rounds = ((length - 2) >> 1) + 1;

        unchecked {
            uint md51 = (U(md5, 0) | 1) + 0x69FB0000u;
            uint md52 = (U(md5, 4) | 1) + 0x13DB0000u;
            uint out1 = 0, out2 = 0, cache = 0;
            for (int i = 0, p = 0; i < rounds; i++, p += 8) {
                uint r0 = U(buf, p) + out1;
                uint r1 = U(buf, p + 4);
                uint r2a = r0 * md51 - 0x10FA9605u * (r0 >> 16);
                uint r2b = 0x79F8A395u * r2a + 0x689B6B9Fu * (r2a >> 16);
                uint r3 = 0xEA970001u * r2b - 0x3C101569u * (r2b >> 16);
                uint r4 = r3 + r1;
                uint r5 = cache + r3;
                uint r6a = r4 * md52 - 0x3CE8EC25u * (r4 >> 16);
                uint r6b = 0x59C3AF2Du * r6a - 0x2232E0F1u * (r6a >> 16);
                out1 = 0x1EC90001u * r6b + 0x35BD1EC9u * (r6b >> 16);
                out2 = r5 + out1;
                cache = out2;
            }
            uint a1 = out1, a2 = out2;

            md51 = U(md5, 0) | 1;
            md52 = U(md5, 4) | 1;
            out1 = 0; out2 = 0; cache = 0;
            for (int i = 0, p = 0; i < rounds; i++, p += 8) {
                uint r0 = U(buf, p) + out1;
                uint r1a = r0 * md51;
                uint r1b = 0xB1110000u * r1a - 0x30674EEFu * (r1a >> 16);
                uint r2a = 0x5B9F0000u * r1b - 0x78F7A461u * (r1b >> 16);
                uint r2b = 0x12CEB96Du * (r2a >> 16) - 0x46930000u * r2a;
                uint r3 = 0x1D830000u * r2b + 0x257E1D83u * (r2b >> 16);
                uint r4a = md52 * (r3 + U(buf, p + 4));
                uint r4b = 0x16F50000u * r4a - 0x5D8BE90Bu * (r4a >> 16);
                uint r5a = 0x96FF0000u * r4b - 0x2C7C6901u * (r4b >> 16);
                uint r5b = 0x2B890000u * r5a + 0x7C932B89u * (r5a >> 16);
                out1 = 0x9F690000u * r5b - 0x405B6097u * (r5b >> 16);
                out2 = out1 + cache + r3;
                cache = out2;
            }
            byte[] result = new byte[8];
            BitConverter.GetBytes(out1 ^ a1).CopyTo(result, 0);
            BitConverter.GetBytes(out2 ^ a2).CopyTo(result, 4);
            return Convert.ToBase64String(result);
        }
    }

    [DllImport("advapi32.dll", CharSet = CharSet.Unicode)]
    static extern int RegQueryInfoKey(Microsoft.Win32.SafeHandles.SafeRegistryHandle hKey, IntPtr cls,
        IntPtr clsLen, IntPtr reserved, IntPtr subKeys, IntPtr maxSubKeyLen, IntPtr maxClassLen,
        IntPtr values, IntPtr maxValueNameLen, IntPtr maxValueLen, IntPtr secDesc, out long lastWriteTime);

    // The hash covers the key's last write time, truncated to the minute.
    public static string LastWriteMinute(RegistryKey key) {
        long ft;
        int rc = RegQueryInfoKey(key.Handle, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero,
            IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, out ft);
        if (rc != 0) { throw new System.ComponentModel.Win32Exception(rc); }
        return (ft - ft % 600000000L).ToString("x16");
    }

    [DllImport("shlwapi.dll", CharSet = CharSet.Unicode)]
    static extern uint AssocQueryString(int flags, int str, string assoc, string extra,
        StringBuilder outp, ref uint len);

    public static string OpenCommand(string assoc) {
        uint n = 2048;
        var sb = new StringBuilder((int)n);
        // ASSOCSTR_COMMAND
        return AssocQueryString(0, 1, assoc, null, sb, ref n) == 0 ? sb.ToString() : "";
    }

    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(int eventId, uint flags, IntPtr item1, IntPtr item2);
}
'@

function Resolve-Gvim {
  $cmd = Get-Command gvim.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $cmd) {
    throw 'gvim.exe is not on PATH; install it (scoop install vim) and run chezmoi apply again'
  }
  # A scoop shim is a console launcher; point Explorer at the real GUI binary
  $shim = [IO.Path]::ChangeExtension($cmd.Source, '.shim')
  if (Test-Path $shim) {
    $m = Select-String -Path $shim -Pattern '^path\s*=\s*"?([^"]+)"?\s*$' | Select-Object -First 1
    if ($m) { return $m.Matches[0].Groups[1].Value }
  }
  return $cmd.Source
}

function Set-DefaultValue([string]$subKey, [string]$value) {
  $k = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($subKey)
  try { $k.SetValue('', $value) } finally { $k.Close() }
}

function Get-UserExperience {
  # Windows mixes this string, embedded in shell32.dll, into the hash
  $text = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes("$env:windir\System32\shell32.dll"))
  $m = [regex]::Match($text, 'User Choice set via Windows User Experience \{[0-9A-F-]{36}\}')
  if (-not $m.Success) { throw 'UserChoice salt not found in shell32.dll' }
  return $m.Value
}

function Test-OpensGvim([Microsoft.Win32.RegistryKey]$parent, [string]$subKey) {
  $k = $parent.OpenSubKey($subKey)
  if (-not $k) { return $false }
  try { $id = $k.GetValue('ProgId') } finally { $k.Close() }
  return $id -and [UserChoice]::OpenCommand($id) -eq $command
}

function Set-UserChoice([string]$ext, [string]$sid, [string]$experience) {
  $parent = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey(
    "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$ext")
  try {
    # Newer Windows builds write UserChoiceLatest alongside UserChoice and prefer
    # it, with a hash this script cannot produce. Keep one that already opens
    # gvim (set by hand via Open with > Always); drop any other so Explorer
    # falls back to UserChoice and the class registry.
    if (Test-OpensGvim $parent 'UserChoiceLatest\ProgId') { return }
    $parent.DeleteSubKeyTree('UserChoiceLatest', $false)
    # Likewise leave a UserChoice that already opens gvim alone: one written by
    # Open with > Always carries a Hash from Windows itself, which is safer to
    # keep than to replace with the reverse-engineered one
    if (Test-OpensGvim $parent 'UserChoice') { return }
    # Windows denies SetValue on its own UserChoice, so start from a fresh key.
    # Writing Hash can move the last write time into the next minute; retry then.
    for ($i = 0; $i -lt 3; $i++) {
      if ($parent.GetSubKeyNames() -contains 'UserChoice') { $parent.DeleteSubKey('UserChoice') }
      $k = $parent.CreateSubKey('UserChoice')
      try {
        $k.SetValue('ProgId', $progId)
        $minute = [UserChoice]::LastWriteMinute($k)
        $k.SetValue('Hash', [UserChoice]::Hash("$ext$sid$progId$minute$experience"))
        if ([UserChoice]::LastWriteMinute($k) -eq $minute) { return }
      } finally { $k.Close() }
    }
    throw "UserChoice for $ext kept crossing a minute boundary"
  } finally { $parent.Close() }
}

$gvim = Resolve-Gvim
$command = "`"$gvim`" --remote-silent `"%1`""

Set-DefaultValue "Software\Classes\$progId" 'Text file (gvim)'
Set-DefaultValue "Software\Classes\$progId\DefaultIcon" "`"$gvim`",0"
Set-DefaultValue "Software\Classes\$progId\shell\open\command" $command
# Used by "Open with" when gvim is picked from the app list
Set-DefaultValue 'Software\Classes\Applications\gvim.exe\shell\open\command' $command

$sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$experience = Get-UserExperience
foreach ($ext in $extensions) {
  Set-DefaultValue "Software\Classes\$ext" $progId
  $k = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey("Software\Classes\$ext\OpenWithProgids")
  try { $k.SetValue($progId, [byte[]]@(), 'None') } finally { $k.Close() }
  # One extension Windows refuses to let us touch should not leave the rest
  # unconfigured; the AssocQueryString check below still fails the script
  try { Set-UserChoice $ext $sid $experience } catch { Write-Warning "${ext}: $_" }
}

# Files without an extension resolve through the "." class
Set-DefaultValue 'Software\Classes\.' $progId
# Extensions nothing has registered fall back to "Unknown", whose default verb
# is the "Open with" dialog
Set-DefaultValue 'Software\Classes\Unknown\shell\gvim\command' $command
Set-DefaultValue 'Software\Classes\Unknown\shell' 'gvim'

# SHCNE_ASSOCCHANGED, SHCNF_IDLIST
[UserChoice]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)

$failed = @($extensions + '.' + '.r-okm-unregistered' | Where-Object {
    [UserChoice]::OpenCommand($_) -ne $command
  })
if ($failed) {
  # Open with > Always writes a choice Windows trusts, and Set-UserChoice keeps
  # it on the next run. That dialog cannot fix the "." class or the Unknown
  # fallback, so only listed extensions get the hint.
  $manual = @($failed | Where-Object { $extensions -contains $_ })
  $hint = if ($manual) { " (pick gvim via Open with > Always for: $($manual -join ' '), then run chezmoi apply again)" } else { '' }
  throw "Explorer still opens these with another app: $($failed -join ' ')$hint"
}
Write-Host "gvim is associated with: $($extensions -join ' '), files without an extension, and unregistered extensions"
