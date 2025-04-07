class FernApi < Formula
  desc "Stripe-level SDKs and Docs for your API"
  homepage "https://buildwithfern.com/"
  url "https://registry.npmjs.org/fern-api/-/fern-api-0.57.17.tgz"
  sha256 "c6dcad3a5b8b5fb62a26622ea43641e66d6268877d96afb440e0427d18a8f6ed"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "29ede10e14c8444515681cb02c8297a608eb97527f8c0ffa50a1dc6ec090a586"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"fern", "init", "--docs", "--org", "brewtest"
    assert_path_exists testpath/"fern/docs.yml"
    assert_match "\"organization\": \"brewtest\"", (testpath/"fern/fern.config.json").read

    system bin/"fern", "--version"
  end
end
