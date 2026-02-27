# Prerequisites

Get [Neovim](https://neovim.io/) from your favorite package manager or follow instructions on the website.

Then run following to copy over configuration.

```bash
git clone https://github.com/wg-romank/blogs.git ~/.config/nvim/
```

If you had any custom configuration previously it helps to clean up caches to ensrue nothing funny is happening behind the sceneces.

```
rm -rf ~/.config/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim
```

If that's too much, try using custom `NVIM_APPNAME`

```
alias vim='NVIM_APPNAME=nvim-custom nvim'
```

And copy files to corresponding directory.


```bash
git clone https://github.com/wg-romank/blogs.git ~/.config/nvim-custom/
```
