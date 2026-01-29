"curl -fLo ~/.vim/autoload/plug.vim --create-dirs "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"vim下载和编译安装
"git clone git@github.com:vim/vim.git
"cd vim/
"./configure --with-features=huge --enable-pythoninterp --enable-rubyinterp --enable-luainterp --enable-perlinterp --with-python-config-dir=/usr/lib/python2.7/config/ --enable-gui=gtk2 --enable-cscope --prefix=/usr
"make
"make install

" 让配置变更立即生效
autocmd BufWritePost $MYVIMRC source $MYVIMRC

" option-list, :h option-list

"编码设置  
set encoding=utf-8
set fencs=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936  

"语言设置  
set langmenu=zh_CN.UTF-8
set helplang=cn

set cmdheight=2

set noeb  " 去掉输入错误的提示声音  
set confirm " 在处理未保存或只读文件的时候，弹出确认  
set nocompatible            " 关闭 vi 兼容模式
set backspace=indent,eol,start
syntax enable               " 开启语法高亮功能
syntax on                   " 自动语法高亮
set number                  " 显示行号
set cursorline              " 突出显示当前行     cul
"set cursorcolumn           " 高亮当前列        cuc
set ruler                   " 打开状态栏标尺
set autochdir               " 自动切换当前目录为当前文件所在的目录
"set backupcopy=yes         " 设置备份时的行为为覆盖
set ignorecase smartcase    " 搜索时忽略大小写，但在有一个或以上大写字母时仍保持对大小写敏感
"set nowrapscan             " 禁止在搜索到文件两端时重新搜索
set incsearch               " 输入搜索内容时就显示搜索结果
set hlsearch                " 搜索时高亮显示被找到的文本
set noerrorbells            " 关闭错误信息响铃
set visualbell              " 视觉提示
set smartindent             " 开启新行时使用智能自动缩进
set noswapfile              " 关闭交换文件
set nobackup                " 关闭备份文件
set nowritebackup
set history=1024
"set paste                   " 粘贴时保持格式
set nowrap                  " 禁止折行
set fillchars=vert:\ ,stl:\ ,stlnc:\  "在被分割的窗口间显示空白，便于阅读
set fileformat=unix
set showmatch               " 高亮显示匹配的括号
set matchtime=10            " 高亮显示匹配的括号时间
set nofoldenable            " 默认关闭代码折叠
set autoread                " 自动加载外部修改
set showcmd                 " 状态栏显示当前执行的命令
set showmode
set laststatus=2            " 总是显示状态栏

set listchars=tab:»■,trail:■ "行尾有多余的空格（包括 Tab 键），该配置将让这些空格显示成可见的小方块
set list

set wildmenu                " Vim 命令行提示, 自身命令行模式智能补全
set wildmode=longest:list,full

filetype on                 " 开启文件类型侦测
filetype plugin indent on   " 根据侦测到的不同类型加载对应的插件
filetype indent on          " 自适应不同语言的智能缩进

set autoindent              " 继承前一行的缩进方式，特别适用于多行注释
set expandtab               " 将制表符扩展为空格
set shiftwidth=4            " 设定 << 和 >> 命令移动时的宽度为 4
set softtabstop=4           " 使得按退格键时可以一次删掉 4 个空格
set tabstop=4               " 设定 tab 长度为 4

set ttyfast                 " Improves smoothness of redrawing 
set lazyredraw              " Don't redraw while executing macros (good performance config)

" set foldmethod=indent  " 基于缩进进行代码折叠
set foldmethod=syntax   " 基于语法进行代码折叠
set nofoldenable        " 启动 vim 时关闭折叠代码

set whichwrap=h,l,b,s,<,>,[,]

set nospell               " turn spell check off

" set gcr=a:block-blinkon0 " 禁止光标闪烁

" set guifont=YaHei\ Consolas\ Hybrid\ 11.5
" set guifont=Courier_New:h11:cANSI  " 设置字体
" set guifontwide=新宋体:h11:cGB2312

" 可以在buffer的任何地方使用鼠标（类似office中在工作区双击鼠标定位）  
" set mouse=a  
" set selection=exclusive  
" set selectmode=mouse,key

set clipboard=exclude:.* " 加快vim加载

set undofile
set undodir=~/.vim/.undo/

set foldmethod=diff

let mapleader=","  "set leader

" 定义快捷键到行首和行尾
nmap LB 0
nmap LE $

" 复制当前文件/路径到剪贴板
nmap <Leader>fn :let @+=substitute(expand("%"), "/", "\\", "g")<CR>
nmap <Leader>fp :let @+=substitute(expand("%:p"), "/", "\\", "g")<CR>

nmap <Leader>p "+p   " 设置快捷键将选中文本块复制至系统剪贴板
vnoremap <Leader>y "+y  " 设置快捷键将系统剪贴板内容粘贴至vim


" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

