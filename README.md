CCMenu
======

This is a Git clone of the original [CCMenu](http://sourceforge.net/projects/ccmenu/) SVN repository.

Please see the original [website](http://ccmenu.sourceforge.net/) for details on what CCMenu
is. The purpose of this repository is to solve a single [issue](http://sourceforge.net/tracker/?func=detail&aid=1878591&group_id=201142&atid=976374) with self-signed SSL
certificates.

The [solution](https://github.com/gorenje/ccmenu/commit/47073501f0918db112e09687807307941b1f6052) is based on http://www.cocoanetics.com/2009/11/ignoring-certificate-errors-on-nsurlrequest/
which requires using private methods on NSURLRequest, i.e. no guarantee made it will
continue to work.
