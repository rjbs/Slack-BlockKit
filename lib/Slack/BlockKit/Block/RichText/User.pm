package Slack::BlockKit::Block::RichText::User;
# ABSTRACT: a BlockKit rich text element that mentions a @user

use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasMentionStyle';

=head1 OVERVIEW

This represents the mention of a specific Slack user in a hunk of rich text.
The user name will be styled and linked-to.  So, to send something like:

    I was discussing this with @rjbs.

You would use the L<sugar|Slack::BlockKit::Sugar> like so:

    blocks(richtext(section(
      "I was discussing this with ", user($user_id), "."
    )));

=cut

use v5.36.0;

=attr user_id

This must be the Slack user id for the user being mentioned.  This is generally
a bunch of alphanumeric characters beginning with C<U>.

=cut

has user_id => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

sub as_struct ($self) {
  return {
    type => 'user',
    user_id => $self->user_id,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
