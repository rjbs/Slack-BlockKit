package Slack::BlockKit::Block::RichText::Quote;
# ABSTRACT: a BlockKit rich text "quoted text" block

use Moose;
use MooseX::StrictConstructor;

use Slack::BlockKit::Types qw(ExpansiveElementList Pixels);

=head1 OVERVIEW

This is a "quote" element, which is formatted something like C<< > >>-prefixed
text in Markdown.

=cut

use v5.36.0;

=attr border

This property is meant to be the number of pixels wide the border is.  In
practice, the author has only found this to cause Slack to reject BlockKit
structures.

=cut

has border => (
  is => 'ro',
  isa => Pixels(),
  predicate => 'has_border',
);

=attr elements

This is an arrayref of rich text elements.

=cut

has elements => (
  isa => ExpansiveElementList(),
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
