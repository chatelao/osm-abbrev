## Software requirements:

* GNU/Linux OS
* Postgresql 8.x - 11.x, PostGIS 2.x

This code is developed on Debian 9.x and should also work on Debian
derivatives like Ubuntu and other GNU/Linux distributions.

If you are on Debian or Ubuntu all required libraries should be installed from
your distribution. Please do not compile them from source!

Microsoft Windows is currently not supported and I have no plans to do so.
If you feel an urgend need to port this code to Windows I would be happy to
take patches.

To install the l10n into your database the following steps are requered:

### 1. Install the libraries for the C/C++ stored procedures


The easiest way to do this on Debian/Ubuntu is to build packages and install
them:

```sh
make deb
```

To make this work you will need to install the required libraries:

```sh
sudo apt-get install devscripts equivs
sudo mk-build-deps -i debian/control
```     

On other Distributions it should work to use `make`/`make install`, given the
required libraries listed in `debian/control` have been installed.
I would be happy if somebody would contribute a spec-file for rpm based
distributions.

### 2. Load the required extensions into your database

```sql
CREATE EXTENSION osmabbrv CASCADE;
```
