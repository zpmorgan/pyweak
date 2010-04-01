package SDLx::Clock;

use strict;
use warnings;
use SDL;

=head1 NAME

SDLx::Clock - A clock for your SDL game, with pause control

=head1 SYNOPSIS

 use SDLx::Clock;
 my $clock = SDLx::Clock->new();
 say $clock->get_ticks; #0!
 sleep(1);
 say $clock->get_ticks; #0
 $clock->start;
 sleep(1);
 say $clock->get_ticks; #near 1000

=head1 DESCRIPTION

This is based on lesson 13 and 14 from L<< http://lazyfoo.net/SDL_tutorials/index.php >>

=head1 TODO

Changes in speed! Time travel! Alternate dimensions! Multiple time-like dimensions!

=cut

sub new {
   my $class = shift;
   my $self = bless {@_}, $class;

   $self->{start_ticks} = 0;
   $self->{started} = 0;
   $self->{paused} = 0;

   return $self;
}


sub start{
   my $self = shift;
   warn 'starting while started' if $self->{started};
   $self->{started} = 1; 
   $self->{start_ticks} = SDL::get_ticks();  
}

sub stop{
   my $self = shift;
   warn 'stopping while stopped' unless $self->{started};
   delete $self->{start_ticks};
   $self->{started} = 0;  
   $self->{paused} = 0; 
}

sub pause{
   my $self = shift;
   warn 'pausing while paused' if $self->{paused};
   unless ($self->{started}){
      warn 'pausing while stopped starting & pausing.';
      $self->{frozen_ticks} = 0;
      $self->{paused} = 1;
      $self->{started} = 1;
   }
   if ( $self->{started} && !$self->{paused} )
   {
      $self->{paused} = 1;
      $self->{frozen_ticks} = SDL::get_ticks() - $self->{start_ticks};
   }
}

sub unpause{
   my $self = shift;
   if ( $self->{paused} )
   {
      $self->{paused} = 0;
      $self->{start_ticks} = SDL::get_ticks() - $self->{frozen_ticks};
   } 
   else {
      warn 'unpausing while not paused';
   }
}

sub get_ticks{
   my $self = shift;
   
   if ( $self->{started} ){
      return SDL::get_ticks() - $self->{start_ticks};
   }
   if ( $self->{paused} ){
      return $self->{frozen_ticks};
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
