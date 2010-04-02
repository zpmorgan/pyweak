package Badass::Game;
use Mouse;
use Carp;
use SDL;
use SDL::Rect;
use SDL::Surface;
use SDL::Video;
use SDL::Event;
use SDL::Events;
use SDL::Color;
use SDLx::Clock;
use SDLx::Animation;

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

has clock => (
   is => 'ro',
   isa => 'SDLx::Clock',
   default => sub{ SDLx::Clock->new() },
   lazy => 1 );

my $anim;
my $portrait = SDL::Image::load ('data/vegastrike_male.png');
my $portrait_rect = SDL::Rect->new(350,20,250,300);

sub run{
   my $self = shift;
   $self->app( SDL::Video::set_video_mode( 600, 400, 32, SDL_SWSURFACE ) );
   croak 'Cannot init video mode 800x500x32: ' . SDL::get_error() if !($self->app);
   $self->clock->start();

   $anim = SDLx::Animation->new(clock=>$self->clock, w=>100,h=>100,x=>100, y=>100, parent_surface=>$self->app);
   $anim->add_cycle ( name=>'moonwalk', file=>'data/moonwalk.gif' );
   $anim->set_cycle ('moonwalk');
   
   while(1){
      # Get an event object to snapshot the SDL event queue
      my $event = SDL::Event->new();

      while ( SDL::Events::poll_event($event) ) {
         #Get all events from the event queue in our event
         if ($event->type == SDL_QUIT)
         {
            exit
         }
      }
      $self->draw;
   }
}

sub draw{
   my $self = shift;
   SDL::Video::fill_rect(
      $self->app,
      SDL::Rect->new( 0, 0, $self->app->w, $self->app->h ),
      SDL::Video::map_RGB( $self->app->format, 0,55,0 )
   );
   $anim->draw;
   $
   SDL::Video::flip($self->app);
}


no Mouse;
__PACKAGE__->meta->make_immutable();
1

