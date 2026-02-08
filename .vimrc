"----------------------------------------
" 基本設定
"----------------------------------------
"文字コードをUFT-8に設定
set fenc=utf-8
" バックアップファイルを作らない
set nobackup
" スワップファイルを作らない
set noswapfile
" 編集中のファイルが変更されたら自動で読み直す
set autoread
" 保存されていないファイルがあるときでも別のファイルを開ける
set hidden
" 入力中のコマンドをステータスに表示する
set showcmd
" ビープ音を可視化
set visualbell
" クリップボード共有の有効化
set clipboard=unnamed,autoselect

"----------------------------------------
" 検索設定
"----------------------------------------
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索語をハイライト表示
set hlsearch

"----------------------------------------
" 表示設定
"----------------------------------------
" シンタックスハイライト
syntax on
" カラースキーム
colorscheme pablo
" タイトルを表示
set title
"" 行番号を表示
set number
" 現在の行を強調表示
set cursorline
" 行末のスペースを可視化
set listchars=tab:^\ ,trail:~
" インデント幅
set shiftwidth=2
" タブキー押下時に挿入される文字幅を指定
set softtabstop=2
" ファイル内にあるタブ文字の表示幅
set tabstop=2
" メッセージ表示欄を2行確保
set cmdheight=2
" ステータス行を常に表示
set laststatus=2
" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore
