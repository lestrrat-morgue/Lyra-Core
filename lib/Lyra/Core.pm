# Bootstrap XS stuff, and be a placeholder for version and stuff

package Lyra::Core;
use strict;
use XSLoader;

our $VERSION = '0.00001';
XSLoader::load __PACKAGE__, $VERSION;

1;