# Todo List Contract (planned)

Simple on-chain todo list for demo purposes. Contract is empty today; this doc captures the expected storage and API shape.

## Intended Features
- Add a todo item with title/description/priority.
- Toggle completion status.
- List todos for a principal.
- Optional: delete/archival of items.

## Draft API
- `add (title (string-ascii 64)) (details (string-ascii 256)) (priority uint)` → creates entry for sender.
- `complete (id uint)` → marks as done.
- `remove (id uint)` optional to delete; could instead mark archived.
- `list (who principal)` read-only to fetch caller or any principal's items.

## Proposed State
- `todos` map keyed by `{owner, id}` storing title, details, priority, completed bool, created-at, updated-at.
- `next-id` map per owner to track next counter.

## Events
- `add`, `complete`, `remove` with owner and id to support indexing.

## Implementation TODOs
- Implement CRUD in `contracts/todo-list.clar` with sensible size limits and ASCII string enforcement.
- Replace example Vitest with cases for add, complete, remove, list pagination.
- Document gas considerations for large strings and item counts.

## Notes
- Keep strings reasonably small to avoid exceeding Clarity size limits; current suggestion: title 64, details 256.
- Consider per-owner item cap to avoid unbounded storage.
- Use stable ids per owner to keep UI caches simple; avoid reindexing on delete by leaving gaps.
