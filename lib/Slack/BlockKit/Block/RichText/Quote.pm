package Slack::BlockKit::Block::RichText::Quote;
use Moose;
use MooseX::StrictConstructor;

use Slack::BlockKit::Types qw(ExpansiveBlockList);

use experimental qw(signatures); # XXX

# "border" px again

has elements => (
  isa => ExpansiveBlockList(),
  traits  => [ 'Array' ],
  handles => { elements => 'elements' },
);

sub as_struct ($self) {
  return {
    type => 'rich_text_quote',
    elements => [ map {; $_->as_struct } $self->elements ],
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
