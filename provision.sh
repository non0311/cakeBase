#!/bin/sh

#httpd インストール
yum -y install httpd

#仮に手動でやるならgit使うならマスト
yum -y install git zip unzip

##### ↓↓↓ データベースの選択 ↓↓↓ #####
# (MariaDB or MySQL 不要な方をコメントアウトする)

### ( ※ MariaDB 採択のケース )

#MariaDB インストール
#yum -y install mariadb mariadb-server

### ( ※ MySQL 採択のケース )

#MariaDBアンインストール
yum -y remove mariadb-libs.x86_64

#mysqlレポジトリ追加
yum -y install http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm

#yum設定変更のためのパッケージのインストール
yum -y install yum-utils

#mysql5.7を無効 にし、5.6を有効にする (5.7だと初期にSQL文をシェルから叩けないため)
yum-config-manager --disable mysql57-community
yum-config-manager --enable mysql56-community

#mysqlインストール (上記の指定により5.6がインストールされる)
yum -y install mysql-community-server

##### ↑↑↑ データベースの選択 ↑↑↑ #####


#epel,remi インストール
yum -y install epel-release
#wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

#php7.0 関連 インストール
yum -y install --enablerepo=remi,epel,remi-php70 php php-intl php-mbstring php-pdo php-mysqlnd
#2016.10.24 ミラーサイトなしの不具合。上記の前に次のコマンドを打つことで解消 yum list --enablerepo=remi,epel,remi-php70 php php-intl php-mbstring php-pdo php-mysqlnd

#php5.6  ※cake2.8〜 php7.0対応している   ※devel と gd モジュール不要かも
#yum -y install --enablerepo=remi,epel,remi-php56 php php-intl php-mbstring php-pdo php-mysqlnd php-devel php-gd

#composer インストール
cd /usr/local/bin
curl -s https://getcomposer.org/installer | php

#composer を使いcakephpライブラリをインストール(詳細をREADMEに追加)
#cakeのソースがgit管理ですでに存在してるが前提となる
##手動手順
##cd /vagrant
##mkdir src
##cd /vagrant/src
##/usr/local/bin/composer.phar create-project --prefer-dist cakephp/app dev_app(任意名)
##これにてsrc以下にcakeアプリが出来る。デフォのgitignore(app/.gitignore)でvendor等が書かれている
##つまり ＝ 毎回シェルで、composerをインストールしてvendorを追加する必要が生まれる
##.gitignoreのapp.phpだけコメントアウトする(git管理にする)
#ここのcd のパスに注意
cd /vagrant/src/dev_app/
yes | /usr/local/bin/composer.phar install

#ドキュメントルート設定 (/vagrant) ln でも cp でも良い
#ln -s /vagrant/cakephp.conf /etc/httpd/conf.d/.

#ドキュメントルート設定 (/var/www/html)
cp /vagrant/httpd_vagrant.conf /etc/httpd/conf.d/

#httpd 起動設定
systemctl start httpd
systemctl enable httpd

#MariaDB MySQL 起動設定 (共通で使える)
systemctl start mysqld
systemctl enable mysqld

#DB作成(SQL文)
mysql -u root -e"
create database cake_base;
grant all on *.* to cakephp@localhost identified by 'cakephp';
use cake_base
create table basetables (
id int unsigned auto_increment primary key,
date datetime,
num int,
result text);
"
