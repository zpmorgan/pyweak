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

my $mov_spd = .004;

has clock => (
   is => 'ro',
   isa => 'SDLx::Clock',
   default => sub{ SDLx::Clock->new() },
   lazy => 1 );

my $anim;
my $portrait = SDL::Image::load ('data/vegastrike_male.png');
my $portrait_src_rect = SDL::Rect->new(0,0,250,300);
my $portrait_dest_rect = SDL::Rect->new(650,20,250,300);


sub run{
   my $self = shift;
   $self->app( SDL::Video::set_video_mode( 850, 500, 32, SDL_SWSURFACE ) );
   croak 'Cannot init video mode 800x500x32: ' . SDL::get_error() if !($self->app);
   $self->clock->start();
   
   $self->load_entities;
   
   #initialize map & viewport
   $self->map( Badass::Map->new());
   $self->viewport ( Badass::Viewport->new (
      map=>$self->map, 
      parent_surface=>$self->app,
      x=>0, y=>0,
      w => $self->app->w - 250,
      h => $self->app->h,
      ent => $self->badass,
   ));
   
   
   $anim = SDLx::Animation->new(clock=>$self->clock, w=>100,h=>100,x=>100, y=>100, parent_surface=>$self->app);
   $anim->add_cycle ( name=>'moonwalk', file=>'data/moonwalk.gif', default=>1 );
#   $anim->set_cycle ('moonwalk');
   
   my $prev_clock = $self->clock->get_ticks;
   while(1){
      my $ms_delta = $self->clock->get_ticks - $prev_clock;
      # Get an event object to snapshot the SDL event queue
      my $event = SDL::Event->new();

      while ( SDL::Events::poll_event($event) ) {
         #Get all events from the event queue in our event
         if ($event->type == SDL_QUIT) {
            exit
         }
         elsif ( $event->type == SDL_KEYDOWN ) {
            my $key = $event->key_sym;
            $self->badass->xv($self->badass->xv-$mov_spd) if($key == SDLK_LEFT);
            $self->badass->xv($self->badass->xv+$mov_spd) if($key == SDLK_RIGHT);
            $self->badass->yv($self->badass->yv-$mov_spd) if($key == SDLK_UP);
            $self->badass->yv($self->badass->yv+$mov_spd) if($key == SDLK_DOWN);
         }
         elsif ( $event->type == SDL_KEYUP ) {
            my $key = $event->key_sym;
            $self->badass->xv(0) if($key == SDLK_LEFT);
            $self->badass->xv(0) if($key == SDLK_RIGHT);
            $self->badass->yv(0) if($key == SDLK_UP);
            $self->badass->yv(0) if($key == SDLK_DOWN);
         }
      }
      $self->badass->update_pos($ms_delta);
      $self->draw;
      $prev_clock += $ms_delta;
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
   $self->viewport->draw_entity($self->badass);
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
   $badass_anim->add_cycle(
      name=>'walk', 
      default=>1, 
      frames => [ {
         file=>'data/badass-walk1.png',
         ms => 200,
      },{
         file=>'data/badass-walk2.png',
         ms => 100,
      } ],
   );
   $self->badass (Badass::Entity->new(
      anim => $badass_anim,
      x=>6,
      y=>4,
   ));
}

no Mouse;
__PACKAGE__->meta->make_immutable();
1

