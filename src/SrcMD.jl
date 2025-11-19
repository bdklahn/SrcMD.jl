module SrcMD

using FileTrees
using Mustache
using BaseDirs
using Base: getpass
using TOML

export  src_files_tree
export  write_md_file

"map file extensions to Markdown code fence block annotation languages"
const ext_lang = (
    apacheconf = "apache",
    c = "c",
    clj = "clojure",
    coffee = "coffeescript",
    cpp = "cpp",
    cr = "crystal",
    cs = "csharp",
    css = "css",
    d = "d",
    dart = "dart",
    djt = "django",
    dockerfile = "dockerfile",
    env = "dotenv",
    erb = "erb",
    erl = "erlang",
    ex = "elixir",
    f90 = "fortran",
    fs = "fsharp",
    git = "git",
    glsl = "glsl",
    go = "go",
    graphql = "graphql",
    groovy = "groovy",
    haml = "haml",
    hcl = "hcl",
    hs = "haskell",
    html = "html",
    http = "http",
    ini = "ini",
    java = "java",
    jenkinsfile = "jenkins",
    jl = "julia",
    js = "javascript",
    json = "json",
    jsx = "jsx",
    kt = "kotlin",
    less = "less",
    lisp = "lisp",
    lua = "lua",
    m = "matlab",
    mak = "makefile",
    md = "markdown",
    ml = "ocaml",
    nginxconf = "nginx",
    pas = "pascal",
    php = "php",
    pl = "perl",
    pp = "puppet",
    properties = "properties",
    proto = "protobuf",
    ps1 = "powershell",
    py = "python",
    r = "r",
    rb = "ruby",
    rkt = "racket",
    rs = "rust",
    sass = "sass",
    scala = "scala",
    scm = "scheme",
    scss = "scss",
    sh = "bash",
    sql = "sql",
    svelte = "svelte",
    swift = "swift",
    tcl = "tcl",
    tex = "latex",
    tf = "terraform",
    toml = "toml",
    ts = "typescript",
    tsx = "tsx",
    txt = "plaintext",
    v = "vlang",
    vala = "vala",
    vb = "vbnet",
    vim = "vim",
    vue = "vue",
    wasm = "wasm",
    xml = "xml",
    yml = "yaml",
    zig = "zig",
)

"regular expression matching source code files based on their extensions"
const src_file_regex = Regex("[^/]\\.(" * join(string.(keys(ext_lang)), '|') * ")\$")

code_block_template = mt"""
file: {{{name}}}
```{{{lang}}}
{{{code}}}
```
"""

function src_files_tree(
  dir::String;
  src_file_regex::Regex=src_file_regex,
)
    FileTrees.load(f->read(path(f), String), FileTree(dir)[src_file_regex])
end

function write_md_file(
  indir::String,
  outdir::String=normpath(joinpath(indir, "../"));
  src_file_regex::Regex=src_file_regex,
)
    t = src_files_tree(indir; src_file_regex=src_file_regex)
    md_fpath = joinpath(outdir, basename(t.name) * ".md")
    rm(md_fpath; force=true)
    FileTrees.map(t; walk=FileTrees.prewalk) do n
      p = path(n)
      if isdir(p)
          dir = relpath(p, dirname(t.name))
          heading = "#" ^ (length(splitpath(dir))) * " directory: $(dir)\n\n"
          open(md_fpath, "a") do io
            write(io, heading)
          end
      else
          ext = splitext(p)[2][2:end]  # get extension without dot
          d = Dict(
              "name" => name(n),
              "lang" => get(ext_lang, Symbol(ext), "plaintext"),
              "code" => get(n),
          )
          code_block = Mustache.render(code_block_template, d)
          open(md_fpath, "a") do io
            write(io, code_block * "\n\n")
          end
      end
      n
    end
    md_fpath
end


"""
    get_github_token(app_name::String)

Retrieves a GitHub PAT using the following priority:
1. `GITHUB_TOKEN` environment variable.
2. GitHub CLI (`gh`) authentication (if installed).
3. A local `config.toml` file located in the standard OS config directory.
4. Prompts the user to enter a token and saves it for next time.
"""
function get_github_token(app_name::String="SrcMD")
    # --- 1. Check Environment Variable (Best for CI/CD) ---
    if haskey(ENV, "GITHUB_TOKEN")
        # println("Using token from GITHUB_TOKEN environment variable.")
        return ENV["GITHUB_TOKEN"]
    end

    # --- 2. Check GitHub CLI (Best for Devs) ---
    if !isnothing(Sys.which("gh"))
        try
            # `gh auth token` handles the secure system keyring lookups
            token = strip(read(`gh auth token`, String))
            # println("Using token from GitHub CLI.")
            return token
        catch
            # gh exists but might not be logged in; ignore and continue
        end
    end

    # --- 3. Check Local Config File (BaseDirs Standard) ---
    # BaseDirs automatically finds:
    # Windows: C:\Users\User\AppData\Roaming\app_name\
    # Linux:   ~/.config/app_name/
    # macOS:   ~/Library/Application Support/app_name/
    config_dir = BaseDirs.User.config(app_name)
    config_file = joinpath(config_dir, "config.toml")

    if isfile(config_file)
        try
            data = TOML.parsefile(config_file)
            if haskey(data, "github_token")
                @info "Using token from config file: $config_file"
                return data["github_token"]
            end
        catch e
            @warn "Config file exists but could not be read: $e"
        end
    end

    # --- 4. Fallback: Prompt and Save ---
    println("""
    --- GitHub Authentication Required ---
    No token found in Environment, GitHub CLI, or Config.
    Please paste your Personal Access Token (PAT).
    (Input will be hidden)""")

    token = strip(read(getpass("Token"), String))

    if isempty(token)
        error("Token cannot be empty.")
    end

    # Ensure directory exists
    mkpath(config_dir)

    # Write to file
    open(config_file, "w") do io
        TOML.print(io, Dict("github_token" => token))
        @info "Saved GitHub token to config file: $config_file"
    end

    # Security: Restrict file permissions on Unix-like systems
    if !Sys.iswindows()
        chmod(config_file, 0o600) # Read/Write for user only
    end

    return token
end



end # module SrcMD
