package Games::Worms::Base;
 # base class for worms
use strict;

use vars qw($Debug $VERSION @Colors $Color_counter $Directions);
$Debug = 0;
$VERSION = "0.01";
$Directions = 6; # number of directions in this universe

my $uid = 0;

$Color_counter = 0;
@Colors = qw(red green blue yellow white orange);

#--------------------------------------------------------------------------

sub default_color {
  my $color = $Color_counter++;
  $Color_counter = 0 if $Color_counter > $#Colors;
  return $Colors[$color];
}

#--------------------------------------------------------------------------

sub init {
  return;
}

#--------------------------------------------------------------------------

sub initial_move {
  return int(rand($Directions));
}

#--------------------------------------------------------------------------

sub try_move {
  my $worm = $_[0];
  return unless $worm->is_alive;
  if($Debug > 2) {
    sleep 1;
  }

  my $current_node = $worm->{'current_node'};

  my(%dir_2_uneaten_seg);
  my $i;
  foreach my $seg ($current_node->segments_away) {
    $dir_2_uneaten_seg{$i++} = $seg;
  }
  # was: @dir_2_uneaten_seg{0,1,2,3,4,5} = $current_node->segments_away;

  my $origin_direction = 0;

  foreach my $d (sort keys %dir_2_uneaten_seg) {
    # Is this the direction I got here by?
    if($dir_2_uneaten_seg{$d} eq $worm->{'last_segment_eaten'}) {
      $origin_direction = $d;
    }

    if($dir_2_uneaten_seg{$d}->is_eaten) {
      # print " Direction $d is no good ($dir_2_uneaten_seg{$d} is eaten)\n" if $Debug;
      delete $dir_2_uneaten_seg{$d};
    } else {
      # print " Direction $d is okay\n" if $Debug;
    }
  }

  unless(keys(%dir_2_uneaten_seg)) {
    print
     " worm $worm->{'name'} is stuck, from direction $origin_direction\n" 
     if $Debug;
    $worm->die;
    return 0;
  }

  my %rel_dir_2_uneaten_seg;
  my @rel_directions = (0) x $Directions;
  @rel_dir_2_uneaten_seg{ map {($_ - $origin_direction) % $Directions}
                              keys(%dir_2_uneaten_seg)
                        }
                        = values(%dir_2_uneaten_seg);
  foreach my $rd (keys(%rel_dir_2_uneaten_seg)) {
    $rel_directions[$rd] = 1;
  } # a 1 in this list means a FREE (uneaten) node

  if($Debug > 1) {
    my $adirs = join '', keys %dir_2_uneaten_seg;
    my $rdirs = join '', keys %rel_dir_2_uneaten_seg;
    print " worm $worm->{'name'} can go ",
      scalar(keys(%dir_2_uneaten_seg)),
      " ways (R$rdirs A$adirs), from dir $origin_direction\n"
     if $Debug > 1;
  }


  my $rel_dir_to_move;
  if(keys(%dir_2_uneaten_seg) == $Directions) { # new worm
    $rel_dir_to_move =
     $worm->initial_move(\%rel_dir_2_uneaten_seg, \@rel_directions);
  } elsif(keys(%dir_2_uneaten_seg) == 1) {
    $rel_dir_to_move = (keys(%rel_dir_2_uneaten_seg))[0];
  } else {
    $rel_dir_to_move =
     $worm->which_way(\%rel_dir_2_uneaten_seg, \@rel_directions);
  }

  # now unrelativize
  my $dir_to_move = ($rel_dir_to_move + $origin_direction) % $Directions;
  print
    "  worm $worm->{'name'} goes in R$rel_dir_to_move (D$dir_to_move)\n"
   if $Debug > 1;

  my $segment_to_eat = $dir_2_uneaten_seg{$dir_to_move};
  my $destination_node = $current_node->toward('node', $dir_to_move);
  
  $worm->eat_segment($segment_to_eat);

  $current_node = $worm->{'current_node'} = $destination_node;

  return 1;
}

#--------------------------------------------------------------------------
#
# You probably don't want to mess with the methods below here.
#

sub new {
  my $c = shift;
  $c = ref($c) || $c;
  my $it = bless { @_ }, $c;

  $it->{'uid'} = $uid++; # per-session unique, if we need it
  $it->{'is_alive'} = 1 unless defined $it->{'is_alive'};
  $it->{'color'} ||= $it->default_color;
  $it->{'segments_eaten'} = 0;
  $it->{'last_segment_eaten'} = 0;
  $it->init;

  push @{$it->{'board'}{'worms'}}, $it if $it->{'board'};
   # if I have a board set, put me in that board's worms list.
  print "New worm $it ($it->{'name'})\n" if $Debug;

  return $it;
}

sub segments_eaten {
  my $it = $_[0];
  return $it->{'segments_eaten'};
}

sub is_alive {
  my $it = $_[0];
  return $it->{'is_alive'};
}

#sub current_node {
#  my $it = $_[0];
#  return $it->{'current_node'};
#}

sub die { # kill this worm
  my $worm = $_[0];
  print " worm $worm dies\n" if $Debug;
  $worm->{'is_alive'} = 0;
}

sub eat_segment {
  my($worm, $segment) = @_[0,1];
  $worm->{'segments_eaten'}++;
  $segment->{'color'} = $worm->{'color'};

  # print " worm $worm eats segment $segment\n" if $Debug;

  $worm->{'last_segment_eaten'} = $segment;
  $segment->be_eaten;
  $segment->draw;
  return;
}

#--------------------------------------------------------------------------

1;

__END__

