# This -*- perl -*- script writes the Makefile for TkWorms
# Time-stamp: "1999-02-15 19:46:19 MST"
require 5.004;
use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
   NAME          => 'Games-Worms-Tk',
   VERSION_FROM  => 'lib/Games/Worms/Tk.pm',
   'dist'        => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);

package MY;

sub libscan
{ # Determine things that should *not* be installed
    my($self, $path) = @_;
    return '' if $path =~ m/~/;
    $path;
}

__END__
