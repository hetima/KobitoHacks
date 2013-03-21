#KobitoHacks


Kobit.app でプレビューにローカル画像を表示する SIMBL プラグインです。[EasySIMBL](https://github.com/norio-nomura/EasySIMBL/) などで読み込んでください。勢いで作ったのでソースかなり適当です。
ファイル連携している場合相対パスで記述できます。ただし「../」とかやって上のフォルダは辿れません。同じフォルダかサブフォルダ限定です。

特定のフォルダに画像を集めて、
```
defaults write com.qiita.Kobito KobitoHacksResourcePath "/path/to/images"
```
と指定すればそのフォルダからの相対パスで読み込みます（ただし「../」とかｒｙ）。ファイル連携していないアイテムでも有効です。ファイル連携している場合両方の場所に同名ファイルがあると連携場所の方が優先されます。

記事が出来上がったつもりで投稿しても当然画像はアップロードされないと思うのでご注意を。

#Download
ビルド済みのバイナリは <http://hetima.com/tmp/KobitoHacks.zip> に

#Specifications
Kobito.app の WebView は CSS などを読み込むために Kobito.app/Contents/Resources が baseURL になっています。resourceLoadDelegate が空いていたので、そこで NSURLRequest を変換しています。

SIMBL のロードタイミングが遅いので、最初に開いているプレビューには適用されません。

Kobit 1.2.0 で動作確認

#License
MIT License

(C)hetima