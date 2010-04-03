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
      trigger => \&update_cycle,
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

sub update_cycle{
   my $self = shift;
   my $new_cycle = ($self->xv or $self->yv) ? 'walk' : 'stand';
   if ($self->anim->current_cycle_name ne $new_cycle){
      $self->anim->set_cycle ($new_cycle);
   }
}


#animation is handled in viewport now



no Mouse;
__PACKAGE__->meta->make_immutable();
1

