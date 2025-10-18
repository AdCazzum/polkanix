{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  protobuf,
  perl,
  llvmPackages,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "substrate-contracts-node";
  version = "0.42.0";

  src = fetchFromGitHub {
    owner = "paritytech";
    repo = "substrate-contracts-node";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kwfl2wSQa99M9CZYY3UgLc2sX7HZDa0n88om/csJALU=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  # Use debug build for faster compilation during development
  buildType = "debug";

  # Fix jemalloc compilation issue with recent glibc
  # The tikv-jemalloc-sys version used expects GNU strerror_r but gets POSIX version
  env.NIX_CFLAGS_COMPILE = "-Wno-error=int-conversion";

  # Point bindgen to libclang for generating C/C++ bindings (needed for RocksDB)
  env.LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  nativeBuildInputs = [
    pkg-config
    protobuf
    perl
    llvmPackages.lld  # Required for linking WASM runtime
  ];

  buildInputs = [
    openssl
    llvmPackages.libclang.lib
  ];

  # Skip tests that require additional dependencies
  doCheck = false;

  # Substrate requires wasm32-unknown-unknown target for runtime compilation
  # Skip WASM runtime build - we only need the node binary for development
  env.SKIP_WASM_BUILD = "1";

  meta = with lib; {
    description = "Minimal Substrate node configured for smart contracts via pallet-contracts";
    homepage = "https://github.com/paritytech/substrate-contracts-node";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "substrate-contracts-node";
  };
})
