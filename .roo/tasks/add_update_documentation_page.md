# Add/Update Documentation Page

A guide for converting external documentation into optimized, project-specific markdown files.
This task involves taking a documentation page, either from a complex prompt or a URL, and converting it into a clean, LLM-agent-optimized markdown file. The goal is to reduce token count by removing irrelevant information and complex formatting, while keeping the content readable for humans. The final markdown file should be stored in the `.roo/docs` directory, organized by topic (e.g., `.roo/docs/dbt/`, `.roo/docs/bigquery/`).

**Files to modify:**
-   `.roo/docs/<topic>/<new_doc_file>.md` - The new or updated documentation file.
-   [`.roo/rules/01-documentation_toc.md`](../01-documentation_toc.md) - The table of contents for all documentation.

**Steps:**
1.  **Analyze Input:** Determine if the input is a raw text/markdown prompt or a URL.
2.  **Fetch Content:** If a URL is provided, use a tool like `curl` to download the content.
3.  **Optimize Content:**
    -   Read the fetched or provided content.
    -   Identify and remove irrelevant sections (e.g., website navigation, ads, verbose examples).
    -   Simplify formatting (e.g., convert complex tables to simple markdown tables or lists).
    -   Rewrite content to be more concise and direct, focusing on the key information.
    -   Ensure code blocks are correctly formatted.
4.  **Determine File Path:** Decide on an appropriate subdirectory and filename within the `.roo/docs` directory based on the content's topic.
5.  **Write File:** Write the optimized markdown content to the new file path.
6.  **Update TOC:** Add a new entry to [`.roo/rules/01-documentation_toc.md`](../01-documentation_toc.md) pointing to the newly created documentation file.
7.  **Review:** Read the new file and the updated TOC to ensure correctness.

**Important notes:**
-   The primary goal is token optimization for an LLM agent, but human readability is still important.
-   Be mindful of the project's existing documentation structure in the `.roo/docs` directory.
-   Always update the Table of Contents ([`01-documentation_toc.md`](../01-documentation_toc.md)) so the new documentation is discoverable.
