module SrcMD

using FileTrees
using Mustache

export  src_files_tree

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
    zig = "zig"
)

"regular expression matching source code files based on their extensions"
const src_file_regex = Regex("\\.(" * join(string.(keys(ext_lang)), '|') * ")\$")


function src_files_tree(
  dir::String,
  src_file_regex::Regex=src_file_regex,
)
    FileTree(dir)[src_file_regex]
end

end # module SrcMD
