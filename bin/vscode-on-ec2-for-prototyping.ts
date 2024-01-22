#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { VscodeOnEc2ForPrototypingStack } from '../lib/vscode-on-ec2-for-prototyping-stack';

const app = new cdk.App();
new VscodeOnEc2ForPrototypingStack(app, 'VscodeOnEc2ForPrototypingStack', {});
