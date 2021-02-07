#+TITLE: My Vim & Emacs Configs
#+AUTUOR: Yin JiAN
#+DATE: 02.05.2012
#+EMAIL: beamiter@163.com
#+KEYWORDS: Vim, Emacs, LSP
#+LANGUAGE: Vimscript, Eclisp

* *Install vim to support python2/3*

#+BEGIN_SRC shell
./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-python3interp=yes \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk2 --enable-cscope --prefix=/usr

make

sudo make install
#+END_SRC

+with-python3-config-dir+ is deprecated
#+BEGIN_SRC shell
            --with-python3-config-dir=/usr/lib/python3.7/config-3.7m-x86_64-linux-gnu \
#+END_SRC

* *Install python related package*
#+BEGIN_SRC shell
pip install --user flake8 autoflake isort coverage yapf autopep8 pylint
conda install flake8 autoflake isort coverage yapf autopep8 pylint
#+END_SRC

* *Some helpful tips*
1. install *bat* to support highlight color in preview.
2. remember to install acompany *clangd* version with *clang*
   to full lsp support.
