# Leg C (distribution) — installs the PUBLIC connector artifact from PyPI.
# Complements Formula/thesrc.rb (full CLI from the private product repo, org
# decision pending); this formula ships only the MCP connector, which is a
# zero-business-logic shim over https://api.thesrc.ai.
#
class ThesrcMcp < Formula
  include Language::Python::Virtualenv

  desc "MCP connector for The Source - thin client for api.thesrc.ai"
  homepage "https://thesrc.ai"
  url "https://files.pythonhosted.org/packages/6f/a4/452bc740963f51c2e8045fdef0338616663df052d853427b966ddcf8d4ac/thesrc_mcp-0.5.0.tar.gz"
  sha256 "beb07de2fa63946f05a395586666c5e26f5ba5647cc017b23050209c8cad97b3"
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
