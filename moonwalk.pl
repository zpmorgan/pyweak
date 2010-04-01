#!/usr/bin/perl
use strict;
use warnings;

use lib 'lib';

use SDL;
use SDL::App;
use SDL::Events;
#use SDL::Surface;
use SDL::Video;
use SDLx::Clock;
use SDLx::Animation;
use Carp;


# If Imager gives you this error:
#   Undefined subroutine &Imager::i_readgif_multi_wiol called at /usr/local/lib/perl/5.10.0/Imager.pm line 1990.
# then you need to install libgif-dev and rebuild Imager.


#Initing video
#Die here if we cannot make video init
croak 'Cannot init video ' . SDL::get_error()
  if ( SDL::init(SDL_INIT_VIDEO) == -1 );

#Make our display window
#This is our actual SDL application window
my $app = SDL::Video::set_video_mode( 800, 500, 32, SDL_SWSURFACE );

croak 'Cannot init video mode 800x500x32: ' . SDL::get_error() if !($app);


my $clock = SDLx::Clock->new();
$clock->start;

my $anim = SDLx::Animation->new(clock=>$clock, w=>100,h=>100,x=>100, y=>100, parent_surface=>$app);
$anim->add_cycle ( name=>'moonwalk', file=>'data/moonwalk.gif' );
$anim->set_cycle ('moonwalk');

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
      SDL::Video::map_RGB( $app->format, 0,55,0 )
   );
   $anim->draw;
   SDL::Video::flip($app);
}
