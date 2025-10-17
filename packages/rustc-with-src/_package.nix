{
  rustc,
  rustPlatform,
  symlinkJoin,
  makeWrapper,
}:
let
  realRustc = rustc.unwrapped or rustc;
in
symlinkJoin {
  name = "rustc-with-src-${rustc.version}";
  paths = [ rustc ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    # Remove the symlink to lib if it exists
    if [ -e $out/lib ]; then
      rm -rf $out/lib
    fi

    # Recreate lib with symlinks from the unwrapped rustc
    mkdir -p $out/lib
    if [ -d "${realRustc}/lib" ]; then
      for item in ${realRustc}/lib/*; do
        if [ "$(basename "$item")" != "rustlib" ]; then
          ln -s "$item" $out/lib/
        fi
      done

      # Handle rustlib specially to add our src symlink
      if [ -d "${realRustc}/lib/rustlib" ]; then
        cp -r ${realRustc}/lib/rustlib $out/lib/
        chmod -R u+w $out/lib/rustlib

        # Create the src symlink that cargo-contract expects
        if [ -d $out/lib/rustlib/rustc-src ] && [ ! -e $out/lib/rustlib/src ]; then
          ln -s rustc-src $out/lib/rustlib/src
        fi

        # Populate library/ with the actual rust library sources
        if [ -d $out/lib/rustlib/src/rust/library ]; then
          # Remove the mostly empty library directory
          rm -rf $out/lib/rustlib/src/rust/library
          # Copy the full library sources from rustPlatform.rustLibSrc
          cp -r ${rustPlatform.rustLibSrc} $out/lib/rustlib/src/rust/library
          chmod -R u+w $out/lib/rustlib/src/rust/library
        fi
      fi
    fi

    # Wrap rustc to use our sysroot
    rm $out/bin/rustc
    makeWrapper ${rustc}/bin/rustc $out/bin/rustc \
      --add-flags "--sysroot $out"
  '';
}
