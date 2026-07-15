# Leg C (distribution) — installs the PUBLIC connector artifact from PyPI.
# Complements Formula/thesrc.rb (full CLI from the private product repo, org
# decision pending); this formula ships only the MCP connector, which is a
# zero-business-logic shim over https://api.thesrc.ai.
#
class ThesrcMcp < Formula
  include Language::Python::Virtualenv

  desc "MCP connector for The Source - thin client for api.thesrc.ai"
  homepage "https://thesrc.ai"
  url "https://files.pythonhosted.org/packages/2b/a3/01e342597e2ecb0dff564f635ed983509acac2ff2dd7128b484699aa398c/thesrc_mcp-0.4.1.tar.gz"
  sha256 "5cbf06160b17ec22fdb639a54ad415a393986b87a65ff8ec1e773921c5c3f505"
  license "MIT"

  depends_on "python@3.13"

  def install
    virtualenv_create(libexec, "python3.13")
    # Pull deps (mcp, httpx, pydantic-settings) from PyPI into the venv
    system libexec/"bin/pip", "install", "thesrc-mcp==#{version}"
    bin.install_symlink libexec/"bin/thesrc-mcp"
    bin.install_symlink libexec/"bin/source-mcp"
  end

  def caveats
    <<~EOS
      Configure your MCP host (stdio transport):
        command: thesrc-mcp
        env:     SOURCE_API_TOKEN=<key from https://api.thesrc.ai/account/keys>

      Or skip local install entirely - remote Streamable HTTP:
        https://api.thesrc.ai/mcp/   (trailing slash required; POST /mcp 307s)

      Claude Code one-liner:
        claude mcp add --transport http source https://api.thesrc.ai/mcp/ \
          --header "Authorization: Bearer $SOURCE_API_TOKEN"
    EOS
  end

  test do
    system libexec/"bin/python", "-c", "import source_mcp"
  end
end
