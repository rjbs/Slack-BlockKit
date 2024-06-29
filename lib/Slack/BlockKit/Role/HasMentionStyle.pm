package Slack::BlockKit::Role::HasMentionStyle;
use Moose::Role;

with 'Slack::BlockKit::Role::HasStyle' => {
  styles => [
    qw( bold italic strike ), # the basic styles (HasBasicStyle) minus code
    qw( highlight client_highlight unlink ), # mysteries to rjbs
  ],
};

no Moose::Role;
1;
