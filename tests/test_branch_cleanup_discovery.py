"""Regression tests for source-only repository declaration discovery."""

import importlib.util
import unittest
from pathlib import Path

SOURCE = Path(__file__).resolve().parents[1] / "scripts/test-branch-cleanup.py"
SPEC = importlib.util.spec_from_file_location("branch_cleanup_tests", SOURCE)
cleanup = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(cleanup)


class DiscoveryTests(unittest.TestCase):
    def test_block_and_line_comments_do_not_create_resources(self):
        source = """/*
resource "github_repository" "commented" {}
*/
// resource "github_repository" "line" {}
# resource "github_repository" "hash" {}
resource /* header comment */ "github_repository" "real" {}
"""
        self.assertEqual(cleanup.repository_resources(source), ["real"])

    def test_comment_markers_inside_strings_preserve_following_resources(self):
        source = r"""locals {
  url = "https://example.invalid/*"
  escaped = "a quote: \" /* not a comment"
}
resource "github_repository" "real" {}
"""
        self.assertEqual(cleanup.repository_resources(source), ["real"])

    def test_heredoc_content_does_not_create_resources(self):
        source = """locals {
  example = <<-DOCUMENT
resource "github_repository" "heredoc" {}
/* and an unmatched comment or quote: "
  DOCUMENT
}
resource "github_repository" "real" {}
"""
        self.assertEqual(cleanup.repository_resources(source), ["real"])

    def test_template_interpolations_can_contain_quotes_and_braces(self):
        source = """locals {
  text = "${format("%s", "/* } ")}"
  literal = "$${not an interpolation} %%{not a directive}"
}
resource "github_repository" "real" {}
"""
        self.assertEqual(cleanup.repository_resources(source), ["real"])

    def test_only_top_level_repository_resource_headers_are_selected(self):
        source = """data "github_repository" "existing" {}
resource "other_kind" "container" {
  resource "github_repository" "nested" {}
}
resource "github_repository" "first" {}
resource "github_repository" "second" {}
"""
        self.assertEqual(cleanup.repository_resources(source), ["first", "second"])

    def test_unterminated_constructs_fail_closed(self):
        for source in ["/* unfinished", '"unfinished', "<<END\nunfinished"]:
            with self.subTest(source=source), self.assertRaises(ValueError):
                cleanup.repository_resources(source)


if __name__ == "__main__":
    unittest.main()
