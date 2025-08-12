package Slack::BlockKit::Block::Image;
# ABSTRACT: a Block Kit image block, used to show an image

use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::Block';

=head1 OVERVIEW

This represents an C<image> block, which displays an image.

=cut

use v5.36.0;

use Moose::Util::TypeConstraints qw(class_type);
use MooseX::Types::Moose qw(ArrayRef);

=attr alt_text

This is a simple string, which provides alt text.  It's I<not> a text
composition object, and can't contain Markdown or mrkdwn.

=cut

has alt_text => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

=attr image_url

This is a string giving the URL for the image.  If you don't provide this,
you'd have to provide C<slack_file>.  Unfortunately, though, Slack::BlockKit
doesn't support that!

=cut

has image_url => (
  is => 'ro',
  isa => 'Str',
  predicate => 'has_image_url',
  required => 1, # eventually, allow an unset image_url if we add slack_file
);

=attr title

This attribute stores a title to display for the image.  It should be a L<text
composition object|Slack::BlockKit::CompObj::Text>, but it's optional and you
can leave it out.

=cut

has title => (
  is => 'ro',
  isa => class_type('Slack::BlockKit::CompObj::Text'),
  predicate => 'has_title',
);

sub BUILD ($self, @) {
  if ($self->has_title && $self->title->type ne 'plain_text') {
    Carp::croak("non-plain_text text object provided as title for image");
  }
}

sub as_struct ($self) {
  return {
    type => 'image',
    image_url => $self->image_url,
    alt_text  => $self->alt_text,
    ($self->has_title
      ? (title => $self->title->as_struct)
      : ()),
  };
}

no Moose;
no Moose::Util::TypeConstraints;
no MooseX::Types::Moose;
__PACKAGE__->meta->make_immutable;
