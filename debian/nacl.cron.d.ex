#
# Regular cron jobs for the nacl package
#
0 4	* * *	root	[ -x /usr/bin/nacl_maintenance ] && /usr/bin/nacl_maintenance
