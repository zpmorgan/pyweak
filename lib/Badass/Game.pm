package Badass::Game;
use Mouse;
use Carp;
use SDL;
use SDL::Rect;
use SDL::Surface;
use SDL::Video;
use SDL::Event;
use SDL::Color;
use SDLx::Timer;

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

has timer => (
   is => 'ro',
   isa => 'SDLx::Timer',
   default => sub{ SDLx::Timer->new() },
   lazy => 1 );

sub run{
   my $self = shift;
   $self->app( SDL::Video::set_video_mode( 800, 500, 32, SDL_SWSURFACE ) );
   croak 'Cannot init video mode 800x500x32: ' . SDL::get_error() if !($self->app);
   while(1){
      $self->draw;
   }
}

sub draw{
   my $self = shift;
   SDL::Video::fill_rect(
      $self->app,
      SDL::Rect->new( 0, 0, 800, 500 ),
      SDL::Video::map_RGB( $self->app->format, 0,0,0 )
   SDL::Video::flip($self->app);
}


no Mouse;
__PACKAGE__->meta->make_immutable();
1

