import (
  # let rev = "60cce7e5e1fdf62421ef6d4184ee399b46209366"; in
  let rev = "04a48a2fcd2370f4e8a8c9fd3394531ccdb30f1e"; in
  fetchTarball "https://github.com/MatrixAI/nixpkgs/archive/${rev}.tar.gz"
)
