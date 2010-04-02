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

has map => (
   is => 'rw',
   isa => 'Badass::Map');

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
my $portrait_src_rect = SDL::Rect->new(0,0,250,300);
my $portrait_dest_rect = SDL::Rect->new(450,20,250,300);


sub run{
   my $self = shift;
   $self->app( SDL::Video::set_video_mode( 700, 400, 32, SDL_SWSURFACE ) );
   croak 'Cannot init video mode 800x500x32: ' . SDL::get_error() if !($self->app);
   $self->clock->start();
   
   $self->load_entities;
   
   #initialize map & viewport
   $self->map( Badass::Map->new());
   $self->viewport ( Badass::Viewport->new (
      map=>$self->map, 
      parent_surface=>$self->app,
      x=>0, y=>0,
      ent => $self->badass,
   ));
   
   
   $anim = SDLx::Animation->new(clock=>$self->clock, w=>100,h=>100,x=>100, y=>100, parent_surface=>$self->app);
   $anim->add_cycle ( name=>'moonwalk', file=>'data/moonwalk.gif', default=>1 );
#   $anim->set_cycle ('moonwalk');
   
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
   $self->viewport->draw;
   $anim->draw;
   $self->badass->draw();
   #draw face
   SDL::Video::blit_surface (
      $portrait, $portrait_src_rect,
      $self->app,$portrait_dest_rect);
      
   SDL::Video::flip($self->app);
}

sub load_entities{
   my $self = shift;
   
   #load badass animation and entity
   my $badass_anim = SDLx::Animation->new(
      parent_surface=>$self->app,
      clock => $self->clock,
      w=>32,h=>32, #x=>0, y=>0,
      default_cycle => 'stand',
   );
   $badass_anim->add_cycle(
      name=>'stand', 
      default=>1, 
      frames => [ {
         file=>'data/badass1.png',
      } ],
   );
   $self->badass (Badass::Entity->new(
      anim => $badass_anim,
      x=>200,
      y=>200,
   ));
}

no Mouse;
__PACKAGE__->meta->make_immutable();
1

