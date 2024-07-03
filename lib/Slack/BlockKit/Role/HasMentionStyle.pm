package Slack::BlockKit::Role::HasMentionStyle;
# ABSTRACT: a BlockKit element with a bunch of styles

use Moose::Role;

=head1 OVERVIEW

This is a specialization of the role L<Slack::BlockKit::Role::HasBasicStyle>,
in which the permitted C<styles> are:

=for :list
* bold
* code
* italic
* strike
* highlight
* client_highlight
* unlink

The author of this library doesn't know what those last three do, but they are
documented.

=cut

with 'Slack::BlockKit::Role::HasStyle' => {
  styles => [
    qw( bold italic strike ), # the basic styles (HasBasicStyle) minus code
    qw( highlight client_highlight unlink ), # mysteries to rjbs
  ],
};

no Moose::Role;
1;
