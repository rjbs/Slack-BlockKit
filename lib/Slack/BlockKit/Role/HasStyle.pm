package Slack::BlockKit::Role::HasStyle;
use MooseX::Role::Parameterized;

use v5.36.0;

use MooseX::Types::Moose qw(ArrayRef Bool);
use MooseX::Types::Structured qw(Dict Optional);

my sub _boolset ($hashref) {
  return {
    map {; $_ => Slack::BlockKit::boolify($hashref->{$_}) } keys %$hashref,
  };
}

parameter styles => (
  is  => 'bare',
  isa => 'ArrayRef[Str]',
  required  => 1,
  traits    => [ 'Array' ],
  handles   => { styles => 'elements' },
);

role {
  my ($param) = @_;

  has style => (
    is  => 'ro',
    isa => Dict[ map {; $_ => Optional([Bool]) } $param->styles ],
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
};

no MooseX::Types::Moose;
no MooseX::Types::Structured;

no Moose::Role;
1;
