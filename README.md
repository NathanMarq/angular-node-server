# SAMPLE NODE ANGULAR WEBAPP #

### Based off of [John Longanecker's Angular Skeleton](https://github.com/jlongnbt/angular-skeleton "jlongnbt repo") ###
#### ALL the grunt magic credit goes to him. ####

## System Configs ##

**Created and Tested With:**

* Mac OSX 10.9.2
* Virtualbox 4.3.8 r92456
* Vagrant 1.4.3
* Grunt v0.1.13
* Bower version 1.2.8

* Uses Grunt Watch functionality, which can be fully appreciated with the [LiveReload](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei/details) plugin in Chrome

**Server Side Requirements:**

* Node v0.10.26
	* Express
	* Forever

These are all installed when you run the bootstrap file. Specific versions of the node modules can be found in the www/package.json file.

**Front End Requirements:**
* AngularJS

Versions of all of these can be found in the package.json file and the bower.json file.

### Getting Started ###

**To run this VM, you MUST have Vagrant installed.**

**After cloning the repo, start up the Vagrant box:**

`vagrant up`

`vagrant ssh`

`cd /vagrant`

`sh bootstrap.sh`

**Then, from your local machine:**

`cd www/public_src/libs`

`bower install`

`cd ../../`

`grunt build`
	
** Run grunt watch for live editing/minification: **

`grunt watch`