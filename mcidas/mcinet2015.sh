#!/bin/sh
#
# Copyright(c) 1998, Space Science and Engineering Center, UW-Madison
# Refer to "McIDAS Software Acquisition and Distribution Policies"
# in the file  mcidas/data/license.txt
#
#	$Id: mcinet.sh,v 1.42 2008/02/28 21:47:03 davep Exp $
#
#-------
# This script sets up the inetd configuration files.
# You must run it as root (Administrator), and you must give the server
# account name as the last command-line argument.
#-------

#-------
# get system type and revision
#-------
uname_s=`uname -s`
uname_r=`uname -r`

#-------
# set port number for mcserv
#-------
mcidas_port=112

#-------
# set xinet directory (for Linux 7.X+ systems that support it)
#-------
xinet_dir=/etc/xinetd.d

#-------
# set launchd directory (for Darwin systems that support it)
#-------
launchd_dir=/Library/LaunchDaemons

#-------
# record the basename of the script
#-------
argv0=`basename $0 .sh`

#-------
# check user
#-------
if [ "$1" != "list" ]; then
	if [ "$uname_s" != "Interix" ]; then
		case `id`
		in
		'uid=0('*)
			;;
		*)	echo "$argv0: ERROR: must have root privilege to run this script"
			exit 1
			;;
		esac
	else
		case `id`
		in
		*'Administrator'*)
			;;
		*)	echo "$argv0: ERROR: must have Administrator privilege to run this script"
			exit 1
			;;
		esac
		mcidas_home=${mcidas_home:-/home/mcidas}
	fi
fi

usage="
To configure inetd to allow remote access to the server account's
files, run the command

	sh ./$argv0.sh install server-account-name

To undo this, run the command

	sh ./$argv0.sh uninstall server-account-name

To list installed McIDAS services, run the command

	sh ./$argv0.sh status

To restart the service control process, run the command

	sh ./$argv0.sh restart
"

#-------
# are we using xinetd
#-------

use_xinet=0
use_launchd=0
case $uname_s
in
AIX	|\
HP-UX	|\
IRIX	|\
IRIX64	|\
OSF1	|\
SunOS	|\
Interix	)
	;;
Linux)	if	[ -d "$xinet_dir" ]; then
		use_xinet=1
	fi
	;;
Darwin)	if	[ -d "$xinet_dir" ]; then
		use_xinet=1
	fi
	if	[ -x /sbin/launchd -a -x /bin/launchctl ]; then
		use_xinet=0
		use_launchd=1
	fi
	;;
*)	echo "$argv0: ERROR: '$uname_s': unknown system type"
	;;
esac

#-------
# are we running on Solaris 10
#-------

if [ "$uname_s" = "SunOS" ]; then
	case $uname_r
	in
	5.1*)
		use_solaris10=1
		;;
	*)
		use_solaris10=0
	esac
fi

#-------
# parse command line
#-------
case $#
in
1)	case $1
	in
	status)
		act=status
		;;
	list)
		act=status
		;;
	restart)
		act=restart
		;;
	*)
		act=install
		mcoper="$1"
	esac
	;;
2)	case $1
	in
	install)
		act=install
		;;
	uninstall)
		act=uninstall
		;;
	status)
		act=status
		;;
	list)
		act=status
		;;
	restart)
		act=restart
		;;
	*)	echo "$usage"
		exit 1
		;;
	esac
	mcoper="$2"
	;;
*)	echo "$usage"
	exit 0
	;;
esac

#-------
# discover home directories of mcidas account and server account
#-------
#mcidas_home
#mcoper_home

