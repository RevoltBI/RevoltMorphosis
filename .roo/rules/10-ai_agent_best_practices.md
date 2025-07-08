# Best Practices for Working with AI Coding Assistants

This document outlines key principles and best practices for effectively collaborating with AI coding assistants like Roo Code. Following these guidelines will help you maximize productivity, maintain security, and improve your overall development workflow.

## On Context Management

- **Prevent Context Contamination:** Be cautious of context contamination from external, untrusted sources (a form of prompt injection). The AI's responses are heavily influenced by the context it receives.

- **Controlled Context Provisioning:** AI agents that can fetch context from the open internet can be a security risk. It is far safer to provide context in a controlled manner, for example, by adding well-defined documentation files directly to the project repository.

- **Initial Context Gathering:** Invest time at the beginning of a task to provide the AI with the right context. Roo Code's "Architect" mode is specifically designed to facilitate this process, helping the agent understand the project before making changes.

## On Interaction and Workflow

- **Avoid Micromanagement:** Provide clear, high-level goals and let it determine the implementation steps. Avoid giving overly detailed, step-by-step instructions. If you do need to provide step by step instructions repeatedly, consider asking the agent to store the procedure as task in [`.roo/rules/memory-bank/tasks.md`](memory-bank/tasks.md). It should be OK to just ask the agent to "store this as task" (See the [relevant memory bank instructions section](99-memory_bank_instructions.md#add-task)). Or otherwise add persistent rules for the agent to avoid having to micromanage it in the future.

- **Be Thorough in Review:** Consistently review the agent's work. A review doesn't have to be a line-by-line code audit; it can be as simple as asking the agent clarifying questions or requesting explanations for its decisions.

- **Systematize Your Workflow:** Improve efficiency by systematically using rules files, [memory bank files](99-memory_bank_instructions.md#memory-bank-structure), and project [docs](../tasks/add_update_documentation_page.md). This creates a robust knowledge base for the AI to draw from.

- **"Program" Your Agent:** The ultimate goal is to "program" the agent's behavior through the rules, documentation, and memory bank you build within your git repository. This customizes the agent to your specific needs and coding style, saving significant time and effort.

- **Enhance, Don't Replace, Understanding:** An AI agent is not a replacement for understanding your own codebase. On the contrary, it should be used as a tool to *improve* your understanding, helping you see connections and explore the code more effectively.

## On Security and Sandboxing

- **Comprehensive Sandboxing:** It's not enough to run the agent in a devcontainer to protect the host system. The agent's environment should be thoroughly sandboxed to prevent any potential harm to production or other important systems.

- **Principle of Least Privilege:** The credentials used by the agent should have the minimum necessary permissions. For example, when working with a database, it should connect to a separate, sandboxed database with a user that has limited rights. The agent should not be able to cause significant damage, even if it were to behave unexpectedly.

## On Testing and Automation

- **Test-Driven Development (TDD):** When an AI agent writes a significant portion of the code, a strong testing culture is essential. Adopting TDD, where tests are written before the code, is highly recommended.

- **Comprehensive Test Suites:** The agent should have access to a comprehensive test suite, including unit tests, integration tests, and end-to-end tests. These tests serve as a safety net, verifying that the agent's changes are correct and do not introduce regressions.

- **Automated Feedback Loops:** Automated testing enables powerful feedback loops. The agent can be configured to automatically run tests after making changes, analyze the results, and attempt to fix any failures. This creates a more autonomous workflow that requires less direct supervision.
