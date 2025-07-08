When using the execute_command tool, make sure you run them in the correct working directory.  Prefer directly specifying the working directory in the tool call over using the `cd` command to change it.

Wrong:
<execute_command>
<command>cd integration_tests && ./run_integration_tests.sh</command>
</execute_command>

Correct:
<execute_command>
<command>./run_integration_tests.sh</command>
<cwd>/workspaces/RevoltMorphosis/integration_tests</cwd>
</execute_command>
