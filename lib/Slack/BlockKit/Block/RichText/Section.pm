package Slack::BlockKit::Block::RichText::Section;
# ABSTRACT: a collection of rich text elements

use Moose;
use MooseX::StrictConstructor;

use Slack::BlockKit::Types qw(ExpansiveElementList);

=head1 OVERVIEW

This object represents a rich text section, which is just an array of rich text
elements.  For more info on what you can put in a rich text section, consult
the Slack docs.

=cut

use v5.36.0;

=attr elements

This must be an arrayref of RichText element objects, from the approved list
according to the Block Kit docs.

=cut

has elements => (
  isa => ExpansiveElementList(),
  traits  => [ 'Array' ],
  handles => { elements => 'elements' },
);

sub as_struct ($self) {
  return {
    type => 'rich_text_section',
    elements => [ map {; $_->as_struct } $self->elements ],
  };
}

no Moose;
no Slack::BlockKit::Types;
__PACKAGE__->meta->make_immutable;
