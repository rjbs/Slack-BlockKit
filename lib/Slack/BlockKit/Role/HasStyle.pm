package Slack::BlockKit::Role::HasStyle;
use Moose::Role;

use experimental 'signatures';

my sub boolify ($val) { $val ? \1 : \0 }

my sub _boolset ($hashref) {
  return { map {; $_ => boolify($hashref->{$_}) } keys %$hashref };
}

has style => (
  is  => 'ro',
  isa => 'HashRef', # <-- make strict
  predicate => 'has_style',
);

around as_struct => sub {
  my ($orig, $self, @rest) = @_;

  my $struct = $self->$orig(@rest);

  if ($self->has_style) {
    $struct->{style} = _boolset($self->style);
  }

  return $struct;
};

no Moose::Role;
1;