for acct in mcidas $mcoper
do
	if [ "$act" = "status" -o "$act" = "restart" ]; then
		break;
	fi

	if [ "$uname_s" != "Interix" ]; then
		if [ "$uname_s" = "Darwin" ]; then
			HAS_NIUTIL=`which niutil`
			if [ -n "${HAS_NIUTIL}" ]; then
				set X `niutil -read . /users/$acct |grep home: |awk '{print $2}'`
			else
				set X `dscl . -read /users/$acct |grep HomeDirectory: |awk '{print $2}'`
			fi
		else
			set X `sed -n "/^$acct:/s,.*:\([^:]*\):[^:]*$,\1,p" /etc/passwd`
		fi
		shift

		case $1 in
		/*)     ;;
		*)	set X `csh -f -c "echo ~$acct" 2>/dev/null`
			shift
			;;
		esac
	else
		set X `echo /home/${acct}`
		shift
	fi

	eval "${acct}_home='$1'"

	# make sure the accounts exist

	case $1
	in
	'')	echo "$argv0: ERROR: the '$acct' account does not exist!"
		exit 1
		;;
	esac

	if	[ ! -d "$1" ]
	then	echo "$argv0: ERROR: the '$acct' account does not have a home directory!"
		exit 1
	fi
done
eval "mcoper_home=\"\$${mcoper}_home\""

# Location of mcservsh program.
mcservsh_default="$mcidas_home/bin/mcservsh"

#echo "mcidas_home='$mcidas_home'"
#echo "mcoper_home='$mcoper_home'"
#echo "mcservsh_default='$mcservsh_default'"

if [ "$uname_s" = "Darwin" ]; then
	unset McINST_ROOT
fi

if [ "$uname_s" != "Interix" ]; then
	case $McINST_ROOT in
	/*)	mcservsh="$McINST_ROOT/bin/mcservsh"
		;;
	*)	mcservsh="$mcservsh_default"
		mcservsh_default=	# zero out the default
		;;
	esac
else
	mcservsh="$mcservsh_default"
fi

#-------
# check for xinetd
#-------
if [ $use_xinet -ne 0 -a "$uname_s" != "Darwin" ]; then
	xinet_run=`service xinetd status |grep running`
	if [ -z "$xinet_run" ]; then
		echo "$argv0: ERROR: xinetd needs to be restarted with the command:"
		echo ""
		echo "	service xinetd restart"
		echo ""
		exit 1
	fi
fi

#-------
# Do $services - make sure that it contains the correct line, or remove
# that line.
#-------
# services - the name of the TCP services file
services=/etc/services

for f in $services
do
	if	[ ! -f "$f" ]; then
		echo "$argv0: ERROR: $f: system has no such file"
		exit 1
	fi
done

no_mcidas=`grep "[	 ]$mcidas_port.tcp" $services |grep -v "^mcidas" |grep -v "^#.*" |awk '{ print $1 }'`

do_mcidas=1
if [ ! -z "$no_mcidas" -a "$act" = "install" ]
then
	echo "$argv0: ERROR: Port $mcidas_port already in use by $no_mcidas"
	echo "$argv0: INPUT: Override $no_mcidas? (yes/no): "
	read CONTYN
	case $CONTYN
	in
	y*)	do_mcidas=1
		;;
	*)	do_mcidas=0
		;;
	esac
fi

mcline="mcidas		$mcidas_port/tcp	# McIDAS ADDE port"
mcpat="^mcidas[ 	][ 	]*$mcidas_port.tcp"

set X `grep "$mcpat" $services | wc -l`; shift
case $1
in
0)	case $act
	in
	install)
		if [ $do_mcidas -ne 0 ]; then
			if	[ ! -z "$no_mcidas" ]; then
				echo "$argv0: $services: mcidas: commenting out $no_mcidas lines"
				if	ed $services <<-EOF >/dev/null 2>&1
					/^$no_mcidas.*tcp/
					s/$no_mcidas/#$no_mcidas/
					.
					w
					q
					EOF
				then	:
				else	echo "$argv0: ERROR: edit of $services has failed"
					exit 1
				fi
			fi

			echo "$argv0: $services: mcidas: adding service lines"
			if	ed $services <<-EOF >/dev/null 2>&1
				\$
				a
				$mcline
				.
				w
				q
				EOF
			then	:
			else	echo "$argv0: ERROR: edit of $services has failed"
				exit 1
			fi
		fi
		;;
	uninstall)
		echo "$argv0: $services: mcidas already uninstalled"
		;;
	status)
		echo "$argv0: ERROR: mcidas transfer services not installed in $services"
		;;
	esac
	;;
1)	case $act
	in
	install)
		echo "$argv0: $services: mcidas already set up"
		;;
	uninstall)
		echo "$argv0: $services: mcidas: removing line"
		if	ed $services <<-EOF >/dev/null 2>&1
			/$mcpat/
			d
			w
			q
			EOF
		then	:
		else	echo "$argv0: ERROR: edit of $services has failed"
			exit 1
		fi
		;;
	esac
	;;
*)	echo "$argv0: ERROR: problem with $services"
	exit 1
	;;
esac

#-------
# Do xinetd - make sure the xinetd.d directory contains the correct
# configuration file for mcserv
#-------
if [ $use_xinet -ne 0 ]; then

inet_print=xinetd
if [ "$act" != "status" -a "$act" != "restart" ]; then
	echo "$argv0: xinet: Using xinetd.d to set up services"
fi

# Begin xinet edit of hostsallow
# hostsallow - the name of the hosts.allow file
hostsallow=/etc/hosts.allow

for f in $hostsallow
do
	if	[ $uname_s = "Darwin" -a ! -f "$f" ]; then
		touch $f
	fi
	if	[ ! -f "$f" ]; then
		echo "$argv0: ERROR: $f: system has no such file"
		exit 1
	fi
done

denypat="^[^#].*deny$";

mcline=" mcidas mcservsh: ALL : severity local3.info : allow"
mcpat="^[ ]*mcidas mcservsh: ALL : severity local3.info : allow"

# If hostsallow contains non-comment line ending in "deny", then the mcidas
# servers must be placed before it
# Changing "ed" pattern based on existence of one of these lines
set X `egrep "$denypat" $hostsallow | wc -l`; shift
if [ $1 -eq 0 ]; then
	edline="\$ a"
else
	edline="/^[^\#].*deny\$/   ^a"
fi

set X `grep "$mcpat" $hostsallow | wc -l`; shift
case $1
in
0)	case $act
	in
	install)
		if [ $do_mcidas -ne 0 ]; then
			echo "$argv0: $hostsallow: mcidas: adding service lines"
			if	ed $hostsallow <<-EOF >/dev/null 2>&1
				$edline
				$mcline
				.
				w
				q
				EOF
			then	:
			else	echo "$argv0: ERROR: edit of $hostsallow has failed"
				exit 1
			fi
		fi
		;;
	uninstall)
		echo "$argv0: $hostsallow: mcidas already uninstalled"
		;;
	status)
		echo "$argv0: ERROR: mcidas transfer services not installed in $hostsallow"
		;;
	esac
	;;
1)	case $act
	in
	install)
		echo "$argv0: $hostsallow: mcidas already set up"
		;;
	uninstall)
		echo "$argv0: $hostsallow: mcidas: removing line"
		if	ed $hostsallow <<-EOF >/dev/null 2>&1
			/$mcpat/
			d
			w
			q
			EOF
		then	:
		else	echo "$argv0: ERROR: edit of $hostsallow has failed"
			exit 1
		fi
		;;
	esac
	;;
*)	echo "$argv0: ERROR: problem with $hostsallow"
	exit 1
	;;
esac
# End xinet edit of hostsallow

# Begin xinet edit of xinetd.d files

# Do mcidas
if [ "$act" != "status" -a "$act" != "restart" ]; then
	echo "$argv0: $xinet_dir/mcidas: modifying file"
fi
mctext="#mcidas (port $mcidas_port)
service mcidas
{
        flags           = REUSE
        socket_type     = stream
        protocol        = tcp
        wait            = no
        user            = $mcoper
        port            = $mcidas_port
        server          = $mcservsh
        server_args     = -H $mcoper_home
}"
case $act
in
install)
	if [ $do_mcidas -ne 0 ]; then
		if	echo "$mctext" > "$xinet_dir/mcidas"
		then	:
		else	echo "$argv0: ERROR: edit of $xinet_dir/mcidas has failed"
			exit 1
		fi
	fi
	;;
uninstall)
	if	rm -f "$xinet_dir/mcidas"
	then	:
	else	echo "$argv0: ERROR: failed to remove old $xinet_dir/mcidas"
		exit 1
	fi
	;;
status)
	if	! ls "$xinet_dir/mcidas" >/dev/null 2>&1
	then	:
		echo "$argv0: ERROR: mcidas transfer services not installed in $xinet_dir"
	fi
	;;
esac
# End mcidas

# End xinet edit of xinetd.d files

# end xinet block
elif [ $use_launchd -ne 0 ]; then

#-------
# Do launchd - create a plist file and tell launchctl what to do with it
#-------
inet_print=launchd

case $act
in
install)
	if [ $do_mcidas -ne 0 ]; then
		if /bin/launchctl list 2>&1 |grep mcidas >/dev/null
		then
			echo "$argv0: $launchd_dir/mcidas.plist: already installed"
		else
			cat  > "$launchd_dir/mcidas.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Disabled</key>
	<true/>
	<key>Label</key>
	<string>mcidas</string>
	<key>Program</key>
	<string>$mcservsh</string>
	<key>ProgramArguments</key>
	<array>
		<string>-H</string>
		<string>$mcoper_home</string>
	</array>
	<key>Sockets</key>
	<dict>
		<key>Listeners</key>
		<dict>
			<key>SockServiceName</key>
			<string>$mcidas_port</string>
		</dict>
	</dict>
	<key>UserName</key>
	<string>$mcoper</string>
	<key>inetdCompatibility</key>
	<dict>
		<key>Wait</key>
		<false/>
	</dict>
</dict>
</plist>
EOF
			/bin/launchctl load -w $launchd_dir/mcidas.plist
		fi
	fi
	;;
uninstall)
	if [ -f $launchd_dir/mcidas.plist ]; then
		/bin/launchctl unload -w $launchd_dir/mcidas.plist
		rm -f "$launchd_dir/mcidas.plist"
	else
		echo "$argv0: $launchd_dir/mcidas.plist: already uninstalled"
	fi
	;;
status)
	if	! ls "$launchd_dir/mcidas.plist" >/dev/null 2>&1
	then	:
		echo "$argv0: ERROR: mcidas transfer services not installed in $launchd_dir"
	fi
	;;
esac
# End plist creation

# end launchd block
else

#-------
# Do inetd - make sure that it contains the correct line, or remove that line
#-------
inet_print=inetd

# inetd_conf - the name of the inetd configuration file
for inetd_conf in /etc/inetd.conf /usr/etc/inetd.conf
do
	[ -f "$inetd_conf" ] && break
done

for f in $inetd_conf
do
	if	[ ! -f "$f" ]; then
		echo "$argv0: ERROR: $f: system has no such file"
		exit 1
	fi
done

inetmcline="mcidas	stream	tcp	nowait	$mcoper	$mcservsh	mcservsh -H $mcoper_home"
inetmcpat="^mcidas[ 	][ 	]*stream[ 	][ 	]*tcp[ 	][ 	]*nowait"

set X `grep "$inetmcpat" $inetd_conf | wc -l`; shift
case $1
in
0)	case $act
	in
	install)
		if [ $do_mcidas -ne 0 ]; then
			echo "$argv0: $inetd_conf: mcidas: adding line"
			case $mcservsh_default in
			?*)	echo "$argv0: WARNING: using $mcservsh instead of $mcservsh_default"
				;;
			esac
			if	[ ! -f "$mcservsh" ]
			then	echo "$argv0: WARNING: $mcservsh does not exist."
				echo "$argv0: WARNING: inetd may not listen for the new service."
			fi
			if	ed $inetd_conf <<-EOF >/dev/null 2>&1
				\$
				a
				$inetmcline
				.
				w
				q
				EOF
			then	:
			else	echo "$argv0: ERROR: edit of $inetd_conf has failed"
				exit 1
			fi

			# Solaris 10 additions
			if [ $use_solaris10 -ne 0 ]; then
				echo "$argv0: inetconv/inetadm: mcidas: installing"
				# Add the inet entry to SMF
				/usr/sbin/inetconv -f -i		\
					/etc/inet/inetd.conf	\
					2>/dev/null
				# Enable the new entry
				/usr/sbin/inetadm -e		\
					svc:/network/mcidas/tcp:default \
					2>/dev/null
				sleep 1
			fi

		fi
		;;
	uninstall)
		echo "$argv0: $inetd_conf: mcidas already uninstalled"
		;;
	status)
		echo "$argv0: ERROR: mcidas transfer services not installed in $inetd_conf"
		;;
	esac
	;;
1)	case $act
	in
	install)
		echo "$argv0: $inetd_conf: mcidas already set up"
		;;
	uninstall)
		echo "$argv0: $inetd_conf: mcidas: removing line"
		if	ed $inetd_conf <<-EOF >/dev/null 2>&1
			/$inetmcpat/
			d
			w
			q
			EOF
		then	:
		else	echo "$argv0: ERROR: edit of $inetd_conf has failed"
			exit 1
		fi

		# Solaris 10 additions
		if [ $use_solaris10 -ne 0 ]; then
			echo "$argv0: inetadm: mcidas: uninstalling"
			# Disable the new entry
			/usr/sbin/inetadm -d		\
				svc:/network/mcidas/tcp:default \
				2>/dev/null
			sleep 1
		fi

		;;
	esac
	;;
*)	echo "$argv0: ERROR: problem with $inetd_conf"
	exit 1
	;;
esac

fi
# end non-xinet, non-launchd block

#-------
# Post-editing actions
#  Skip all of this if we are on solaris 10 (taken care of with inetadm)
#  Skip all of this if we are using launchd
#-------
if [ "$act" != "status" -a "$use_solaris10" == "0" -a "$use_launchd" == "0" ]; then

case $uname_s
in
AIX)	odmshow InetServ >/dev/null 2>&1 && inetimp
	;;
esac

case $uname_s
in
SunOS)	
	case $uname_r
	in
	5.*)
		# Avoid the possibility of getting /usr/ucb/ps by
		# using a full pathname.
		set X `/usr/bin/ps -e | grep $inet_print`; shift
		;;
	4.*)
		set X `ps cagx | grep $inet_print`; shift
		;;
	*)	echo "$argv0: ERROR: unknown version of SunOS"
		exit 1
		;;
	esac
	;;
Darwin) set X `cat /var/run/xinetd.pid`; shift
	;;
*)	set X `ps -e | grep $inet_print`; shift
	;;
esac
inetd_pid="$1"

if [ "$uname_s" != "Interix" ]; then
	echo "$argv0: telling $inet_print to reread its configuration"
	case $inetd_pid
	in
	'')	echo "$argv0: WARNING: your system is not running $inet_print"
		;;
	*)	if [ ! $use_xinet -ne 0 -o "$uname_s" = "Darwin" ]; then
			if	kill -HUP $inetd_pid
			then	:
			else	echo "$argv0: ERROR: could not tell $inet_print to reread its configuration (kill -HUP $inetd_pid)"
				exit 1
			fi
		else
			if	service xinetd restart
			then	:
			else	echo "$argv0: ERROR: could not tell $inet_print to reread its configuration (service xinetd restart)"
				exit 1
			fi
		fi
		echo "$argv0: waiting for $inet_print to reread its configuration"
		sleep 5
		;;
	esac

else
	case $act
	in
	install)
		inetd_pid=`ps -ef | grep inetd |
			grep -v grep | awk '{print $2}'`
		inetd_svc=`service list | grep "inetd -s"`
		if [ ! -z "$inetd_svc" ]; then
			echo "$argv0: service already installed"
		else
			echo "$argv0: stopping inetd Interix service"
			if [ ! -z "$inetd_pid" ]; then
				kill $inetd_pid
				rm -f /etc/rc2.d/S*inet /etc/rc2.d/K*inet
			fi
			echo "$argv0: starting inetd Windows service"
			echo "$argv0: $mcoper password: \c"
			read mcpass
			service install -u $mcoper -p $mcpass -s auto /usr/sbin/inetd -s
			sleep 2
			service start inetd >/dev/null
		fi
		;;
	uninstall)
		inetd_pid=`ps -ef | grep inetd | grep -v "inetd -s" |
			grep -v grep | awk '{print $2}'`
		if [ ! -z "$inetd_pid" ]; then
			echo "$argv0: service already uninstalled"
		else
			echo "$argv0: stopping inetd Windows service"
			inetd_svc=`service list | grep inetd`
			if [ ! -z "$inetd_svc" ]; then
				service stop inetd >/dev/null
				sleep 2
				service remove inetd >/dev/null
			fi
			echo "$argv0: starting inetd Interix service"
			ln -s /etc/init.d/inet /etc/rc2.d/S32inet
			ln -s /etc/init.d/inet /etc/rc2.d/K68inet
			/etc/rc2.d/S32inet start
		fi
		;;
	esac
fi

fi
# end non-status action

#-------
# Make sure that (x)inetd/launchd is behaving as expected by looking at the
# output from 'netstat -a'.
#-------

if [ "$uname_s" = "Interix" ]; then
	WINPATH1=`winpath2unix $SYSTEMROOT/SYSTEM32`
	WINPATH2=`winpath2unix $SYSTEMROOT/system32`
fi
for netstat in	/bin/netstat /usr/ucb/netstat /usr/etc/netstat /usr/sbin/netstat $WINPATH1/NETSTAT.EXE $WINPATH1/netstat.exe $WINPATH2/NETSTAT.EXE $WINPATH2/netstat.exe
do
	[ -f "$netstat" ] && break
done
if	[ ! -f "$netstat" ]
then	echo "$argv0: ERROR: cannot find netstat"
	exit 1
fi

# default grep pattern
# Look for any line that contains the string ".mcserv" with "LISTEN"

statmcpat='[.:]mcidas.*LISTEN'

set X `$netstat -a | grep "$statmcpat" | wc -l`; shift
case $1
in
0)	case $act
	in
	install)
		if [ $do_mcidas -ne 0 ]; then
			echo "$argv0: WARNING: $inet_print not listening"
			echo "Try running the script again in a few minutes."
		fi
		;;
	uninstall)
		echo "$argv0: $inet_print mcidas configuration uninstalled successfully"
		;;
	status)
		echo "$argv0: mcidas transfer services installed and running:		NO"
		;;
	esac
	;;
[12])	case $act
	in
	install)
		echo "$argv0: $inet_print mcidas configuration installed successfully"
		;;
	uninstall)
		echo "$argv0: WARNING: $inet_print still listening"
		echo "Try running the script again in a few minutes."
		;;
	status)
		echo "$argv0: mcidas transfer services installed and running:		YES"
		;;
	esac
	;;
*)	echo "$argv0: ERROR: problem with $inet_print or netstat"
	exit 1
	;;
esac

exit 0
