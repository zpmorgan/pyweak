package Badass::Viewport;
use Mouse;

#maybe this is shtoopid
has window => (
   is => 'rw',
   isa => 'SDL::Surface',
);

for (qw/x y w h/){   #/// 
   has $_ => (
      is => 'rw',
      isa => 'Int',
   );
}
sub draw_bg{}
sub draw_entity{}



no Mouse;
__PACKAGE__->meta->make_immutable();
1

