package Badass::Viewport;
use Mouse;

has window => (
   is => 'rw',
   isa => 'SDL::Game',
);

for (qw/x y w h/){   #/// 
   has $_ => (
      is => 'rw',
      isa => 'Num',
   );
}
sub draw_bg{}
sub draw_entity{}



1

