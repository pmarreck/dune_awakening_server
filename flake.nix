{
	description = "Dune Awakening Linux hosting investigation and pinned operator tools";
	inputs = {
		# Reuse the host configuration's existing package revision without changing it.
		nixpkgs.url = "github:NixOS/nixpkgs/c0a89c379b4ac67c7b13b051ddbd4e0dbc9b0eaf";
		# Locale-free, reproducible line sorting (`collate`) for scripts and tests.
		romantic_collation.url = "github:pmarreck/romantic_collation";
	};
	outputs = { self, nixpkgs, romantic_collation }:
		let
			system = "x86_64-linux";
			# Only steamcmd and its steam-unwrapped bootstrap are admitted as unfree; review any addition.
			pkgs = import nixpkgs {
				inherit system;
				config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "steamcmd" "steam-unwrapped" ];
			};
			tools = [
				pkgs.bash pkgs.coreutils pkgs.curl pkgs.git pkgs.jq pkgs.openssl
				(pkgs.python312.withPackages (ps: [ ps.psycopg2 ps.python-dateutil ps.debugpy ])) pkgs.rsync pkgs.gnumake pkgs.ripgrep
				pkgs.gnugrep pkgs.gnused pkgs.gawk pkgs.findutils
				pkgs.gnutar pkgs.gzip pkgs.util-linux pkgs.procps pkgs.cacert
				romantic_collation.packages.${system}.default
				pkgs.steamcmd pkgs.postgresql_17 pkgs.rabbitmq-server pkgs.socat pkgs.patchelf pkgs.iproute2 pkgs.systemd
				# Mirrors the host's global luajit.withPackages set so scripts behave the same inside and outside the dev shell.
				(pkgs.luajit.withPackages (ps: with ps; [
					alt-getopt basexx busted cjson lpeg lua_cliargs luabitop luacheck
					luafilesystem luasocket luasystem penlight sqlite
				]))
			];
			musl = pkgs.pkgsMusl;
			# Libraries that Funcom's musl self-contained .NET apps (Director, TextRouter) load via RUNPATH $ORIGIN/netcoredeps.
			netcoredeps = pkgs.runCommand "dune-musl-netcoredeps" { } ''
				mkdir -p "$out"
				ln -s ${musl.musl}/lib/libc.so "$out/libc.musl-x86_64.so.1"
				ln -s ${musl.stdenv.cc.cc.lib}/lib/libstdc++.so.6 ${musl.stdenv.cc.cc.lib}/lib/libgcc_s.so.1 "$out/"
				ln -s ${musl.zlib}/lib/libz.so.1 "$out/"
				ln -s ${musl.icu}/lib/libicu*.so* ${musl.openssl.out}/lib/libssl.so* ${musl.openssl.out}/lib/libcrypto.so* "$out/"
			'';
			dotnetEnv = {
				DUNE_MUSL_LOADER = "${musl.musl}/lib/ld-musl-x86_64.so.1";
				DUNE_NETCOREDEPS = "${netcoredeps}";
				DUNE_GLIBC_LOADER = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
				DUNE_GCC_LIB = "${pkgs.stdenv.cc.cc.lib}/lib";
				DUNE_LIBPQ = "${pkgs.postgresql_17.lib}/lib/libpq.so.5";
			};
		in {
			checks.${system} = {
				operator-tools = pkgs.runCommand "dune-operator-tools-check" {
					nativeBuildInputs = tools;
					inherit (dotnetEnv) DUNE_MUSL_LOADER DUNE_NETCOREDEPS DUNE_GLIBC_LOADER DUNE_GCC_LIB DUNE_LIBPQ;
					src = pkgs.lib.fileset.toSource {
						root = ./.;
						fileset = pkgs.lib.fileset.unions [ ./test ./tests ./bin ./libexec ./.envrc ];
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
				inherit (dotnetEnv) DUNE_MUSL_LOADER DUNE_NETCOREDEPS DUNE_GLIBC_LOADER DUNE_GCC_LIB DUNE_LIBPQ;
			};
		};
}