inoremap <leader><leader>w <Esc>:w<CR>
inoremap jj <Esc>`^

cnoremap w!! w !sudo tee % >/dev/null

" Smart way to move between windows
" nnoremap <C-j> <C-W>j
" nnoremap <C-k> <C-W>k
" nnoremap <C-h> <C-W>h
" nnoremap <C-l> <C-W>l

" map <leader>1 :b 1<CR>
" map <leader>2 :b 2<CR>
" map <leader>3 :b 3<CR>
" map <leader>4 :b 4<CR>

" 配合：Plug 'chxuan/change-colorscheme'
map <F9> :NextColorScheme<CR>
map <F8>  :PreviousColorScheme<CR>

" Avoid garbled characters in Chinese language windows OS
let $LANG='en'
set langmenu=en
if has("win16") || has("win32")
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim
endif

set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
endif



" ==> plugin -----------------------------------------------------------------
if has("win16") || has("win32")
else
    if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.GitHub.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
endif

" plugins {{{
call plug#begin('~/.vim/plugins')
    Plug 'chxuan/change-colorscheme' " 配色切换
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'altercation/vim-colors-solarized'
    Plug 'NLKNguyen/papercolor-theme'

    Plug 'preservim/nerdcommenter'
    Plug 'tpope/vim-unimpaired' "遍历 ]b和[b循环遍历缓冲区 ]l和[l遍历位置列表 ]q和[q遍历快速修复列表 ]t和[t遍历标签列表 ]f和[f循环遍历同一目录中的文件，并打开为当前缓冲区。
    Plug 'easymotion/vim-easymotion'
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'mileszs/ack.vim'
    Plug 'junegunn/goyo.vim', {'for': 'markdown'}
    Plug 'sjl/gundo.vim'
    " Plug 'Valloric/YouCompleteMe', { 'do': './install.py' } " sudo apt-get install cmake llvm
    " Plug 'tpope/vim-fugitive'
    " Plug 'vim-syntastic/Syntastic'
    " Plug 'tpope/vim-vinegar'  "Netrw

call plug#end()
"}}}


let g:ctrlp_working_path_mode = "ra"
noremap <leader>p :CtrlP<cr>



" ==> 配色 -----------------------------------------------------------------
if has('gui_running')
    set background=dark
else
    set background=dark
    set t_Co=256 " make sure our terminal use 256 color
    let g:solarized_termcolors = 256
endif
colorscheme PaperColor
" colorscheme solarized
" colorscheme delek






" ==> FAQ -----------------------------------------------------------------
" ctags -R: 生成tag文件，-R表示也为子目录中的文件生成tags
" :set tags=path/tags -- 告诉ctags使用哪个tag文件
" :tag xyz -- 跳到xyz的定义处，或者将光标放在xyz上按C-]，返回用C-t
" :stag xyz -- 用分割的窗口显示xyz的定义，或者C-w ]， 如果用C-w n ]，就会打开一个n行高的窗口
" :ptag xyz -- 在预览窗口中打开xyz的定义，热键是C-w }。
" :pclose -- 关闭预览窗口。热键是C-w z。
" :pedit abc.h -- 在预览窗口中编辑abc.h
" :psearch abc -- 搜索当前文件和当前文件include的文件，显示包含abc的行。

" C-x C-s -- 拼写建议。
" C-x C-v -- 补全vim选项和命令。
" C-x C-l -- 整行补全。
" C-x C-f -- 自动补全文件路径。弹出菜单后，按C-f循环选择，当然也可以按 C-n和C-p。
" C-x C-p 和C-x C-n -- 用文档中出现过的单词补全当前的词。 直接按C-p和C-n也可以。
" C-x C-o -- 编程时可以补全关键字和函数名啊。
" C-x C-i -- 根据头文件内关键字补全。
" C-x C-d -- 补全宏定义。
" C-x C-n -- 按缓冲区中出现过的关键字补全。 直接按C-n或C-p即可。

" help xxx + ctrl_D,  ctrl + ] 打开链接
" Netrw :Ex, :Vex ：Sex :Lex
" 寄存器：  ctrl + r 允许在插入模式和命令模式下粘贴缪戈寄存器的内容，
" %存储了当前文件名，#存储了上次打开的文件名，.中为最后插入的文本，:为最后执行的命令
" *系统的主粘贴板（windows/macos默认粘贴板，Linux为鼠标选择内容） + windows(ctrl+c、ctrl+v)
" set clipboard=unamed，unnamedplus 「 复制到系统寄存器(*, +)
" %USERPROFILE%
" vim --startuptime startuptime.log 分析启动时间， :profile start profile.log  :profile func* :profile file* 分析运行速度
" set foldmethod=indent  对于浏览大型文件
" 模式： normal 
" command line mode  ctrl+p/n  ctrl+f/ctrl+c
" 插入模式： ctrl+o 执行命令， ctrl+r 粘贴寄存器
" 可视模式 （如果需要选择的文本不属于已定义的文本对象（单词、句子sentence和段落paragraph等），则这个模式非常有用， gv 上一次select
" terminal 模式
" 命令映射， help index/  :map :rem
" :help complete  ctrl+n/ctrl+p   ctrl+o - ctrl+i/ctrl+j/ctrl+f
" sudo apt-get install ctags / ctags -R / set tags=tags;
" help undo-tree
" vimdiff dp(cur->other)/do(cur<-other) [c ]c / :diffu 
" 快速恢复列表： :cnext :copen :cprev :cw ; 位置列表 :ln :lp :lopen ::lclose  :lwindow
" :make -> :compiler/:set errorformat/:set makeprg
" 区间： 区间范围用；组合  :help comdline-ranges  例如：:12;/dog/s/animal/creature/g
" 精确匹配 animal animals  /\<animal\> 
" arg  :argdo :args  :set hidden  :wa  :argdo execute ":normal @a" | update
" :help oridinary-atom    :help characters-classes  :help multi \_ ^ $ \< \> \| \(\)
" :qaq   :@a  :@@  :new  "ap  _"ay$
