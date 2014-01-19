
print_run_info()
{
	echo "Fedora chroot is installed in '${ROOT}'."
	echo "To chroot into Fedora, please run '$0 run' as root."
}

mount_fs()
{
	mount -t proc foo "${ROOT}/proc"
	mount -t sysfs foo "${ROOT}/sys"
	mount -t devtmpfs foo "${ROOT}/dev"
}

unmount()
{
	umount "${ROOT}/"{proc,sys,dev}
}

install()
{
	echo "Installing Fedora chroot to '${ROOT}'..."
	
	mkdir -p "${ROOT}"
	rpm --root "${ROOT}" --initdb
	rpm -ivh --nodeps --root "${ROOT}" "${ROOT}/${FEDORA_RELEASE_RPM}"
	test ! -e /etc/pki || (test -L /etc/pki && sudo rm /etc/pki) || (echo "Error: /etc/pki exists."; exit 1)
	ln -s "${ROOT}/etc/pki" "/etc/pki"
	sleep 0.1
	echo -e "\nFedora packages will be downloaded now. Please be patient, this may take a while."
	yum -y --installroot "${ROOT}" install yum git mingw32-qt5-qtbase mingw32-eigen3 cmake make
	rm "/etc/pki"
	
	mount_fs;
	chroot "${ROOT}" /usr/bin/install.sh
	
	print_run_info;
}

upgrade() 
{
	print_run_info;
}

remove()
{
	echo "Removing Fedora chroot from '${ROOT}'..."
	
	unmount;
	rm -r "${ROOT}"
}

run()
{
	mount_fs;
	chroot "${ROOT}"
}

case "$1" in
"install")
	install;
	;;
"upgrade")
	upgrade;
	;;
"remove")
	remove;
	;;
*)
	run;
	;;
esac
