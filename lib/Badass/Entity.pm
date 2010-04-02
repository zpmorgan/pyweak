package Badass::Entity;
use Mouse;


for (qw/x y/){   #///
   has $_ => (
      is => 'rw',
      isa => 'Num',
   );
}
for (qw/xv yv/){   #///
   has $_ => (
      is => 'rw',
      isa => 'Num',
      default => 0,
   );
}

has anim => (
   is => 'rw',
   isa => 'SDLx::Animation');

sub update_pos {
   my ($self, $ms) = @_;
   $self->x ($self->x + $self->xv*$ms);
   $self->y ($self->y + $self->yv*$ms);
}

my $tilesize = 32;

#update anim coordinates and call anim->draw
sub drawFOO{
   my $self = shift;
   my $anim = $self->anim;
   $anim->x(int($self->x*$tilesize));
   $anim->y(int($self->y*$tilesize));
   $anim->draw();
}



no Mouse;
__PACKAGE__->meta->make_immutable();
1

