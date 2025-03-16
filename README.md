# vlayusuke-terraform-infrastructure

## Version
|              | Version |
| ------------ | ------- |
| Terraform    | 1.9.8   |
| AWS Provider | 5.88.0  |

## このプロジェクトについて
このプロジェクトは、Web3層で構成する標準的なインターネット向けのWebアプリケーションを構築するために使用するテンプレートです。アプリケーションレイヤにはAWS Fargateを使用することにより、コンテナを用いてアプリケーションを構築することを想定しています。

## 実行する際の注意事項
`../production`配下のAWSリソースを構築する前に、必ず`../maintenance`配下のAWSリソースを先に構築してください。
