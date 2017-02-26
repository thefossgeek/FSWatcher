#!/bin/bash

# Config file used to get TO and SMTP
conf_file="/opt/FSWatcher/etc/fswatcher.ini"
if [ ! -f $conf_file ]; then
	echo "No such file or directory $conf_file"	
	exit 1
fi

# Get all the command path
cmd_cat=$(which cat)
if [ $? -ne 0 ]; then
	cmd_cat="/bin/cat"
fi

cmd_cp=$(which cp)
if [ $? -ne 0 ]; then
	cmd_cp="/bin/cp"
fi

cmd_grep=$(which grep)
if [ $? -ne 0 ]; then
	cmd_grep="/bin/grep"
fi

cmd_awk=$(which awk)
if [ $? -ne 0 ]; then
	cmd_awk="/bin/awk"
fi

cmd_cut=$(which cut)
if [ $? -ne 0 ]; then
	cmd_cut="/bin/cut"
fi

cmd_sed=$(which sed)
if [ $? -ne 0 ]; then
	cmd_sed="/bin/sed"
fi

cmd_tr=$(which tr)
if [ $? -ne 0 ]; then
	cmd_tr="/usr/bin/tr"
fi

cmd_mailx=$(which mailx)
if [ $? -ne 0 ]; then
	cmd_mailx="/bin/mailx"
fi

# Log file which contain file or directory change event
log_file=`$cmd_cat "${conf_file}" | $cmd_grep -v ^$ | $cmd_grep -v ^# | $cmd_grep  'logfile=' | $cmd_cut -d '=' -f2 | $cmd_sed 's/^ *//'`
if [ ! -n "$log_file" ]; then
	echo "logfile parameter not configured in $conf_file"
	exit 1
fi

# Log file which contain old events
log_file_old=`$cmd_cat "${conf_file}" | $cmd_grep -v ^$ | $cmd_grep -v ^# | $cmd_grep  'logfile_old=' | $cmd_cut -d '=' -f2 | $cmd_sed 's/^ *//'`
if [ ! -n "$log_file_old" ]; then
	echo "logfile_old parameter not configured in $conf_file"
	exit 1
fi

# Function which sends email up on new event.
function send_mail {

	changes="$1"
	Today=`date +'%d-%B-%Y'`
	TO=`$cmd_cat "${conf_file}" | $cmd_grep -v ^$ | $cmd_grep -v ^# | $cmd_grep  'emailto=' | $cmd_cut -d '=' -f2 | $cmd_sed 's/^ *//'`
	if [ ! -n "$TO" ]; then
		echo "Recipient mail id not configured in $conf_file"	
		exit 1
	fi
	Mail_Relay_Server=`$cmd_cat "${conf_file}" | $cmd_grep -v ^$ | $cmd_grep -v ^# | $cmd_grep  'Mail_Relay_Server=' | $cmd_cut -d '=' -f2 | $cmd_sed 's/^ *//'`
	if [ ! -n "$Mail_Relay_Server" ]; then
		echo "Mail_Relay_Server not configured in $conf_file"	
		exit 1
	fi
	FROM="fswatcher@example.com"
	Subject="Automatic e-Mail Notification for file system change - $Today"
	(
		echo
		echo Dear All,
		echo
		echo Please find enclosed file system change notification for $Today
		echo
		echo "The following files are changed:" 
		echo
		echo "$changes"
		echo
		echo " ********** This is a system generated report, please do not reply ************* "
		echo
		echo "Thanks, "
		echo "FSWatcher"
		echo
	) > /tmp/descfile.$$

	$cmd_cat "/tmp/descfile.$$" | $cmd_mailx -v -r "${FROM}" -s "$Subject" -S smtp="${Mail_Relay_Server}" "${TO}"

	/bin/rm -r /tmp/descfile.$$

}

# This condition only work if you run the script first time.
if [ ! -f "${log_file_old}" ]; then
	#touch "${log_file_old}"
	$cmd_cp "${log_file}" "${log_file_old}"
fi
    
# Code which compared the log file and call send_mail function to send email.
if ! /usr/bin/cmp -s "${log_file_old}" "${log_file}"; then

	changes=$(/usr/bin/diff "${log_file_old}" "${log_file}" | $cmd_sed -n "s/^<//p; s/^>//p" | $cmd_tr A-Z a-z)
	send_mail "$changes"
	$cmd_cp "${log_file}" "${log_file_old}"

fi
