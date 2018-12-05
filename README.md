Setup
=====
`master` is the first repo to download when setting up
tkcloud master node.

Usually on a brand-new OS, git clone this repo and run
`pacman -Syu`, then run ``./setup.sh `whoami` `` using root privilege.

Troubleshoot
============
1. On proxy server instance:
	* Some cloud providers require SSH pubkey (you need to manually copy master node pubkey to `~/.ssh/authorized_keys`).
	* Some cloud providers require non-root user in order to login (modify `/etc/ssh/sshd_config` to remove this restriction).
	* Restart sshd service after steps above are done.
	* Remember to allow at least port 8986 traffic (e.g. using cloud provider portal) so that wsproxy can work.
2. Run `tkcloud:up` job.
	* If sshd authentication does not work.
		* Try to fix it until `ssh-auth:remotehost-test` job can success.
		* ssh on master node manually to cloud proxy instance, see if that works.
	* Test php proxy: Visit `http://[cloud_IP]/php-test/phpinfo.php`
	* See if `jobd` and `droppy` services can be visited locally and remotely.
	* Check if rsync is working correctly, if not:
		* Make sure `rsync:delete-lock` job is successful.
		* On client node side, make sure `tkcloud/client/setup.archlinux.sh` show active status. If not, sudo run it.
		* Check if `~/Desktop/.please-sync` file exists on client node.
	* Check if extdisk is mounted correctly: Run `show:extdisk0` job to test it.
3. Setup other micro-services.
	* Run `service:all-up` if master node has installed essential environment (`service-blog:first-time-up` job).
	* Check `http://[cloud_IP]/tkblog/search.php?q=test` to test tkblog search engine.
	* Check `http://[cloud_IP]/hippo/` to test hippo service.
	* Check `http://[cloud_IP]/static/` to test static file service.
	* Check `http://[cloud_IP]/feeder/` to test feed/news service.

Reminder
========
* Don't forget to keep `t-k-cloud.github.io/index.html` IP updated, so that tkblog blog publish will work.
