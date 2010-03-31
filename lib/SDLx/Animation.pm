package SDLx::Animation;
use Mouse;

use SDL;
use SDL::Surface;
use SDL::Rect;
use SDL::Video;

#these are in pixels; h,w are immutable; x and y are of course mutable
#perhaps h and w should be overridable in each cycle or frame?
for (qw/h w/){
   has $_ => (
      is => ro,
      isa => 'Int',
   );
}
for (qw/x y/){
   has $_ => (
      is => rw,
      isa => 'Int',
   );
}

has cycles => (
   is => 'ro',
   isa => 'Hashref{Animcycle}',
   default => sub{{}},
);
has default_cycle => (
   is => 'rw',
   isa => 'Str',
);
has parent_surface => (
   is => 'rw',
   isa => 'SDL::Surface',
);

=head1 NAME

SDLx::Animation - Defining animated entity behavior

=head1 SYNOPSIS

   my $anim = SDLx::Animation->new (
      timer => $timer,
      default => 'breathe',
      parent_surface => $app,
   );
   $anim->add_cycle(
      name => 'breathe',
      frames => [
         {
            img => 'inhale.png',
            ms => 300,
         }, {
            img => 'exhale.png',
            ms => 200,
         },
      ]
   );
   
   $anim->add_cycle (
      name => 'laugh',
      img => 'entire-laugh.gif',
      after_cycle => 'breathe',
      frames => [
         {
            u => 0,
            v => 0,
            ms => 88,
         }, {
            u => 32,
            v => 0,
            ms => 25,
         }, {
            u => 0,
            v => 32,
            ms => 150,
         },
         }, {
            u => 32,
            v => 32,
            ms => 40,
         },
      ],
   );

=head1 METHODS

=head2 draw

Draws current frame on C<< $self->parent_surface >>,
based on the current cycle and C<< $self->timer >>.

=cut












