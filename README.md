# 開発環境構築

## 構築されるもの

- node
    - vue
- php
    - Codeigniter 3
- MySQL 8.0
- Nginx

## 構築手順

### php/codeigniter3 側の環境を構築。

```bash
make provision
```

上記コマンドを実行し、以下の表示が出ればphp/codeigniter側はOKです。

```text
NAME                COMMAND                  SERVICE             STATUS              PORTS
app_db              "docker-entrypoint.s…"   db                  running (healthy)   0.0.0.0:3306->3306/tcp
app_nginx           "/docker-entrypoint.…"   nginx               running             0.0.0.0:2525->80/tcp
app_node            "docker-entrypoint.s…"   node                running
app_php             "docker-php-entrypoi…"   php                 running             0.0.0.0:9000->9000/tcp
---------------------------------
| Go to http://localhost:2525/  |
---------------------------------
```


### 次にnode/vueの環境を構築。

```bash
make vue-create
```

上記コマンドを実行すると作成する vue の環境を確認してくるので適宜答えると、 以下の表示が出ればnode/vue側はOKです。

```text
🎉  Successfully created project html.
👉  Get started with the following commands:

 $ npm run serve
```

### Makefile のコマンド説明

```text
make provision                php/codeigniter側のプロビジョニング。最初に実行することで環境が整います。
make app-build-no-cache       docker image を完全に削除してから0から再作成。
make app-build                docker image を再作成(キャッシュがあれば利用します)
make app-up                   docker compose をバックグランドで起動。
make app-down                 docker compose を終了および停止します。
make allclean                 docker compose で作成した全てを停止して削除します。
make app-test                 php test(実際のテスト方法はcodeigniter側に併せて修正してください。
make copy-env                 .env / .env.testing をサンプルからコピーします。
make db-fresh                 dbのマイグレーションを実施します。(デフォルトではサンプルで作られたものをマイグレーションします)
make test-db-fresh            test用dbのマイグレーションを実施します。(デフォルトではサンプルで作られたものをマイグレーションします)
make composer-install         composer でのインストールを実施します。
make composer-dump-autoload   クラスのオートロードを実施します。
make vue-create               vue createでvueの初期設定を実施します。
make npm-install              npm installを実施します。
make npm-ci                   npm ci を実施します。
make npm-serve                npm ciの後、 npm run serve を実施します。
make vendor-copy              ローカルにある src/vendor 以下を削除後、docker コンテナ内のvendorの内容をsrc/vendor にコピーします。
make node_modules-copy        ローカルにある src/node_modules 以下を削除後、docker コンテナ内のvendorの内容をsrc/node_modules にコピーします。
make help                     コマンドリストを表示します。
```

## 注意事項など

### .env.example/.env.testing.example

- `WEB_FREE_FOLLOW_ADMIN_ENDPOINT` については `WEB_APP_ADMIN_POINT` に変更しています。
- 定義中に memcache / redis についての記述がありますが、これらは docker-compose.yml には記述がありませんでしたので、そのままでは動作しません。
- 同様にメール送信で mailhog というサービスを使う設定になっていますが、これもそのまままでは動作しません。
- AWSの DEFAULT REGION が `us-east-1` になっていますのでご注意ください（参考元のままです）
- `DB_PASSWORD` が直書きされていますが、参考元に沿ったものとなります。

### codeigniter3について

- database.phpは名前変更して database.php.bak としてあり、環境別に production/database.php / development/database.php / testing/database.php にそれぞれ作成してあります。 production と development では中身が同一にしてありますが、本番環境確定時に変更してください。 git ではコミットできないようしてあります。
- 本体は vendor/codeigniter/framework 以下にありますが、application ディレクトリをsrc以下にコピーし、そのディレクトリ内を編集しております。
- pubclic/index.php を修正して vendor/codeigniter/framework と application をそれぞれ見るように修正してあります。
- db migration のサンプルを作成しています。

### php イメージについて

- gd は参考元にありませんでしたのでインストールしていないため、画像編集などは扱えません。
- mbstring は参考元にありませんでしたが、phpではほぼ必須のためインストールしてあります。

### node イメージについて

- node側では webpack, esbuild などどのツールを使うかでコマンドが違いますが、vue create で実施した際に vue2 のデフォルト状態を元に作成しています。
- npm run serve などとした場合に 8000 ポートで待ち受けるのですが、参考元でポート待受が設定されていませんでしたので設定しておりません。

### Makefileについて

- app-build の構成を変更させていただき、プロビジョニングとして新たに make provision を作成してあります。
- vue create で作られる場合を想定して npm run dev を npm run serve に変更しています。またそのままでは最後に Go to http://localhost:2525/ と言う表示が本来なら表示されるはずですが、 npm run serve が表示を抑制されてしまいます。ですので別ターミナルで make npm-serve を打っていただくことにさせていただきました。
- codeigniter では encrypt key generation はコマンドとして存在しないので、参考元にある php artisan key:generate のステップは削除してあります。
- npm-watch および npm-watch-poll については laravel mix の機能ですので削除してあります。
- app-test については実装方法により変わってきますので、コメントアウトしてあります。

### vue/cli について
- コマンドは `docker compose exec node vue --help` で確かめることができます。


## ディレクトリ構成

```text
.
├── Dockerfile                   # php用Dockerfile
├── Dockerfile.node              # node用Dockerfile
├── Makefile                     # 各種コマンドの記述されたMakefile
├── README.md
├── docker-compose.yml           # docker compose v2用
├── etc
│   ├── mysql
│   │   ├── conf.d
│   │   │   └── my.local.cnf
│   │   └── init.d
│   │       └── createdb.sql   # ユーザとデータベース作成用
│   └── nginx
│       └── conf.d
│           └── default.conf
└── src
    ├── application              # codeigniter3のapplicationフォルダ
    │   ├── cache
    │   ├── config
    │   │   ├── development    # 開発環境用設定置き場
    │   │   ├── production     # 本番環境用設定置き場
    │   │   └── testing        # テスト環境用設定置き場
    │   ├── controllers
    │   ├── language
    │   │   ├── english
    │   │   └── japanese       # 日本語メッセージ
    │   ├── migrations
    │   │   └── 20121031100537_add_blog.php # マイグレーションサンプル
    │   ├── models
    │   ├── third_party
    │   └── views
    ├── composer.json
    ├── composer.lock
    ├── node_modules             # 初期は空
    ├── public
    │   ├── favicon.ico
    │   └── index.php           # codeigniter3の公開ファイル
    └── vendor
```
