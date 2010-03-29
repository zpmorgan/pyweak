package Badass::Viewport;
use Mouse;

sub tile_size {32} # or like such as

for (qw/w h/){   # number of tiles
   has $_ => (
      is => 'rw',
      isa => 'Int',
   );
}

has tiles => (
   is => 'ro',
   isa => 'ArrayRef[ArrayRef]',
   default => sub{[]} );

#opportunity for dynamic programming
sub tile_at {
   my ($self,$x,$y) = @_;
   return $self->tiles->[$y][$x];
}

no Mouse;
__PACKAGE__->meta->make_immutable();
1

