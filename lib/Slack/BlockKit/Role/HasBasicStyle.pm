package Slack::BlockKit::Role::HasBasicStyle;
# ABSTRACT: a Block Kit element with optional (bold, code, italic, strike) styles

use Moose::Role;

=head1 OVERVIEW

This is a specialization of the role L<Slack::BlockKit::Role::HasBasicStyle>,
in which the permitted C<styles> are:

=for :list
* bold
* code
* italic
* strike

=cut

with 'Slack::BlockKit::Role::HasStyle' => {
  styles => [ qw( bold italic strike code ) ],
};

no Moose::Role;
1;
