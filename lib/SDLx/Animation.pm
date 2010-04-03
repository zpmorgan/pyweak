package SDLx::Animation;
use Mouse;

use SDL;
use SDL::Surface;
use SDL::Image;
use SDL::Rect;
use SDL::Video;

has parent_surface => (
   is => 'rw',
   isa => 'SDL::Surface',
);

#this is anything with a 'get_ticks' method.
has clock => (
   is => 'rw',
   required => 1,
);

#these are in pixels; h,w are immutable; x and y are of course mutable
#perhaps h and w should be overridable in each cycle or frame?
for my $dimnsn(qw/h w/){
   has $dimnsn => (
      is => 'ro',
      isa => 'Int',
      lazy => 1,
      default => sub {$_[0]->_default_dimension($dimnsn)}
   );
}
for (qw/x y/){
   has $_ => (
      is => 'rw',
      isa => 'Int',
   );
}

has cycles => (
   is => 'ro',
   isa => 'HashRef[HashRef]',
   default => sub{{}},
);
has default_cycle => (
   is => 'rw',
   isa => 'Str',
);
has _current_cycle => (
   is => 'rw',
   isa => 'HashRef',
   lazy => 1,
   default => sub { die 'needs default cycle' unless $_[0]->default_cycle ; $_[0]->cycles->{$_[0]->default_cycle} },
);

sub current_cycle_name {
   my $self = shift;
   return $self->_current_cycle->{name};
}

=head1 NAME

SDLx::Animation - Defining animated entity behavior

=head1 SYNOPSIS

   my $anim = SDLx::Animation->new (
      clock => $clock,
      default_cycle => 'breathe',
      parent_surface => $app,
   );
   $anim->add_cycle(
      name => 'breathe',
      frames => [
         {
            file => 'inhale.png',
            ms => 300,
         }, {
            file => 'exhale.png',
            ms => 200,
         },
      ]
   );
   
   $anim->add_cycle (
      name => 'laugh',
      file => 'laugh-block.gif',
      after_cycle => 'breathe',
      default => 1,
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

=head2 translate_cycle

=head2 adjust_time

=cut


#effectively, the clock value from when animation starts
has _start_time => (
   is => 'rw',
   isa => 'Int',
   default => sub{$_[0]->clock->get_ticks},
   lazy=>1,
);
sub _current_frame_num{
   my $self = shift;
   my $cycle = $self->_current_cycle;
   my $ticks = $self->clock->get_ticks - $self->_start_time;
   $ticks %= $cycle->{interval};
   return $cycle->{span}->lookup($ticks);
}
sub _current_frame{
   my $self = shift;
   my $i = $self->_current_frame_num;
   return $self->_current_cycle->{frames}[$i];
}


=head2 add_cycle

 $anim->add_cycle ( %params );

Required parameters are name and frames. Frames is an array reference.

Img is a filename.

Each frame has an interval and a source, which is an file and u/v coordinates.
u and v both default to 0, and file defaults to the cycle's file, if it exists.

=cut

use Array::IntSpan;


sub add_cycle {
   my ($self, %cycle) = @_;
   $self->cycles->{$cycle{name}} = \%cycle;
   
   if ($cycle{default}){
      $self->default_cycle ($cycle{name});
   }
   
   #load file(s)
   if ($cycle{frames}){
      $self->_load_frames(\%cycle);
   }
   else { #gif?
      $self->_load_gif(\%cycle);
   }
   
   #syntax: $rhash{'1.4,1.8'}      = 'Jim';
   #    $rhash{1.5} eq 'Jim'
   my $span = Array::IntSpan->new();
   $cycle{span} = $span;
   
   #number the frames, and determine offsets.
   my $i=0;
   my $offset = 0;
   for my $frame (@{$cycle{frames}}){
      $frame->{ms} = 1000 unless defined $frame->{ms};
      $frame->{n} = $i;
      $frame->{offset} = $offset;
      #warn "$offset,".($offset+$frame->{ms}-1);
      #$range{"$offset,".($offset+$frame->{ms}-1)} = $i;
      $span->set_range($offset, $offset+$frame->{ms}-1, $i);
      $offset += $frame->{ms};
      $i++;
   }
   $cycle{interval} = $offset;
}

#do some dwim, and load images into sdl::surfaces
sub _load_frames{
   my ($self, $cycle) = @_;
   for my $frame (@{$cycle->{frames}}){
      $frame->{u} //= 0;
      $frame->{v} // 0;
      $frame->{ms} //= 100; #sensible default?
      my $filename = $frame->{file} // $cycle->{file};
      $frame->{surf} = SDL::Image::load ($filename);
      #todo: have frames from the same file use the same surface
      warn "file $filename not loaded for some reason" unless $frame->{surf};
   }
}

# use Imager library to read gifs
sub _load_gif{
   my ($self, $cycle) = @_;
   unless ($Imager::VERSION){
      eval('use Imager');
      if ($@){
         die $@;
      }
   }
   my $filename = $cycle->{file};
   my @imgs = Imager->read_multi(file=>$filename)
           or die "Cannot read: ", Imager->errstr;
   $filename =~ s#/#-#g;
   my @frames;
   for my $i (0..$#imgs){
      my $frame_filename = $filename;
      $frame_filename =~ s# \.gif$ #$i\.gif#ix;
      $frame_filename = '/tmp/'.$frame_filename;
      # "/tmp/data-pics-MichaelJacksonMoonwalk2.gif", like such as..
      #small potential for filename collisions, except with previous runs.
      #maybe there's a way to hold images in memory and have SDL use those.
      
      if (-e $frame_filename){
         unlink $frame_filename;
      }
      
      my $img = $imgs[$i];
      #warn $frame_filename;
      $img->write(file=>$frame_filename)
         or die "Cannot write: ",$img->errstr;

      push @frames, {
         u=>0,
         v=>0,
         ms => $img->tags(name=>'gif_delay')*10,
         file => $frame_filename,
         surf => SDL::Image::load($frame_filename),
      }
   }
   $cycle->{frames} = \@frames;
}

sub _default_dimension{
   my $self = shift;
   my $WorH = shift; #'w' or 'h'
   my $cycle = $self->_current_cycle;
   return $cycle->{frames}[0]{surf}->$WorH;
}

=head2 set_cycle

 $anim->set_cycle('drink_coffee');

=cut

sub set_cycle {
   my ($self, $cycle_name) = @_;
   $self->_current_cycle($self->cycles->{$cycle_name});
}

=head2 draw

Draws current frame on C<< $self->parent_surface >>,
based on the current cycle and C<< $self->clock >>.

=cut

sub draw{
   my $self = shift;
   SDL::Video::blit_surface (
      $self->_current_frame->{surf}, $self->src_rect,
      $self->parent_surface,         $self->dest_rect
   );
}

sub src_rect{
   my $self = shift;
   return SDL::Rect->new(0,0,$self->w,$self->h)
}
sub dest_rect{
   my $self = shift;
   return SDL::Rect->new($self->x,$self->y, $self->w,$self->h);
}

no Mouse;
__PACKAGE__->meta->make_immutable();

'like such as'
