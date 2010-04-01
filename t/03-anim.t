use strict;
use warnings;

use SDLx::Animation;

use Test::More tests => 1;

my $main_surf = SDL::Surface->new( SDL_SWSURFACE|SDL_SRCALPHA, 200, 200, 32, 0, 0, 0, 255 );

my $anim = SDLx::Animation->new();
isa_ok ($anim, 'SDLx::Animation');



