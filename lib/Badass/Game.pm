package Badass::Game;
use Mouse;

use SDL;
use SDL::Rect;
use SDL::Surface;
use SDL::Video;
use SDL::Event;
use SDL::Color;

#use SDL::GFX::Primitives;
#
#use SDL::Events;

has viewport => (
   is => 'rw',
   isa => 'Badass::Viewport');

has app =>  (
   is => 'rw',
   isa => 'SDL::Surface');

has badass => (
   is => 'rw',
   isa => 'Badass::Entity');


sub run{
   my $self = shift;
   $self->app( SDL::Video::set_video_mode( 800, 500, 32, SDL_SWSURFACE ) );
   
}

sub draw{
   
}


no Mouse;
__PACKAGE__->meta->make_immutable();
1

