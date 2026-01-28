# Maui - Phoenix LiveView UI Toolkit

## Commands
- **Build**: `mix setup` (deps, assets)
- **Test all**: `mix test`
- **Test single file**: `mix test test/my_test.exs`
- **Test single line**: `mix test test/my_test.exs:42`
- **Failed tests**: `mix test --failed`
- **Assets watch**: `mix dev`

## Architecture
- **lib/maui.ex**: Main module with `use Maui` macro that imports all components
- **lib/maui/**: UI components (Button, Input, Select, Dialog, Dropdown, Alert, Popover, etc.)
- **assets/**: JS hooks and CSS for client-side functionality
- **demo/**: Phoenix app showcasing components (see demo/AGENTS.md for Phoenix guidelines)

## Code Style
- Elixir/Phoenix library targeting LiveView ~> 1.1
- Components use `Phoenix.Component` with `~H` sigil for HEEx templates
- Predicate functions end with `?` (not `is_` prefix)
- Never nest multiple modules in one file
- Use `Enum.at/2` for list index access, never `list[i]`
- Bind block expression results (`if`/`case`/`cond`) to variables
