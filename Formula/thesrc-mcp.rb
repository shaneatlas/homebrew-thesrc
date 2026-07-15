# Leg C (distribution) — installs the PUBLIC connector artifact from PyPI.
# Complements Formula/thesrc.rb (full CLI from the private product repo, org
# decision pending); this formula ships only the MCP connector, which is a
# zero-business-logic shim over https://api.thesrc.ai.
#
# ACTIVATION: requires thesrc-mcp on PyPI (the-source PR "Leg B" + publish tag).
# After first publish, fill sha256:
#   curl -sL https://files.pythonhosted.org/packages/source/t/thesrc-mcp/thesrc_mcp-0.4.0.tar.gz | shasum -a 256
class ThesrcMcp < Formula
  include Language::Python::Virtualenv

  desc "MCP connector for The Source - thin client for api.thesrc.ai"
  homepage "https://thesrc.ai"
  url "https://files.pythonhosted.org/packages/source/t/thesrc-mcp/thesrc_mcp-0.4.0.tar.gz"
  sha256 "REPLACE_AFTER_FIRST_PYPI_PUBLISH"
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
