package Games::Worms::Tk;

use strict;
use Tk;
use Games::Worms::Tk::Seg;
use Games::Worms::Tk::Board;
use Games::Worms::Node;
use vars qw($Debug $VERSION @ISA);

$Debug = 0;
$VERSION = "0.41";

sub main {
  my $mw = MainWindow->new;

  my $board = Games::Worms::Tk::Board->new('window' => $mw);
  $board->window_init;

  $mw->waitVisibility;

  $board->run(@ARGV);

  MainLoop;

}

1;

__END__

