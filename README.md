## pass clip - Modified Version for MacOS

A modified extension for the Unix password manager [pass](https://www.passwordstore.org/) that allows one to use [fzf](https://github.com/junegunn/fzf) to search for their passwords and copy them to the clipboard.

### Demo
-----------------------------------------
![pass-clip demo](https://lucasburns.xyz/images/clip.gif)

### Installation
-----------------------------------------
```sh
git clone https://github.com/burnsac5040/pass-clip-mac.git
cd pass-clip-mac
make install
```

### Options
-------------------------------------------
```sh
-s, --show     Equivalent to pass show
-t, --term     Search for a term before fzf starts
```

#### Requirements
-------------------------------------------
- [fzf](https://github.com/junegunn/fzf)
- [pass](https://www.passwordstore.org)


#### Original
-------------------------------------------
[ibizaman](https://github.com/ibizaman/pass-clip)
