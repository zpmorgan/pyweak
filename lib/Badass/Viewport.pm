package Badass::Viewport;
use Mouse;
use POSIX qw/ceil floor/;

#maybe this is shtoopid
has parent_surface => (
   is => 'rw',
   isa => 'SDL::Surface',
);
has map => (
   is => 'rw',
   isa => 'Badass::Map',
);

my $tilesize = 32;

#u,v are offsets on parent_window, in pixels.
#h and w in pixels, tilesize in pixels,
#x and y are in tiles, the map offset.
for (qw/u v x y/){   #/// on world coordinates 
   has $_ => (
      is => 'rw',
      isa => 'Int',
      default=>0,
   );
}
for (qw/w h/){   #/// on world coordinates 
   has $_ => (
      is => 'rw',
      isa => 'Int',
      default=>300,
   );
}
sub draw{
   my $self = shift;
   my $map = $self->map;
   my $window = $self->parent_surface;
   my $x = $self->x;
   my $y = $self->y;
   my $tile_x_min = floor ($x / $tilesize);
   my $tile_x_max = ceil (($x + $self->w) / $tilesize);
   my $tile_y_min = floor ($y / $tilesize);
   my $tile_y_max = ceil (($y + $self->h) / $tilesize);
   for my $tile_x($tile_x_min .. $tile_x_max){
      for my $tile_y($tile_y_min .. $tile_y_max){
         my $tile = $map->tile_at($tile_x, $tile_y);
         if ($tile == 1){
            SDL::Video::fill_rect(
               $self->parent_surface,
               SDL::Rect->new( ($tile_x-$x)*$tilesize, ($tile_y-$y)*$tilesize, 32, 32 ),
               SDL::Video::map_RGB( $self->parent_surface->format, 0,0,0 )
            );
         }
      }
   }
}
sub draw_entity{}



no Mouse;
__PACKAGE__->meta->make_immutable();
1

