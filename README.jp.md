# Visual Studio Code on EC2

このリポジトリでは、EC2 にホストした VSCode にブラウザからアクセスして利用する方法を紹介します。接続は Session Manager 経由で行うため、認証には IAM 権限が利用されます。また、アクセス先は localhost になります。このリポジトリが紹介する方法は、手元の VSCode から Remote SSH で EC2 インスタンスに接続する方法ではありませんのでご注意ください。

## Features
- ブラウザから VSCode を利用できます
- Node.js 環境がインストールされています
- デフォルトで 128 GB のストレージが用意されています
- AdministratorAccess 相当の権限で aws cli が実行できます
- VSCode をホストする EC2 インスタンスは Private Subnet に属するため、インターネットには晒されていません。接続は Session Manager 経由で行います。

## Prerequirements
- Node.js 実行環境
- [`aws` コマンド](https://aws.amazon.com/jp/cli/) (AWS CDK を実行するため、AdministratorAccess 相当の権限の付与が必要)
- `git` コマンド
- `jq` コマンド (必須ではない。後述する session.sh を実行する場合に必要)

手元に環境を用意するのが難しい場合は [CloudShell](https://console.aws.amazon.com/cloudshell/home) で代替が可能ですが、`session.sh` 以降の手順は手元で行う必要がある点に注意してください。
(SessionManager 経由で localhost にセッションを作成するため。)

## Installation

まずはこのリポジトリを clone してください。

```bash
git clone https://github.com/aws-samples/vscode-on-ec2-for-prototyping
```

アプリケーションは [AWS Cloud Development Kit](https://aws.amazon.com/jp/cdk/)（以降 CDK）を利用してデプロイします。実行には Node.js が必要です。まず、以下のコマンドを実行してください。全てのコマンドはリポジトリのルートで実行してください。

```bash
npm ci
```

CDK を利用したことがない場合、初回のみ [Bootstrap](https://docs.aws.amazon.com/ja_jp/cdk/v2/guide/bootstrapping.html) 作業が必要です。すでに Bootstrap された環境では以下のコマンドは不要です。

```bash
npx cdk bootstrap
```

続いて、以下のコマンドで AWS リソースをデプロイします。

```bash
npx cdk deploy
```

デプロイが完了したら、EC2 インスタンスが作成されたことを[マネージメントコンソール](https://console.aws.amazon.com/ec2/home#Instances)で確認します。
また、その際に Status check が Initializing から checks passed になることをご確認ください。
checks passed になったことが確認できたら、`session.sh` を実行してセッションを作成します。

```bash
./session.sh
```

手元で Unix 系コマンドが使えない場合は、`session.sh` が実行できません。
代わりに、以下のコマンドを実行してください。
Instance ID と Private IP は前述したマネージメントコンソールでも確認可能ですし、`cdk deploy` 時にそれぞれ `VscodeOnEc2ForPrototypingStack.InstanceID`、`VscodeOnEc2ForPrototypingStack.PrivateIP` として出力されます。

```bash
# <> で囲まれた 2 箇所の値は置き換えが必要

aws ssm start-session \
    --target <EC2 インスタンスの Instance ID> \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters "{\"portNumber\":[\"8080\"],\"localPortNumber\":[\"8080\"],\"host\":[\"<EC2 インスタンスの Private IP>\"]}"
```

セッションの作成に成功したら、http://localhost:8080 を開いてください。接続できない場合は [Troubleshooting](#Troubleshooting) をご参照ください。

## Configurations

[cdk.json](/cdk.json) の `context` の値を変更することでいくつかの項目を修正できます。

- `volume` VSCode をホストする EC2 インスタンスのストレージサイズ (GB)
- `nvm` Node.js をインストールする `nvm` のバージョン
- `node` Node.js のバージョン

## Troubleshooting

[こちらの Issue](https://github.com/amazonlinux/amazon-linux-2023/issues/397) で書かれているのと同様の現象が確認されることがあります。**セッションを作成後にブラウザを開いても接続できない場合は、まずこれを疑ってください。**

エラーを確認するためには、まず[マネージメントコンソール](https://console.aws.amazon.com/ec2/home#Instances)を開き、作成した EC2 インスタンスを選択した状態で上部の Connect をクリックします。続いて Session Manager のタブを開き、Connect をクリックします。

ターミナルを開いたら、以下のコマンドを実行してください。EC2 インスタンスを初期化する際に実行したコマンドの実行結果が確認できます。

```bash
sudo cat /var/log/cloud-init-output.log
```

この中で `[Errno 2] No such file or directory: '/var/cache/dnf/amazonlinux-...` というエラーが出ている場合は code コマンドのインストールに失敗しています。その場合は、以下のコマンドで改めてインストールしてください。

```bash
sudo yum install -y code
```

インストールに成功後、以下のコマンドを実行して `code` を起動します。

```bash
sudo systemctl start code-server
```

実行後に再度 `session.sh` でセッションを作成し、ブラウザで接続できることを確認してください。(http://localhost:8080) なお、一度 `code` コマンドをインストールしてしまえば、ブラウザのタブを一度閉じて再度開いた時や、EC2 インスタンスの再起動時、セッションを作成した時などにこれらの手順を再度実行する必要はありません。

## Future works
- [ ] 既存の VPC をインポートできるようにする
- [ ] インスタンスタイプを選択できるようにする

## Cleanup

環境を削除する場合は、以下のコマンドを実行してください。

```
npx cdk destroy
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

