package Games::Worms::Random;
use strict;
use vars qw($Debug $VERSION @ISA);
use Games::Worms::Base;
@ISA = ('Games::Worms::Base');
$Debug = 0;
$VERSION = "0.50";

sub which_way { # figure out which direction to go in
  my($worm, $hash_r) = @_;
  my @dirs = keys %$hash_r;
  return $dirs[ rand(@dirs) ];
}

1;

__END__

