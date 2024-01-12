PKG_ROOT := `pwd`
export PATH := env_var('PATH') + ':' + PKG_ROOT + '/bin' + ':' + env_var('HOME') + '/.cargo/bin'
CURRENT_DIR := invocation_directory_native()
DIR_NAME := file_stem(CURRENT_DIR)

setup:
    #!/usr/bin/env bash
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    cargo install uniffi-bindgen-go --git https://github.com/NordSecurity/uniffi-bindgen-go --tag v0.2.0+v0.25.0
    rustup target add aarch64-apple-darwin aarch64-unknown-linux-gnu
    brew tap messense/macos-cross-toolchains
    brew install aarch64-unknown-linux-gnu

# build the rust library for the various target platforms
build:
    @cargo build -p lib --target aarch64-apple-darwin
    @cargo build -p lib --target aarch64-unknown-linux-gnu


# generates the golang bindings for the UDL file
generate:
    @uniffi-bindgen-go lib/src/lib.udl

run-local: generate build
    @go run app

run-linux:
    docker run --rm -it -v .:/go golang go run app