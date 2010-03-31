package SDLx::Timer;

use strict;
use warnings;
use SDL;

=head1 NAME

SDLx::Timer - A timer for your SDL game, with pause control

=head1 SYNOPSIS

 use SDLx::Timer;
 my $timer = SDLx::Timer->new();
 say $timer->get_ticks; #0!
 sleep(1);
 say $timer->get_ticks; #0
 $timer->start;
 sleep(1);
 say $timer->get_ticks; #near 1000

=head1 DESCRIPTION

This is based on lesson 13 and 14 from L<< http://lazyfoo.net/SDL_tutorials/index.php >>

=head1 TODO

Changes in speed! Time travel! Alternate dimensions! Multiple time-like dimensions!

=cut

sub new {
   my $class = shift;
   my $self = bless {@_}, $class;

   $self->{started_ticks} = 0;
   $self->{paused_ticks} = 0;
   $self->{started} = 0;
   $self->{paused} = 0;

   return $self;
}


sub start{
   my $self = shift;
   warn 'starting while started' if $self->{started};
   $self->{started} = 1; 
   $self->{started_ticks} = SDL::get_ticks();  
}

sub stop{
   my $self = shift;
   warn 'stopping while stopped' unless $self->{started};

   $self->{started} = 0;  
   $self->{paused} = 0; 
}

sub pause{
   my $self = shift;
   warn 'pausing while paused' if $self->{paused};
   warn 'pausing while stopped' unless $self->{started};
   if ( $self->{started} && !$self->{paused} )
   {
      $self->{paused} = 1;

      $self->{paused_ticks} = SDL::get_ticks() - $self->{started_ticks};
   }
}

sub unpause{
   my $self = shift;
   if ( $self->{paused} )
   {
      $self->{paused} = 0;

      $self->{started_ticks} = SDL::get_ticks() - $self->{started_ticks};

      $self->{paused_ticks} = 0;
   } 
   else {
      warn 'unpausing while not paused';
   }
}

sub get_ticks{
   my $self = shift;
   if ( $self->{started} ){
      if ( $self->{paused} ){
         return $self->{paused_ticks};
      }
      else{
         my $update = SDL::get_ticks();
         my $diff = $update - $self->{started_ticks};
         $self->{started_ticks} = $update;
         return $diff;
      }
   }
   return 0;
}

sub is_started{
   my $self = shift;
   return $self->{started}
}


sub is_paused{
   my $self = shift;
   return $self->{paused}
}

1;
