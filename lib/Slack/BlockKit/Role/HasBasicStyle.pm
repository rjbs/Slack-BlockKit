package Slack::BlockKit::Role::HasBasicStyle;
use Moose::Role;

with 'Slack::BlockKit::Role::HasStyle' => {
  styles => [ qw( bold italic strike code ) ],
};

no Moose::Role;
1;
