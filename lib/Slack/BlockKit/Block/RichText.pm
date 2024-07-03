package Slack::BlockKit::Block::RichText;
use Moose;
use MooseX::StrictConstructor;
use Slack::BlockKit::Types qw(RichTextBlocks);

with 'Slack::BlockKit::Role::Block';

use v5.36.0;

has elements => (
  isa => RichTextBlocks(),
  traits  => [ 'Array' ],
  handles => { elements => 'elements' },
);

sub as_struct ($self) {
  return {
    type => 'rich_text',
    elements => [ map {; $_->as_struct } $self->elements ],
  };
}

no Slack::BlockKit::Types;
no Moose;
__PACKAGE__->meta->make_immutable;
