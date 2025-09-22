class FernApi < Formula
  desc "Stripe-level SDKs and Docs for your API"
  homepage "https://buildwithfern.com/"
  url "https://registry.npmjs.org/fern-api/-/fern-api-0.78.2.tgz"
  sha256 "ada5713c5d0ceefcc6390095dba3362aebd0128b2b96b027700813d7db52e9c7"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "4ea05e822f9f0047532e718f3616f66bf587ef7989a745e1a5723fc3f440e5cf"
  end

  depends_on "node"

  def install
    # Supress self update notifications
    inreplace "cli.cjs", "await this.nudgeUpgradeIfAvailable()", "await 0"
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    system bin/"fern", "init", "--docs", "--org", "brewtest"
    assert_path_exists testpath/"fern/docs.yml"
    assert_match '"organization": "brewtest"', (testpath/"fern/fern.config.json").read

    system bin/"fern", "--version"
  end
end
