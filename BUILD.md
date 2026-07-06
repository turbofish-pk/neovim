- **IMPORTANT**: Before upgrading to a new version, **always check for [breaking changes](https://neovim.io/doc/user/news.html#news-breaking).**


## Quick start

1. Install [build prerequisites](#build-prerequisites) on your system
2. `git clone https://github.com/neovim/neovim`
3. `cd neovim`
    - If you want the **stable release**, also run `git checkout stable`.
4. `make CMAKE_BUILD_TYPE=RelWithDebInfo`
    - If you want to install to a custom location, set `CMAKE_INSTALL_PREFIX`. See also [INSTALL.md](./INSTALL.md#install-from-source).
5. `sudo make install`
    - Default install location is `/usr/local`
**Notes**:
- From the repository's root directory, running `make` will download and build all the needed dependencies and put the `nvim` executable in `build/bin`.
- Third-party dependencies (libuv, LuaJIT, etc.) are downloaded automatically to `.deps/`. See the [FAQ](https://neovim.io/doc/user/faq.html#faq-build) if you have issues.
- After building, you can run the `nvim` executable without installing it by running `VIMRUNTIME=runtime ./build/bin/nvim`.
- If you plan to develop Neovim, install [Ninja](https://ninja-build.org/) for faster builds. It will automatically be used.
- Install [ccache](https://ccache.dev/) for faster rebuilds of Neovim. It's used by default. To disable it, use `CCACHE_DISABLE=true make`.

## Running tests

See [test/README.md](https://github.com/neovim/neovim/blob/master/test/README.md).

## Building

First make sure you installed the [build prerequisites](#build-prerequisites). Now that you have the dependencies, you can try other build targets explained below.

The _build type_ determines the level of used compiler optimizations and debug information:

- `Release`: Full compiler optimizations and no debug information. Expect the best performance from this build type. Often used by package maintainers.
- `Debug`: Full debug information; few optimizations. Use this for development to get meaningful output from debuggers like GDB or LLDB. This is the default if `CMAKE_BUILD_TYPE` is not specified.
- `RelWithDebInfo` ("Release With Debug Info"): Enables many optimizations and adds enough debug info so that when Neovim ever crashes, you can still get a backtrace.

So, for a release build, just use:

```bash
make CMAKE_BUILD_TYPE=Release
```
(Do not add a `-j` flag if `ninja` is installed! The build will be in parallel automatically.)

Afterwards, the `nvim` executable can be found in `build/bin`. To verify the build type after compilation, run:

```bash
./build/bin/nvim --version | grep ^Build
```

To install the executable to a certain location, use:

```bash
make CMAKE_INSTALL_PREFIX=$HOME/.local/share/nvim install
```

CMake, our main build system, caches a lot of things in `build/CMakeCache.txt`. If you ever want to change `CMAKE_BUILD_TYPE` or `CMAKE_INSTALL_PREFIX`, run `rm -rf build` first. This is also required when rebuilding after a Git commit adds or removes files (including from `runtime`) — when in doubt, run `make distclean` (which is basically a shortcut for `rm -rf build .deps`).

By default (`USE_BUNDLED=1`), Neovim downloads and statically links its needed dependencies. In order to be able to use a debugger on these libraries, you might want to compile them with debug information as well:

<!-- THIS CAUSES SCREEN INTERFERENCE
```
make distclean
VERBOSE=1 DEBUG=1 make deps
```
-->
```bash
make distclean
make deps
```

### Build options

View the full list of CMake options defined in this project:
```bash
cmake -B build -LH
```

## Building on Windows

### Windows / CLion

1. Install [CLion](https://www.jetbrains.com/clion/).
2. Open the Neovim project in CLion.
3. Select _Build → Build All in 'Release'_.

## Compiler options

To see the chain of includes, use the `-H` option ([#918](https://github.com/neovim/neovim/issues/918)):

```bash
echo '#include "./src/nvim/buffer.h"' | \
> clang -I.deps/usr/include -Isrc -std=c99 -P -E -H - 2>&1 >/dev/null | \
> grep -v /usr/
```

- `grep -v /usr/` is used to filter out system header files.
- `-save-temps` can be added as well to see expanded macros or commented assembly.

## Custom Makefile

You can customize the build process locally by creating a `local.mk`, which is referenced at the top of the main `Makefile`. It's listed in `.gitignore`, so it can be used across branches. **A new target in `local.mk` overrides the default make-target.**

Here's a sample `local.mk` which adds a target to force a rebuild but *does not* override the default-target:

```make
all:

rebuild:
	rm -rf build
	make
```

## Third-party dependencies

Reference the [Debian package](https://packages.debian.org/sid/source/neovim) (or alternatively, the [Homebrew formula](https://github.com/Homebrew/homebrew-core/blob/master/Formula/n/neovim.rb)) for the precise list of dependencies/versions.

To build the bundled dependencies using CMake:

```bash
cmake -S cmake.deps -B .deps -G Ninja -D CMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build .deps
```

By default the libraries and headers are placed in `.deps/usr`. Now you can build Neovim:

```bash
cmake -B build -G Ninja -D CMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build
```

### Build without "bundled" dependencies

1. Manually install the dependencies:
    - libuv libluv libutf8proc luajit lua-lpeg tree-sitter tree-sitter-c tree-sitter-lua tree-sitter-markdown tree-sitter-query tree-sitter-vim tree-sitter-vimdoc unibilium
2. Run CMake:
   ```bash
   cmake -B build -G Ninja -D CMAKE_BUILD_TYPE=RelWithDebInfo
   cmake --build build
   ```
   If all the dependencies are not available in the package, you can use only some of the bundled dependencies as follows (example of using `ninja`):
   ```bash
   cmake -S cmake.deps -B .deps -G Ninja -D CMAKE_BUILD_TYPE=RelWithDebInfo -DUSE_BUNDLED=OFF -DUSE_BUNDLED_TS=ON
   cmake --build .deps
   cmake -B build -G Ninja -D CMAKE_BUILD_TYPE=RelWithDebInfo
   cmake --build build
   ```
3. Run `make`, `ninja`, or whatever build tool you told CMake to generate.
    - Using `ninja` is strongly recommended.
4. If treesitter parsers are not bundled, they need to be available in a `parser/` runtime directory (e.g. `/usr/share/nvim/runtime/parser/`).


### Build without unibilium

Unibilium is the only dependency which is licensed under LGPLv3 (there are no
GPLv3-only dependencies). This library is used for loading the terminfo database at
runtime, and can be disabled if the internal definitions for common terminals
are good enough. To avoid this dependency, build with support for loading
custom terminfo at runtime, use

```bash
make CMAKE_EXTRA_FLAGS="-DENABLE_UNIBILIUM=0" DEPS_CMAKE_FLAGS="-DUSE_BUNDLED_UNIBILIUM=0"
```

To confirm at runtime that unibilium was not included, check `has('terminfo') == 1`.

### Build with specific "bundled" dependencies

Example of building with specific bundled and non-bundled dependencies:

```bash
make DEPS_CMAKE_FLAGS="-DUSE_BUNDLED=OFF -DUSE_BUNDLED_LUV=ON -DUSE_BUNDLED_TS=ON -DUSE_BUNDLED_LIBUV=ON"
```

## Build prerequisites

General requirements (see [#1469](https://github.com/neovim/neovim/issues/1469#issuecomment-63058312)):

- Clang or GCC version 4.9+
- CMake version 3.16+, built with TLS/SSL support
  - Optional: Get the latest CMake from https://cmake.org/download/
    - Provides a shell script which works on most Linux systems. After running it, ensure the resulting `cmake` binary is in your $PATH so the Nvim build will find it.

Platform-specific requirements are listed below.

### RHEL / Fedora

```bash
sudo dnf -y install ninja-build cmake gcc make gettext curl glibc-gconv-extra git
```

### openSUSE

```bash
sudo zypper install ninja cmake gcc-c++ gettext-tools curl git
```

## Building with zig

### Prerequisites

- zig 0.16.x

### Instructions

- Build the editor: `zig build`, run it with `./zig-out/bin/nvim`
- Complete installation with runtime: `zig build install --prefix ~/.local`
- Tests:
  - `zig build functionaltest` to run all functionaltests
  - `zig build functionaltest -- test/functional/autocmd/bufenter_spec.lua` to run the tests in one file
  - `zig build unittest` to run all unittests
  - `zig build oldtest` to run all oldtests

#### Using system dependencies

See "Available System Integrations" in `zig build -h` to see available system integrations. Enabling an integration, e.g. `zig build -fsys=utf8proc` will use the system's installation of utf8proc.

`zig build --system deps_dir` will enable all integrations and turn off dependency fetching. This requires you to pre-download the dependencies which don't have a system integration into `deps_dir` (at the time of writing these are ziglua and the built-in tree-sitter parsers). You have to create subdirectories whose names are the respective package's hash under `deps_dir` and unpack the dependencies inside that directory - ziglua should go under `deps_dir/zlua-0.1.0-hGRpC1dCBQDf-IqqUifYvyr8B9-4FlYXqY8cl7HIetrC` and so on. Hashes should be taken from `build.zig.zon`.

See the `prepare` function of [this `PKGBUILD`](https://git.sr.ht/~chinmay/nvim_build/tree/26364a4cf9b4819f52a3e785fa5a43285fb9cea2/item/PKGBUILD#L90) for an example.


