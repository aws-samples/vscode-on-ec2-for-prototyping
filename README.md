> [!NOTE]
> 日本語のドキュメントは [こちら](/README.jp.md)

# Visual Studio Code on EC2

This repository introduces how to access and use VSCode hosted on EC2 from a browser. The connection is made via Session Manager, so IAM permissions are used for authentication. The access destination will be localhost. Please note that this repository does not introduce connecting from your local VSCode to an EC2 instance via Remote SSH.

## Features
- You can use VSCode from a browser
- Node.js environment is installed
- 128 GB of storage is provided by default
- aws cli can be executed with AdministratorAccess equivalent permissions
- The EC2 instance hosting VSCode belongs to a Private Subnet, so it is not exposed to the internet. The connection is made via Session Manager.

## Prerequisites
- Node.js runtime environment
- [`aws` command](https://aws.amazon.com/cli/) (AdministratorAccess equivalent permissions are required to run AWS CDK)
- `git` command
- `jq` command (not required. Needed when executing session.sh described later)

If it is difficult to prepare the environment locally, [CloudShell](https://console.aws.amazon.com/cloudshell/home) can be used as an alternative, but the steps from `session.sh` onwards need to be performed locally (because a session is created to localhost via SessionManager).

## Installation

First, clone this repository.

```bash
git clone https://github.com/aws-samples/vscode-on-ec2-for-prototyping
```

The application uses the [AWS Cloud Development Kit](https://aws.amazon.com/cdk/)(CDK) for deployment. Node.js is required to run. First, run the following command. Run all commands from the root of the repository.

```bash
npm ci
```

If you have never used CDK before, a [Bootstrap](https://docs.aws.amazon.com/cdk/v2/guide/bootstrapping.html) process is required only the first time. The following command is not required if already bootstrapped.

```bash
npx cdk bootstrap
```

Then deploy the AWS resources with the following command:

```bash
npx cdk deploy
```

After deployment completes, check that the EC2 instance was created in the [management console](https://console.aws.amazon.com/ec2/home#Instances). Also please confirm that the Status check changes from Initializing to checks passed. 

Once checks passed is confirmed, run `session.sh` to create a session:

```bash
./session.sh
```

If Unix-like commands cannot be used locally, run the following command instead. The Instance ID and Private IP can be confirmed in the management console mentioned above, or output when running `cdk deploy` as `VscodeOnEc2ForPrototypingStack.InstanceID` and `VscodeOnEc2ForPrototypingStack.PrivateIP` respectively.

```bash
# Replace the two values enclosed in <>

aws ssm start-session \
    --target <EC2 instance Instance ID> \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters "{\"portNumber\":[\"8080\"],\"localPortNumber\":[\"8080\"],\"host\":[\"<EC2 instance Private IP>\"]}"
```

Once the session is created, open http://localhost:8080 in your browser. If it does not connect, please refer to [Troubleshooting](#Troubleshooting).

## Configurations

The values in the `context` of [cdk.json](/cdk.json) can be modified to change some items.

- `volume` The storage size (GB) of the EC2 instance hosting VSCode
- `nvm` The version of `nvm` used to install Node.js
- `node` The version of Node.js

## Troubleshooting

The same phenomenon described in [this Issue](https://github.com/amazonlinux/amazon-linux-2023/issues/397) may occur. **If the browser cannot connect after creating a session, first suspect this.

To check for errors, first open the [management console](https://console.aws.amazon.com/ec2/home#Instances) and select the created EC2 instance. Then click Connect at the top and open the Session Manager tab and click Connect.

Open a terminal and run the following command. This will show the execution results of the commands run when initializing the EC2 instance:

```bash
sudo cat /var/log/cloud-init-output.log
```

If this shows an error like `[Errno 2] No such file or directory: '/var/cache/dnf/amazonlinux-...`, the code command installation failed. In that case, reinstall with:

```bash
sudo yum install -y code
```

After successful installation, run:

```bash
sudo systemctl start code-server
```

Try creating a session with `session.sh` and connecting in the browser (http://localhost:8080) again. You will no longer need to run these steps again after the initial code installation, such as when closing and reopening the browser tab, or restarting the EC2 instance.

## Future works
- [ ] Make it possible to import existing VPC
- [ ] Allow selecting instance type

## Cleanup

To delete the environment, run the following command:

```
npx cdk destroy
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

