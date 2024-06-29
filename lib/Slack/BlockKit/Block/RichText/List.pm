package Slack::BlockKit::Block::RichText::List;
use Moose;
use MooseX::StrictConstructor;

use Moose::Util::TypeConstraints qw(class_type enum);
use MooseX::Types::Moose qw(ArrayRef);
use Slack::BlockKit::Types qw(RichTextArray);

use experimental qw(signatures); # XXX

has elements => (
  isa => RichTextArray(),
  traits  => [ 'Array' ],
  handles => { elements => 'elements' },
);

# pixel things:
# * indent
# * offset
# * border

has style => (
  is  => 'ro',
  isa => enum([ qw(bullet ordered) ]),
  required => 1,
);

sub as_struct ($self) {
  return {
    type => 'rich_text_list',
    elements => [ map {; $_->as_struct } $self->elements ],
    style => $self->style,
  };
}

no Moose::Util::TypeConstraints;
no Moose;
__PACKAGE__->meta->make_immutable;
