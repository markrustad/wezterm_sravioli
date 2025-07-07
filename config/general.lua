local Icons = require "utils.class.icon"
local fs = require("utils.fn").fs
local wt = require "wezterm"

local Config = {}

-- Get platform information using helper functions
local platform = fs.platform()

-- Helper function to check if a program exists
local function program_exists(program)
  local cmd = platform.is_win and ("where %s >nul 2>&1"):format(program)
    or ("command -v %s >/dev/null 2>&1"):format(program)
  return os.execute(cmd) == 0
end

-- Helper function to check if a file exists
local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end
  return false
end

-- Get environment-based paths
local function get_env_paths()
  local paths = {}

  if platform.is_win then
    paths.user_profile = os.getenv "USERPROFILE" or ""
    paths.msys2_root = os.getenv "MSYS2_ROOT" or (paths.user_profile .. "\\msys64")
    paths.msys2_home = os.getenv "MSYS2_HOME"
      or (paths.msys2_root .. "\\home\\" .. (os.getenv "USERNAME" or ""))
    paths.git_bash = os.getenv "GIT_BASH"
      or (os.getenv "LOCALAPPDATA" .. "\\Programs\\Git\\bin\\bash.exe")
  else
    paths.home = os.getenv "HOME" or fs.home()
  end

  return paths
end

local env_paths = get_env_paths()

-- Configure default program based on platform
if platform.is_win then
  Config.default_prog =
    { "pwsh", "-NoLogo", "-ExecutionPolicy", "RemoteSigned", "-NoProfileLoadTime" }
else
  Config.default_prog = { "zsh", "-l" }
end

-- Configure launch menu with enhanced cross-platform support
Config.launch_menu = {}

if platform.is_win then
  -- Windows-specific launch menu items
  Config.launch_menu = {}

  -- Add PowerShell V7 if available
  if program_exists "pwsh" then
    table.insert(Config.launch_menu, {
      label = Icons.Progs["pwsh.exe"] .. " PowerShell V7",
      args = {
        "pwsh",
        "-NoLogo",
        "-ExecutionPolicy",
        "RemoteSigned",
        "-NoProfileLoadTime",
      },
      cwd = "~",
    })
  end

  -- Add PowerShell V5 if available
  if program_exists "powershell" then
    table.insert(Config.launch_menu, {
      label = Icons.Progs["pwsh.exe"] .. " PowerShell V5",
      args = { "powershell" },
      cwd = "~",
    })
  end

  -- Add Command Prompt (should always be available on Windows)
  table.insert(Config.launch_menu, {
    label = "Command Prompt",
    args = { "cmd.exe" },
    cwd = "~",
  })

  -- Add Git bash if available via PATH
  if program_exists "bash" then
    table.insert(Config.launch_menu, {
      label = Icons.Progs["git"] .. " Git bash",
      args = { "bash", "-l" },
      cwd = "~",
    })
  end

  -- Add MSYS2 configurations if available
  local msys2_shell = env_paths.msys2_root .. "\\msys2_shell.cmd"
  if file_exists(msys2_shell) then
    -- Add UCRT64 if available
    table.insert(Config.launch_menu, {
      label = "UCRT64",
      args = {
        msys2_shell,
        "-defterm",
        "-here",
        "-no-start",
        "-ucrt64",
        "-shell",
        "zsh",
      },
      cwd = env_paths.msys2_home,
    })

    -- Add MSYS2
    table.insert(Config.launch_menu, {
      label = "MSYS2",
      args = {
        msys2_shell,
        "-defterm",
        "-here",
        "-no-start",
        "-msys",
        "-shell",
        "zsh",
      },
      cwd = env_paths.msys2_home,
    })
  end

  -- Add Git Bash from typical installation path if file exists
  if file_exists(env_paths.git_bash) then
    table.insert(Config.launch_menu, {
      label = "Git Bash",
      args = { env_paths.git_bash, "-i", "-l" },
      cwd = "~",
    })
  end

  -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
  Config.wsl_domains = {
    {
      name = "WSL:Ubuntu",
      distribution = "Ubuntu",
      username = "sravioli",
      default_cwd = "~",
      default_prog = { "bash", "-i", "-l" },
    },
    {
      name = "WSL:Alpine",
      distribution = "Alpine",
      username = "sravioli",
      default_cwd = "/home/sravioli",
    },
  }
