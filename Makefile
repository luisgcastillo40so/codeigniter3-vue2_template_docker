.PHONY: provision # →php/codeigniter側のプロビジョニング。最初に実行することで環境が整います。
provision:
	make app-build
	make copy-env
	docker compose up -d
	make composer-install
	make vendor-copy
	sleep 20
	make db-fresh
	make test-db-fresh
	docker-compose ps
	@echo ---------------------------------
	@echo "| Go to http://localhost:2525/  |"
	@echo ---------------------------------

.PHONY: app-build-no-cache # →docker image を完全に削除してから0から再作成。
app-build-no-cache:
	docker compose build --force-rm --no-cache

.PHONY: app-build # →docker image を再作成(キャッシュがあれば利用します)
app-build:
	docker compose build

.PHONY: app-up # →docker compose をバックグランドで起動。
app-up:
	docker compose up -d

.PHONY: app-down # →docker compose を終了および停止します。
app-down:
	docker compose down

.PHONY: allclean # →docker compose で作成した全てを停止して削除します。
allclean:
	docker compose down --rmi local --volumes --remove-orphans

.PHONY: app-test # →php test(実際のテスト方法はcodeigniter側に併せて修正してください。
app-test:
	#docker compose exec -e CI_ENV=testing php php test

.PHONY: copy-env # →.env / .env.testing をサンプルからコピーします。
copy-env:
ifeq ($(OS),Windows_NT)
	copy .\src\.env.example .\src\.env
else
	-cp -n ./src/.env.example ./src/.env
	-cp -n ./src/.env.testing.example ./src/.env.testing
endif

.PHONY: db-fresh # →dbのマイグレーションを実施します。
db-fresh:
	make composer-dump-autoload
	docker compose run php php public/index.php  Migrate index

.PHONY: test-db-fresh # →テスト用dbのマイグレーションを実施します。
test-db-fresh:
	make composer-dump-autoload
	docker compose run -e CI_ENV=testing php php public/index.php  Migrate index

.PHONY: compose-install # →composer でのインストールを実施します。
composer-install:
	docker compose exec php composer install --prefer-dist

.PHONY: composer-dump-autoload # →クラスのオートロードを実施します。
composer-dump-autoload:
	docker compose exec php composer dump-autoload

.PHONY: vue-create # →vue createでvueの初期設定を実施します。
vue-create:
	docker compose exec node vue create .
	make node_modules-copy

.PHONY: npm-install # →npm installを実施します。
npm-install:
	docker compose exec node npm install

.PHONY: npm-ci # →npm ci を実施します。
npm-ci:
	docker compose exec node npm ci

.PHONY: npm-serve # →npm ciの後、 npm server を実施します。
npm-serve:
	docker compose exec node mkdir -p /var/www/html/node_modules/.cache
	make npm-ci
	docker compose exec node npm run serve

.PHONY: vendor-copy # →ローカルにある src/vendor 以下を削除後、docker コンテナ内のvendorの内容をsrc/vendor にコピーします。
vendor-copy:
	rm -rf ./src/vendor/**
	docker cp `docker compose ps -q php`:/var/www/html/vendor ./src

.PHONY: node_modules-copy # →ローカルにある src/node_modules 以下を削除後、docker コンテナ内のvendorの内容をsrc/node_modules にコピーします。
node_modules-copy:
	rm -rf ./src/node_modules/**
	docker cp `docker compose ps -q node`:/var/www/html/node_modules ./src

.PHONY: help # →コマンドリストを表示します。
help:                                                                                                                    
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\1 \2/' | expand -t20
