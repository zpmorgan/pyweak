use strict;
use warnings;

use SDL;
use SDL::App;
use SDL::Events;
#use SDL::Surface;
use SDL::Video;
use SDLx::Timer;
use SDLx::Animation;
use Carp;




#Initing video
#Die here if we cannot make video init
croak 'Cannot init video ' . SDL::get_error()
  if ( SDL::init(SDL_INIT_VIDEO) == -1 );

#Make our display window
#This is our actual SDL application window
my $app = SDL::Video::set_video_mode( 800, 500, 32, SDL_SWSURFACE );

croak 'Cannot init video mode 800x500x32: ' . SDL::get_error() if !($app);


my $timer = SDLx::Timer->new();
$timer->start;

my $anim = SDLx::Animation->new(timer=>$timer, x=>100, y=>100);
$anim->add_cycle ( name=>'moonwalk', file=>'data/moonwalk.gif' );

# Get an event object to snapshot the SDL event queue
my $event = SDL::Event->new();
while (1){
   
   while ( SDL::Events::poll_event($event) )
   {    #Get all events from the event queue in our event
      if ($event->type == SDL_QUIT)
      {
         exit
      }
   }
   
   SDL::Video::fill_rect(
      $app,
      SDL::Rect->new( 0, 0, $app->w, $app->h ),
      SDL::Video::map_RGB( $app->format, 0,0,0 )
   );
   $anim->draw;
   SDL::Video::flip($app);
}
