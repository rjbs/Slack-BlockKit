package Slack::BlockKit::Role::HasStyle;
# ABSTRACT: a parameterized role for objects with styles

use MooseX::Role::Parameterized;

=head1 OVERVIEW 

This role exists to help write classes for Block Kit objects that have text
styles applied.  Because not all objects with styles permit all the same
styles, this is a I<parameterized> role, and must be included by providing a
C<styles> parameter, which is an arrayref of style names that may be enabled or
disabled on an object.

When a Block Kit object class that composes this role is converted into a data
structure with C<as_struct>, the styled defined in that instance's C<style>
hash will be added as JSON boolean objects.

You probably don't need to think about this role, though.

=cut

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
