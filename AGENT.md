# Ruby Environment Notes

This project relies on [`chruby`](https://github.com/postmodern/chruby) and [`ruby-install`](https://github.com/postmodern/ruby-install) (both managed from `~/.zshrc`) to select the correct Ruby for Jekyll.

1. **Load your shell profile** – open a new shell or run `source ~/.zshrc`. This exports `CHRUBY_ROOT`, loads the `chruby` helper functions, and runs `chruby` against the version declared in `.ruby-version`.
2. **Confirm the interpreter** – after sourcing, `which ruby` should resolve to `~/.rubies/<version>/bin/ruby`. The repository already contains `.ruby-version` so no manual selection is needed.
3. **Install missing gems** – run `bundle install` inside the project. When the sandbox can’t write under `$HOME`, Bundler falls back to a temp directory automatically; no additional flags are required.
4. **Build or serve the site** – use `bundle exec jekyll build` or `bundle exec jekyll serve --livereload`.

If `bundle exec` complains about missing gems, repeat step 1; it usually means the shell wasn’t sourced so the system Ruby was used instead of the chruby-managed one. Should you ever need to install a fresh Ruby, run `ruby-install ruby <version>` and then re-run `bundle install`.
