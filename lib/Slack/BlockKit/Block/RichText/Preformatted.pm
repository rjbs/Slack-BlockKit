package Slack::BlockKit::Block::RichText::Preformatted;
use Moose;
use MooseX::StrictConstructor;

use Slack::BlockKit::Types qw(ExpansiveBlockList Pixels);

use experimental qw(signatures); # XXX

# When I tried using this, it got rejected.  Surface-dependent?
has border => (
  is => 'ro',
  isa => Pixels(),
);

has elements => (
  isa => ExpansiveBlockList(),
  traits  => [ 'Array' ],
  handles => { elements => 'elements' },
);

sub as_struct ($self) {
  return {
    type => 'rich_text_preformatted',
    elements => [ map {; $_->as_struct } $self->elements ],
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
