CCFinderX core
==============

This is a clone of [CCFinderX][1] that has the settings to build with autoconf on a Linux machine. Actually this is a clone of a clone. I've cloned this from
[gpoo/ccfinderx][2].

I've split [gpoo/ccfinderx][2] into two separate projects. This is the core and do not need java, and there is the [ccfinderx-gui][3]. The gui is not working yet,
but you can compile ccfinderx-core without OpenJDK dependencies.

The autoconf setting is not finished (it does not pass `make distcheck`), but it is something to start with. The process to build `ccfinderx` is:

    $ libtoolize
    $ aclocal -I m4 --install
    $ autoconf
    $ automake --foreign --add-missing
    $ ./configure
    $ make

Before running you need to tell Python about easytorq.so. For Fedora19:

    $ sudo cp ./torq/pyeasytorq/.libs/easytorq.so /usr/lib64/python2.7/site-packages/

For testing:

    $ ./ccfx/ccfx d cpp <dir/with/c/or/cpp/files/*> # Detect clones

    $ ./ccfx/ccfx p a.ccfxd <dir/with/c/or/cpp/files/*> # Pretty? print the results

    $ ./ccfx/ccfx m a.ccfxd -c # Calculates clone metrics
    $ ./ccfx/ccfx m a.ccfxd -f # Calculates file metrics

For help:

    $ ./ccfx/ccfx -h
    $ ./ccfx/ccfx d -h
    $ ./ccfx/ccfx p -h
    $ ./ccfx/ccfx m -h


  [1]: http://www.ccfinder.net/ccfinderxos.html
  [2]: https://github.com/gpoo/ccfinderx
  [3]: https://github.com/petersenna/ccfinderx-gui
