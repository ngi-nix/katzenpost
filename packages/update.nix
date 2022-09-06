{
  server-src,
  client-src,
  writeShellScriptBin,
  gomod2nix,
}:
writeShellScriptBin "update-nixified-dependencies" ''
  cd $(git rev-parse --show-toplevel)
  mkdir -p deps
  pushd deps

  cp -f ${server-src}/go.mod ${server-src}/go.sum .
  ${gomod2nix}/bin/gomod2nix
  mv gomod2nix.toml server.toml
  git add server.toml
  rm -f go.mod go.sum

  cp -f ${client-src}/go.mod ${client-src}/go.sum .
  ${gomod2nix}/bin/gomod2nix
  mv gomod2nix.toml client.toml
  git add client.toml
  rm -f go.mod go.sum

  popd
''
