{
	description = "Dune Awakening Linux hosting investigation and pinned operator tools";
	inputs = {
		# Reuse the host configuration's existing package revision without changing it.
		nixpkgs.url = "github:NixOS/nixpkgs/c0a89c379b4ac67c7b13b051ddbd4e0dbc9b0eaf";
		# Locale-free, reproducible line sorting (`collate`) for scripts and tests.
		romantic_collation.url = "github:pmarreck/romantic_collation";
		# Cryptographically secure random picks (`random`), used for generated passphrases.
		random.url = "github:pmarreck/random";
		# LuaJIT v2.1 fork whose JIT runs under MemoryDenyWriteExecute (trace code remapped through a memfd). Taken as
		# source only and built by nixpkgs' LuaJIT recipe below, so nixpkgs' Lua package set compiles against it.
		# Rollback: drop this input and the override once upstream LuaJIT carries the change.
		luajit-mdwe = {
			url = "github:pmarreck/luajit_mdwe/171e315503e9cedcc44afdf2ab03dd569504cb0a";
			flake = false;
		};
	};
	outputs = { self, nixpkgs, romantic_collation, random, luajit-mdwe }:
		let
			system = "x86_64-linux";
			# Only steamcmd and its steam-unwrapped bootstrap are admitted as unfree; review any addition.
			pkgs = import nixpkgs {
				inherit system;
				config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "steamcmd" "steam-unwrapped" ];
				overlays = [ luajitMdweOverlay ];
			};
			# The fork with memfd code remapping on by default (LUAJIT_SECURITY_MCODE=2, Linux only), so our LuaJIT tools
			# need no flag under MemoryDenyWriteExecute=yes. It is nixpkgs' own LuaJIT recipe with the fork's source:
			# `self` makes `.pkgs`/`withPackages` build every Lua C module (cjson, luasocket, lpeg, ...) against it, and
			# `luaAttr` names this new attribute so nixpkgs' build-host interpreter (luarocks, wrappers) is the same build.
			# It is a separate attribute, not a replacement of luajit_2_1, so nothing else in nixpkgs is rebuilt.
			luajitMdweOverlay = final: prev: {
				luajit_mdwe = (prev.luajit_2_1.override {
					self = final.luajit_mdwe;
					luaAttr = "luajit_mdwe";
					src = luajit-mdwe;
					version = "2.1.${toString luajit-mdwe.lastModified}";
				}).overrideAttrs (old: {
					pname = "luajit-mdwe";
					# The rolling-release number normally comes from git export-subst, which a flake source may lack.
					postPatch = old.postPatch + ''
						echo ${toString luajit-mdwe.lastModified} > .relver
					'';
					env = old.env // prev.lib.optionalAttrs prev.stdenv.hostPlatform.isLinux {
						NIX_CFLAGS_COMPILE = "${old.env.NIX_CFLAGS_COMPILE} -DLUAJIT_SECURITY_MCODE=2";
					};
				});
			};
			luajit = pkgs.luajit_mdwe;
			tools = [
				pkgs.bash pkgs.coreutils pkgs.curl pkgs.git pkgs.jq pkgs.openssl
				(pkgs.python312.withPackages (ps: [ ps.psycopg2 ps.python-dateutil ps.debugpy ])) pkgs.rsync pkgs.gnumake pkgs.ripgrep
				pkgs.gnugrep pkgs.gnused pkgs.gawk pkgs.findutils
				pkgs.gnutar pkgs.gzip pkgs.util-linux pkgs.procps pkgs.cacert
				romantic_collation.packages.${system}.default random.packages.${system}.random-luajit
				pkgs.steamcmd pkgs.postgresql_17 pkgs.rabbitmq-server pkgs.socat pkgs.patchelf pkgs.iproute2 pkgs.systemd
				luajitEnv
			];
			# Mirrors the host's global luajit.withPackages module set so scripts behave the same inside and outside the dev
			# shell (the host's interpreter is stock LuaJIT; this one is the fork).
			luajitEnv = luajit.withPackages (ps: with ps; [
				alt-getopt basexx busted cjson lpeg lua_cliargs luabitop luacheck
				luafilesystem luasocket luasystem penlight sqlite
			]);
			musl = pkgs.pkgsMusl;
			# Libraries that Funcom's musl self-contained .NET apps (Director, TextRouter) load via RUNPATH $ORIGIN/netcoredeps.
			netcoredeps = pkgs.runCommand "dune-musl-netcoredeps" { } ''
				mkdir -p "$out"
				ln -s ${musl.musl}/lib/libc.so "$out/libc.musl-x86_64.so.1"
				ln -s ${musl.stdenv.cc.cc.lib}/lib/libstdc++.so.6 ${musl.stdenv.cc.cc.lib}/lib/libgcc_s.so.1 "$out/"
				ln -s ${musl.zlib}/lib/libz.so.1 "$out/"
				ln -s ${musl.icu}/lib/libicu*.so* ${musl.openssl.out}/lib/libssl.so* ${musl.openssl.out}/lib/libcrypto.so* "$out/"
			'';
			shellEnv = {
				DUNE_MUSL_LOADER = "${musl.musl}/lib/ld-musl-x86_64.so.1";
				DUNE_NETCOREDEPS = "${netcoredeps}";
				DUNE_GLIBC_LOADER = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
				DUNE_GCC_LIB = "${pkgs.stdenv.cc.cc.lib}/lib";
				DUNE_LIBPQ = "${pkgs.postgresql_17.lib}/lib/libpq.so.5";
				# Store paths of the Lua runtime closure; tests/integration/toolchain checks that it holds only the fork's LuaJIT.
				DUNE_LUAJIT_CLOSURE = "${pkgs.closureInfo { rootPaths = [ luajitEnv ]; }}/store-paths";
			};
		in {
			checks.${system} = {
				operator-tools = pkgs.runCommand "dune-operator-tools-check" {
					nativeBuildInputs = tools;
					inherit (shellEnv) DUNE_MUSL_LOADER DUNE_NETCOREDEPS DUNE_GLIBC_LOADER DUNE_GCC_LIB DUNE_LIBPQ DUNE_LUAJIT_CLOSURE;
					src = pkgs.lib.fileset.toSource {
						root = ./.;
						fileset = pkgs.lib.fileset.unions [ ./test ./tests ./bin ./libexec ./data ./.envrc ];
					};
				} ''
					cp -r "$src" work && chmod -R u+w work && cd work
					patchShebangs bin libexec tests test
					bash ./test --hermetic
					mkdir -p "$out"
				'';
			};
			devShells.${system}.default = pkgs.mkShell {
				packages = tools;
				inherit (shellEnv) DUNE_MUSL_LOADER DUNE_NETCOREDEPS DUNE_GLIBC_LOADER DUNE_GCC_LIB DUNE_LIBPQ DUNE_LUAJIT_CLOSURE;
			};
		};
}
