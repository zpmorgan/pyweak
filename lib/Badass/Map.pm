package Badass::Map;
use Mouse;

sub tile_size {32} # or like such as

for (qw/w h/){   # number of tiles
   has $_ => (
      is => 'rw',
      isa => 'Int',
   );
}

#this is finite... a single hash would provide infinite coverage.
has tiles => (
   is => 'ro',
   isa => 'HashRef',
   default => sub{{}} );


#dynamic programming
sub tile_at {
   my ($self,$x,$y) = @_;
   unless (defined $self->tiles->{"$y,$x"}){
      $self->generate_tile_at($x,$y);
   }
   return $self->tiles->{"$y,$x"};
}

#use Math::Fractal::NoiseMaker;

#randomly generated tile registry
has _num_tiles_of => (
   is => 'ro',
   isa => 'HashRef',
   default => sub{{0=>0,1=>40}},
);

has tile_proportions => (
   isa => 'HashRef',
   is=>'ro',
   default => sub{{0=>4, 1=>3}},
);
has _normalized_tile_proportions => (
   is => 'ro',
   isa => 'ArrayRef',
   lazy => 1,
   default => sub{$_[0]->_generate_normalized_tile_proportions},
);
#called automatically for former attribute

sub _generate_normalized_tile_proportions{
   my $self = shift;
   my $tpro = $self->tile_proportions;
   my $total = 0;
   for (values %$tpro){
      $total += $_;
   }
   my @stpro = map {[$_, $tpro->{$_}/$total]} keys %$tpro;
   return \@stpro;
}

my @nghbr_d = ([-1,0, 255],[0,-1, 255],[0,1, 255],[1,0, 255], [1,1, 175],[-1,-1, 175],[-1,1, 175],[1,-1, 175],);
push  @nghbr_d, ([-2,0, 45], [2,0, 45],[0,2, 45], [0,-2, 45]);
my $basis = 25;
my $neighbor_bias = 225;
use List::Util qw/min max sum/;

sub generate_tile_at{
   my ($self, $x,$y) = @_;
   my $tiles = $self->tiles;
   my $randval = rand();
   #only randomly generate the types specified in proportions
   #my %pros = %{$self->tile_proportions};
   my @types = keys %{$self->tile_proportions};
   my %totals = map {$_ => $self->_num_tiles_of->{$_}} @types;
   
   #now inject a bias based on neighboring tiles
   for (@nghbr_d){
      my ($ax,$ay, $bias) = @$_;
      $ax += $x;
      $ay += $y;
      my $tile = $tiles->{ "$ay,$ax" };
      next unless defined $tile and defined $totals{$tile};
      $totals{$tile} -= $bias;
   }
   #negate totals, then increase each one by the same amount
   # so that the lowest (the present highest) == $basis
   my $max_tiles = max map {$totals{$_}} keys %totals;
   for my $type (@types){
      $totals{$type} = -$totals{$type};
      $totals{$type} += $max_tiles+25;
   }
   my $sum = sum (map {$totals{$_}} @types);
   
   my $a = 0;
   for my $tile_t (@types){
      $a += $totals{$tile_t} / $sum;
      if ($a > $randval){
         $self->tiles->{"$y,$x"} = $tile_t;
         $self->_num_tiles_of->{$tile_t}+= 1/$self->tile_proportions->{$tile_t};
         return;
      }
   }
}


no Mouse;
__PACKAGE__->meta->make_immutable();
1

