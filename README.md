# nirila's dotfiles

自分用

書いている事
- terminalの表記

## install

```sh
bash .bin/install.sh            # dotfiles の symlink + CLI ツール導入
bash .bin/install.sh --no-tools # symlink だけ(ツール導入はスキップ)
bash .bin/install_tools.sh      # ツール導入だけ(冪等・再実行OK)
```

### 入るツール (`.bin/install_tools.sh`)

- [Claude Code](https://github.com/anthropics/claude-code): 公式インストーラ (既にあればスキップ)
- [fzf](https://github.com/junegunn/fzf): Ctrl-R で履歴検索 / Ctrl-T でファイル検索 (git で最新版を導入)
- [zoxide](https://github.com/ajeetdsouza/zoxide): 賢い cd (`z <dir>`)
- [fd](https://github.com/sharkdp/fd) / [bat](https://github.com/sharkdp/bat) / [eza](https://github.com/eza-community/eza) / [ripgrep](https://github.com/BurntSushi/ripgrep): find / cat / ls / grep のモダン版 (apt、Ubuntu では fdfind/batcat を alias で吸収)
- [lazygit](https://github.com/jesseduffield/lazygit): git の TUI (`lg`、GitHub リリースから ~/.local/bin に導入)

## ref
- https://qiita.com/yutkat/items/c6c7584d9795799ee164