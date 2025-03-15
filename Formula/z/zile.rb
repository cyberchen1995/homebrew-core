class Zile < Formula
  desc "Text editor development kit"
  homepage "https://www.gnu.org/software/zile/"
  # Before bumping to a new version, check the NEWS file to make sure it is a
  # stable release: https://git.savannah.gnu.org/cgit/zile.git/plain/NEWS
  # For context, see: https://github.com/Homebrew/homebrew-core/issues/67379
  url "https://ftp.gnu.org/gnu/zile/zile-2.6.4.tar.gz"
  mirror "https://ftpmirror.gnu.org/zile/zile-2.6.4.tar.gz"
  sha256 "d5d44b85cb490643d0707e1a2186f3a32998c2f6eabaa9481479b65caeee57c0"
  license "GPL-3.0-or-later"
  version_scheme 1

  bottle do
    sha256 arm64_sequoia: "1e8c4e55e5fd847876d83c47dd94ac35c8bb259806cbf287b927f163eadbbbfc"
    sha256 arm64_sonoma:  "2626abe8f48706311b64d18713917ae526357169d1d6fcab0fe4d4bd6c96787d"
    sha256 arm64_ventura: "0cb7cbd3030e94fddfdde2c7117ebd2206df4d63c60f9ac6103f45a80779e522"
    sha256 sonoma:        "42a771caf90019b6ea975f0d672daeaa170edc24bf3fbfeea03f7db2e468372b"
    sha256 ventura:       "2a0bfe55a5ba022a214452812fb48ed1bc322d4676b7f02b2c46eba085a83255"
    sha256 x86_64_linux:  "dad50ecdec4c215137db0a61da5c12164462737ec485e80f6c15c36af9fd06b1"
  end

  depends_on "help2man" => :build
  depends_on "pkgconf" => :build
  depends_on "bdw-gc"
  depends_on "glib"
  depends_on "libgee"

  uses_from_macos "ncurses"

  on_macos do
    depends_on "gettext"
  end

  def install
    # Work around Vala issue https://gitlab.gnome.org/GNOME/vala/-/issues/1408
    # which causes src/eval.vala:87:32: error: incompatible function pointer types passing
    ENV.append_to_cflags "-Wno-incompatible-function-pointer-types" if DevelopmentTools.clang_build_version >= 1500

    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zile --version")
  end
end
