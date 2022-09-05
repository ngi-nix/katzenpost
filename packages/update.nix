{
  src,
  writeShellScriptBin,
  gomod2nix,
}:
writeShellScriptBin "update-nixified-dependencies" ''
  export PATH=${gomod2nix}/bin:$PATH

  cd $(git rev-parse --show-toplevel)
  pushd deps

  cp -f ${src}/go.mod ${src}/go.sum .

  gomod2nix
  git add gomod2nix.toml

  rm -f go.mod go.sum
  popd
''
