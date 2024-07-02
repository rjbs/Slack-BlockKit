package Slack::BlockKit::Block::RichText::List;
use Moose;
use MooseX::StrictConstructor;

use Moose::Util::TypeConstraints qw(class_type enum);
use MooseX::Types::Moose qw(ArrayRef);
use Slack::BlockKit::Types qw(Pixels RichTextArray);

use experimental qw(signatures); # XXX

has elements => (
  isa => RichTextArray(),
  traits  => [ 'Array' ],
  handles => { elements => 'elements' },
);

# I don't know how to use these successfully. -- rjbs, 2024-06-29
my @PX_PROPERTIES = qw(indent offset border);
for my $name (@PX_PROPERTIES) {
  has $name => (
    is => 'ro',
    isa => Pixels(),
    predicate => "has_$name",
  );
}

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

    (map {; my $p = "has_$_"; ($self->$p ? ($_ => $self->$_) : ()) }
      @PX_PROPERTIES)
  };
}

no Moose::Util::TypeConstraints;
no Moose;
__PACKAGE__->meta->make_immutable;
