{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  cmake,
  makeWrapper,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-contract";
  version = "5.0.3";

  src = fetchFromGitHub {
    owner = "paritytech";
    repo = "cargo-contract";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TlWdgeDLck7xCzyraIo6rLOIKzkIkbuVqWQSEoCeWRI=";
  };

  cargoHash = "sha256-bRAPICP2UBYHzIhiQ98rXsOavbjtWna3XcdonBmrO5w=";

  postPatch = ''
    # Fix cmake version requirement in wabt dependency
    sed -i 's/cmake_minimum_required.*$/cmake_minimum_required(VERSION 3.10)/' \
      $cargoDepsCopy/wabt-sys-*/wabt/CMakeLists.txt
  '';

  nativeBuildInputs = [
    pkg-config
    cmake
    makeWrapper
  ];

  buildInputs = [ openssl ];

  # Skip tests that require additional dependencies not in vendor
  doCheck = false;

  # Wrap cargo-contract to set RUST_SRC_PATH
  postInstall = ''
    wrapProgram $out/bin/cargo-contract \
      --set-default RUST_SRC_PATH "${rustPlatform.rustLibSrc}"
  '';

  meta = with lib; {
    description = "Setup and deployment tool for developing Wasm based smart contracts via ink!";
    homepage = "https://github.com/paritytech/cargo-contract";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ aciceri ];
    mainProgram = "cargo-contract";
  };
})
