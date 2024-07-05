package Slack::BlockKit::Block::RichText::Preformatted;
# ABSTRACT: a Block Kit preformatted rich text element

use Moose;
use MooseX::StrictConstructor;

use Slack::BlockKit::Types qw(ExpansiveElementList Pixels);

=head1 OVERVIEW

This is a "preformatted" element, which basically just means a code block of
the sort you'd get with C<``` ... ```> in Markdown.

=cut

use v5.36.0;

=attr border

This property is meant to be the number of pixels wide the border is.  In
practice, the author has only found this to cause Slack to reject Block Kit
structures.

=cut

has border => (
  is => 'ro',
  isa => Pixels(),
);

=attr elements

This is an arrayref of rich text elements.  For more information, see the slack
Block Kit documentation.

=cut

# Now, the documentation says that "link" elements inside "preformatted" blocks
# are special, and that while normal "link" elements can have (bold, italic,
# strike, code) styles, they *can't* have (strike) or (code) when inside a
# preformatted block.
#
# Testing shows this is not true, so I have not special-cased anything.  (I
# actually wrote the code, but then experiments showed it was not enforced.  I
# filed a bug.)
has elements => (
  isa => ExpansiveElementList(),
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
