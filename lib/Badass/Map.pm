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


sub generate_tile_at{
   my ($self, $x,$y) = @_;
   $self->tiles->{"$y,$x"} = int rand(2);
}


no Mouse;
__PACKAGE__->meta->make_immutable();
1

