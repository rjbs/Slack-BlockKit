package Slack::BlockKit::Block::RichText::Quote;
use Moose;
use MooseX::StrictConstructor;

use Slack::BlockKit::Types qw(ExpansiveBlockList Pixels);

use v5.36.0;

# When I tried using this, it got rejected.  Surface-dependent?
has border => (
  is => 'ro',
  isa => Pixels(),
  predicate => 'has_border',
);

has elements => (
  isa => ExpansiveBlockList(),
  traits  => [ 'Array' ],
  handles => { elements => 'elements' },
);

sub as_struct ($self) {
  return {
    type => 'rich_text_quote',
    elements => [ map {; $_->as_struct } $self->elements ],
    ($self->has_border ? (border => $self->border) : ()),
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
