# AWS Infrastructure Management

These Ansible roles create the infrastructure over AWS using Ansible and include

 * VPC
 * EC2 Key Pair
 * Security Groups
 * EC2 instances
 * ELB

You will need

 * [Ansible 2.0+](https://ansible.com)
 * Python Boto
 * An AWS account with Admin rights

Ansible uses the python-boto library to call the AWS API and will need your AWS
credentials. Create a .boto file under your user directory with the following.

```
[Credentials]
aws_access_key_id = <your_access_key_here>
aws_secret_access_key = <your_secret_key_here>
```

If you are using Mac OSX with Homebrew (which is how most of the
development here is done) it is important to remember Ansible assumes
`/usr/bin/python` and depending on your setup Homebrew's python and pip will be
at `/usr/local/bin/python`.
