package Games::Worms::Tk::Seg;
use strict;
use vars qw($Debug $VERSION @ISA);
use Games::Worms::Seg;

$Debug = 0;
@ISA = ('Games::Worms::Seg');
$VERSION = "0.50";

sub draw { # possibly redraw
  my $it = shift;
  $it->{'board'}->{'canvas'}->createLine(
   @{$it->{'coords'}}, '-fill' => $it->{'color'}
  );
}

1;

__END__

