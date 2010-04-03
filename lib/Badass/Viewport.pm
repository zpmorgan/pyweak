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
for (qw/u v/){   #/// pixels on app
   has $_ => (
      is => 'rw',
      isa => 'Int',
      default=>0,
   );
}
for (qw/w h/){   #/// pixels on app
   has $_ => (
      is => 'rw',
      isa => 'Int',
      default=>300,
   );
}
for (qw/x y/){   #/// tiles on world coordinates 
   has $_ => (
      is => 'rw',
      isa => 'Num',
      default=>0,
   );
}
#thing to track, with x and y methods
has ent => (
   is => 'rw',
   isa => 'Badass::Entity',
);

sub track_entity{
   my $self = shift;
   die 'viewport needs entity to track.' unless $self->ent;
   
   my $ent_x_pixels = int($self->ent->x * $tilesize);
   my $ent_y_pixels = int($self->ent->y * $tilesize);
   my $x_pixels = int($self->x * $tilesize);
   my $y_pixels = int($self->y * $tilesize);
   if ($ent_x_pixels - 100 < $x_pixels){
      $self->x( ($ent_x_pixels - 100) / $tilesize);
   }
   elsif ($ent_x_pixels + 32 > $x_pixels + $self->w - 100){
      $self->x( ( $ent_x_pixels + 32 + 100 - $self->w) / $tilesize);
   }
   if ($ent_y_pixels - 100 < $y_pixels){
      $self->y( ( $ent_y_pixels - 100) / $tilesize);
   }
   elsif ($ent_y_pixels + 32 > $y_pixels + $self->h - 100){
      $self->y( ( $ent_y_pixels + 32 + 100 - $self->h) / $tilesize);
   }
}

sub draw{
   my $self = shift;
   $self->track_entity;
   my $map = $self->map;
   my $window = $self->parent_surface;
   my $x = $self->x;
   my $y = $self->y;
   my $tile_x_min = floor ($x);
   my $tile_x_max = ceil (($x + $self->w/$tilesize));
   my $tile_y_min = floor ($y);
   my $tile_y_max = ceil (($y + $self->h/$tilesize));
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
sub draw_entity{
   my ($self, $entity) = @_;
   my $anim = $entity->anim;
   $anim->x(int(($entity->x-$self->x)*$tilesize));
   $anim->y(int(($entity->y-$self->y)*$tilesize));
   $anim->draw();
}



no Mouse;
__PACKAGE__->meta->make_immutable();
1

