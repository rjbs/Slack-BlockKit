package Slack::BlockKit::Block::RichText::UserGroup;
# ABSTRACT: a Block Kit rich text element that mentions a @usergroup

use Moose;
use MooseX::StrictConstructor;

with 'Slack::BlockKit::Role::HasMentionStyle';

=head1 OVERVIEW

This represents the mention of a specific Slack user group in a hunk of rich
text.  The group name will be styled and linked-to.  So, to send something
like:

    I will ask @team-tam.

You would use the L<sugar|Slack::BlockKit::Sugar> like so:

    blocks(richtext(section(
      "I will ask ", usergroup($usergroup_id), "."
    )));

=cut

use v5.36.0;

=attr usergroup_id

This must be the Slack usergroup id for the group being mentioned.  This is
generally a bunch of alphanumeric characters beginning with C<S>.

=cut

has usergroup_id => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

sub as_struct ($self) {
  return {
    type => 'usergroup',
    usergroup_id => $self->usergroup_id,
  };
}

no Moose;
__PACKAGE__->meta->make_immutable;
