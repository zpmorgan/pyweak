package Badass::Viewport;
use Mouse;


for (qw/x y/){   #///
   has $_ => (
      is => 'rw',
      isa => 'Int',
   );
}

#this will surely become more elaborate
has img => (
   is => 'rw',
   isa => 'SDL::Surface');

has anim => (
   is => 'rw',
   isa => 'SDLx::Animation');


no Mouse;
__PACKAGE__->meta->make_immutable();
1

