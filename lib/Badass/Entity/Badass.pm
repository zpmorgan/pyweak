package Badass::Entity::Badass;
use Mouse;
extends 'Badass::Entity';


my $mov_spd = .007;


sub update_movement{
   my $self = shift;
   
   if ($self->move_left and !$self->move_right){
      $self->xv(-$mov_spd)
   } elsif (!$self->move_left and $self->move_right){
      $self->xv($mov_spd)
   } else {
      $self->xv(0)
   }
   if ($self->move_up and !$self->move_down){
      $self->yv(-$mov_spd)
   } elsif (!$self->move_up and $self->move_down){
      $self->yv($mov_spd)
   } else {
      $self->yv(0)
   }
   
   my $new_cycle = ($self->xv or $self->yv) ? 'walk' : 'stand';
   if ($self->anim->current_cycle_name ne $new_cycle){
      $self->anim->set_cycle ($new_cycle);
   }
}


for (qw/move_up move_down move_left move_right/){   #///
   has $_ => (
      is => 'rw',
      isa => 'Num',#bool? or different speeds?
      trigger => \&update_movement,
   );
}

1
