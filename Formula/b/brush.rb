class Brush < Formula
  desc "Bourne RUsty SHell (command interpreter)"
  homepage "https://github.com/reubeno/brush"
  url "https://github.com/reubeno/brush/archive/refs/tags/brush-shell-v0.2.22.tar.gz"
  sha256 "ea32dd57534b446edda66ed215325d07c10cf6f357b3b6272081dab853968be4"
  license "MIT"
  head "https://github.com/reubeno/brush.git", branch: "main"

  livecheck do
    url :stable
    regex(/brush-shell[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "66ea36d90bfe2fa69a0d50d6f6c2657e9d16d49eb2b8011f559fee1141cf547e"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "22939d1b2fc4b6e363e24346b27f491c9855cc0dae1a6da166011e22820af942"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "581177a84ce4ff3370761f073cbd484d2e1ad82616422ec4c10deb4e3d87243c"
    sha256 cellar: :any_skip_relocation, sonoma:        "9df828b5b2be7725a7a5d63325971345e175d784c7ba5300fa6a5dafe723130d"
    sha256 cellar: :any_skip_relocation, ventura:       "804020919b073d8ccbfdc00e42aedc88d9163624db2c7100037730f6d56729de"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "0ef16c59c2c7abdd38a62463f05488bbd11816e2aee61916429342824430553f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "2b25c00f06d580a8c3616cf81a3148f72f91a6fb374977a502ee6c99746812d5"
  end

  depends_on "rust" => :build

  # Fix to get correct exit code for the version and help commands, should be removed in next release
  # PR ref: https://github.com/reubeno/brush/pull/667
  patch do
    url "https://github.com/reubeno/brush/commit/d4e09d98abf95f5a941ea8709b93805c9523994b.patch?full_index=1"
    sha256 "51b36a680380b41a1f9703035a3198ea0b3d7bdb66e1762d4e219fd7715a61f2"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "brush-shell")
  end

  test do
    assert_match "brush", shell_output("#{bin}/brush --version")
    assert_equal "homebrew", shell_output("#{bin}/brush -c 'echo homebrew'").chomp
  end
end
