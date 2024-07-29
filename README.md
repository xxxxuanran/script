# scripts

## Basic configuration

### Bash config

```shell
curl -o ~/.bashrc https://raw.githubusercontent.com/xxxxuanran/scripts/master/bashrc
curl -o ~/.bash_aliases https://raw.githubusercontent.com/xxxxuanran/scripts/master/bash_aliases
curl -o ~/.profile https://raw.githubusercontent.com/xxxxuanran/scripts/master/profile
```

### Apt config

```shell
curl -sSL https://raw.githubusercontent.com/xxxxuanran/scripts/master/apt/debian.sh | bash
```

### SSH config

```shell
ssh-keygen -a 732 -t ed25519 -f ./id_ed25519
cat ./id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
mkdir -p /etc/ssh/sshd_config.d/bak
mv /etc/ssh/sshd_config.d/*.conf /etc/ssh/sshd_config.d/bak/
echo "LogLevel VERBOSE" >> /etc/ssh/sshd_config.d/01-logging.conf
passwd -d root
systemctl restart sshd
```

### fail2ban config

```shell
curl -o /etc/fail2ban/jail.local https://raw.githubusercontent.com/xxxxuanran/scripts/master/fail2ban/jail.conf
```


### Firewall config

```shell
curl -sSL https://raw.githubusercontent.com/xxxxuanran/scripts/master/ufw/ufw.sh | bash
```

## Network setup

### Switch to netplan

```shell
curl -sSL https://raw.githubusercontent.com/xxxxuanran/scripts/master/network/netplan.sh | bash
```

 > You can find the more information in the [Debian - Network setup](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html)