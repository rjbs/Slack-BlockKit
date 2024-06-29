package Slack::BlockKit;
use v5.32.0;
use warnings;

use experimental qw(signatures); # XXX

use JSON::XS ();
use Types::Serialiser;

my sub boolify ($val) { $val ? \1 : \0 }

my sub _boolset ($hashref) {
  return { map {; $_ => boolify($hashref->{$_}) } keys %$hashref };
}

package Slack::BlockKit::Block::RichText {
  use Moose;
  use MooseX::StrictConstructor;

  use experimental qw(signatures); # XXX

  has block_id => (is => 'ro', isa => 'Str', predicate => 'has_block_id');

  has elements => (
    isa => 'ArrayRef', # <-- Make better
    traits  => [ 'Array' ],
    handles => { elements => 'elements' },
  );

  sub as_struct ($self) {
    return {
      type => 'rich_text',
      ($self->has_block_id ? (block_id => $self->block_id) : ()),
      elements => [ map {; $_->as_struct } $self->elements ],
    };
  }

  no Moose;
  __PACKAGE__->meta->make_immutable;
}

package Slack::BlockKit::Block::RichText::Section {
  use Moose;
  use MooseX::StrictConstructor;

  use experimental qw(signatures); # XXX

  has elements => (
    isa => 'ArrayRef', # <-- Make better
    traits  => [ 'Array' ],
    handles => { elements => 'elements' },
  );

  sub as_struct ($self) {
    return {
      type => 'rich_text_section',
      elements => [ map {; $_->as_struct } $self->elements ],
    };
  }

  no Moose;
  __PACKAGE__->meta->make_immutable;
}

package Slack::BlockKit::Block::RichText::Quote {
  use Moose;
  use MooseX::StrictConstructor;

  use experimental qw(signatures); # XXX

  # "border" px again

  has elements => (
    isa => 'ArrayRef', # <-- Make better
    traits  => [ 'Array' ],
    handles => { elements => 'elements' },
  );

  sub as_struct ($self) {
    return {
      type => 'rich_text_quote',
      elements => [ map {; $_->as_struct } $self->elements ],
    };
  }

  no Moose;
  __PACKAGE__->meta->make_immutable;
}

package Slack::BlockKit::Block::RichText::Preformatted {
  use Moose;
  use MooseX::StrictConstructor;

  use experimental qw(signatures); # XXX

  # has border => (...); # Seems to fail when sent to Slack!?

  has elements => (
    isa => 'ArrayRef', # <-- Make better
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
}

package Slack::BlockKit::Block::RichText::List {
  use Moose;
  use MooseX::StrictConstructor;

  use experimental qw(signatures); # XXX

  has elements => (
    isa => 'ArrayRef', # <-- Make better
    traits  => [ 'Array' ],
    handles => { elements => 'elements' },
  );

  # pixel things:
  # * indent
  # * offset
  # * border

  has style => (
    is  => 'ro',
    isa => 'Str', # <-- make strict, enum([ qw(bullet ordered) ])
    predicate => 'has_style',
  );

  sub as_struct ($self) {
    return {
      type => 'rich_text_list',
      elements => [ map {; $_->as_struct } $self->elements ],
      ($self->has_style
        ? (style => _boolset($self->style))
        : ()),
      text => $self->text,
    };
  }

  no Moose;
  __PACKAGE__->meta->make_immutable;
}

package Slack::BlockKit::Block::RichText::Channel {
  use Moose;
  use MooseX::StrictConstructor;

  use experimental qw(signatures); # XXX

  has channel_id => (
    is  => 'ro',
    isa => 'Str',
    required => 1,
  );

  has style => (
    is  => 'ro',
    isa => 'HashRef', # <-- make strict
    predicate => 'has_style',
  );

  sub as_struct ($self) {
    return {
      type => 'channel',
      channel_id => $self->channel_id,
      ($self->has_style
        ? (style => _boolset($self->style))
        : ()),
    };
  }

  no Moose;
  __PACKAGE__->meta->make_immutable;
}

package Slack::BlockKit::Block::RichText::User {
  use Moose;
  use MooseX::StrictConstructor;

  use experimental qw(signatures); # XXX

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
}

package Slack::BlockKit::Block::RichText::UserGroup {
  use Moose;
  use MooseX::StrictConstructor;

  use experimental qw(signatures); # XXX

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
}

package Slack::BlockKit::Block::RichText::Emoji {
  use Moose;
  use MooseX::StrictConstructor;

  use experimental qw(signatures); # XXX

  has name => (
    is  => 'ro',
    isa => 'Str', # Unknown names show up as ":bogus_name_here:"
    required => 1,
  );

  sub as_struct ($self) {
    return {
      type => 'emoji',
      name => $self->name,
    };
  }

  no Moose;
  __PACKAGE__->meta->make_immutable;
}

package Slack::BlockKit::Block::RichText::Text {
  use Moose;
  use MooseX::StrictConstructor;

  use experimental qw(signatures); # XXX

  has text => (
    is  => 'ro',
    isa => 'Str',
    required => 1,
  );

  has style => (
    is  => 'ro',
    isa => 'HashRef', # <-- make strict
    predicate => 'has_style',
  );

  sub as_struct ($self) {
    return {
      type => 'text',
      ($self->has_style
        ? (style => _boolset($self->style))
        : ()),
      text => $self->text,
    };
  }

  no Moose;
  __PACKAGE__->meta->make_immutable;
}

package Slack::BlockKit::Block::RichText::Link {
  use Moose;
  use MooseX::StrictConstructor;

  use experimental qw(signatures); # XXX

  has url => (
    is  => 'ro',
    isa => 'Str',
    required => 1,
  );

  has text => (
    is  => 'ro',
    isa => 'Str',
    predicate => 'has_text',
  );

  has unsafe => (
    is  => 'ro',
    isa => 'Bool',
    predicate => 'has_unsafe',
  );

  has style => (
    is  => 'ro',
    isa => 'HashRef', # <-- make strict
    predicate => 'has_style',
  );

  sub as_struct ($self) {
    return {
      type => 'link',

      $self->has_text    ? (text   => $self->text)             : ()),
      ($self->has_unsafe  ? (unsafe => boolify($self->unsafe))  : ()),
      ($self->has_style   ? (style => _boolset($self->style))   : ()),
      url => $self->url,
    };
  }

  no Moose;
  __PACKAGE__->meta->make_immutable;
}

1;
