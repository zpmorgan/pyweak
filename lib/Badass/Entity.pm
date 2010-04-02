package Badass::Entity;
use Mouse;


for (qw/x y/){   #///
   has $_ => (
      is => 'rw',
      isa => 'Int',
   );
}


has anim => (
   is => 'rw',
   isa => 'SDLx::Animation');

#update anim coordinates and call anim->draw
sub draw{
   my $self = shift;
   my $anim = $self->anim;
   $anim->x($self->x);
   $anim->y($self->y);
   $anim->draw();
}



no Mouse;
__PACKAGE__->meta->make_immutable();
1