else
  -- Unix-like systems (Linux, macOS)
  Config.launch_menu = {}

  -- Add zsh if available
  if program_exists "zsh" then
    table.insert(Config.launch_menu, {
      label = "zsh",
      args = { "zsh", "-l" },
    })
  end

  -- Add bash if available
  if program_exists "bash" then
    table.insert(Config.launch_menu, {
      label = "bash",
      args = { "bash", "-l" },
    })
  end

  -- Add fish if available
  if program_exists "fish" then
    table.insert(Config.launch_menu, {
      label = "fish",
      args = { "fish", "-l" },
    })
  end
end

-- Add a separator after platform-specific items
if #Config.launch_menu > 0 then
  table.insert(Config.launch_menu, { label = "──────────" })
end

Config.default_cwd = fs.home()

-- Configure SSH domains based on environment variable
Config.ssh_domains = {}

local ssh_domain_env = os.getenv "WEZTERM_SSH_DOMAIN"

-- Get SSH-related environment variables
local ssh_username = os.getenv "SSH_USERNAME"
  or os.getenv "USER"
  or os.getenv "USERNAME"
  or "user"
local ssh_key_path = os.getenv "SSH_KEY_PATH" or "~/.ssh/id_ed25519"
local remote_wezterm_path = os.getenv "REMOTE_WEZTERM_PATH"
  or ("/home/" .. ssh_username .. "/.local/bin/wezterm")

if ssh_domain_env == "sky1" then
  -- Use environment variables for HPC configuration
  local hpc_username = os.getenv "HPC_USERNAME" or ssh_username
  local hpc_wezterm_path = os.getenv "HPC_WEZTERM_PATH"
    or ("/data/home/" .. hpc_username .. "/.local/bin/wezterm")

  Config.ssh_domains = {
    {
      name = "sky1",
      remote_address = os.getenv "HPC_SUBMIT1_HOST" or "ai-hpcsubmit1.niaid.nih.gov",
      username = hpc_username,
      remote_wezterm_path = hpc_wezterm_path,
      ssh_option = {
        identityfile = ssh_key_path,
      },
    },
    {
      name = "sky2",
      remote_address = os.getenv "HPC_SUBMIT2_HOST" or "ai-hpcsubmit2.niaid.nih.gov",
      username = hpc_username,
      remote_wezterm_path = hpc_wezterm_path,
      ssh_option = {
        identityfile = ssh_key_path,
      },
    },
    {
      name = "thinlinc",
      remote_address = os.getenv "HPC_GPU_HOST" or "ai-hpcgpu19.niaid.nih.gov",
      username = hpc_username,
      remote_wezterm_path = hpc_wezterm_path,
      ssh_option = {
        identityfile = ssh_key_path,
      },
    },
  }
elseif ssh_domain_env == "manjaro" then
  Config.ssh_domains = {
    {
      name = "manjaro",
      remote_address = os.getenv "MANJARO_HOST" or "192.168.1.86",
      username = ssh_username,
      remote_wezterm_path = remote_wezterm_path,
      ssh_option = {
        identity_file = ssh_key_path,
      },
    },
    {
      name = "nas",
      remote_address = os.getenv "NAS_HOST" or "192.168.2.10",
      username = ssh_username,
      remote_wezterm_path = remote_wezterm_path,
      ssh_option = {
        identity_file = ssh_key_path,
      },
    },
    {
      name = "termux",
      remote_address = os.getenv "TERMUX_HOST" or "192.168.1.207",
      username = ssh_username,
      remote_wezterm_path = remote_wezterm_path,
      ssh_option = {
        identity_file = ssh_key_path,
      },
    },
  }
elseif ssh_domain_env == "nas" then
  Config.ssh_domains = {
    -- Add specific domains for nas environment if needed
    -- Can be configured with NAS_* environment variables
  }
elseif ssh_domain_env == "termux" then
  Config.ssh_domains = {
    -- Add specific domains for termux environment if needed
    -- Can be configured with TERMUX_* environment variables
  }
end

-- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
Config.unix_domains = {}

return Config
