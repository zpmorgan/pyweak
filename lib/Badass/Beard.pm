package Badass::Beard;
use Mouse;

has pieces => (
   is => 'rw',
   isa => 'HashRef',
   default=>sub{{}} );

no Mouse;
__PACKAGE__->meta->make_immutable();
1

