#!/bin/sh

# ------------------------ install google-authenticator -------------
if [ ! -f /usr/local/lib/security/pam_google_authenticator.so ]; then
	echo "installing google-athenticator PAM module"
	yum -y install pam-devel make gcc-c++ git
	git clone https://github.com/google/google-authenticator-libpam
	git clone https://code.google.com/p/google-authenticator/
	cd ~/google-authenticator-libpam
	./bootstrap.sh
	./configure
	make
	make install
fi
# ------------------------ configure pam ----------------------------
cd /etc/pam.d
mkdir -p ARCHIVE
cp sshd ARCHIVE/sshd-$(date +%d-%m-%Y)
if grep -F -q "pam_google_authenticator.so" sshd ; then
	# line already exists in sshd file
	echo ".so file already added"
else
	echo "adding .so file to /etc/pam.d/sshd"
	sed -i "/#%PAM-1.0/{N;N;a auth       required     /usr/local/lib/security/pam_google_authenticator.so
}" sshd
fi
# ----------------------- configure sshd -----------------------------
if grep -F -q "ChallengeResponseAuthentication yes" /etc/ssh/sshd_config; then
	# line already added
	echo "sshd_config file already done"
else
	echo "adding ** ChallengeResponseAuthentication yes ** to sshd_config"
	sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
fi
service sshd restart	
