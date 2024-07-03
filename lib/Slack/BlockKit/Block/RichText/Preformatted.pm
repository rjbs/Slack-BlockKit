package Slack::BlockKit::Block::RichText::Preformatted;
use Moose;
use MooseX::StrictConstructor;

use Slack::BlockKit::Types qw(ExpansiveElementList Pixels);

use v5.36.0;

# When I tried using this, it got rejected.  Surface-dependent?
has border => (
  is => 'ro',
  isa => Pixels(),
);

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
