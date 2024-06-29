package Slack::BlockKit::Sugar;
use v5.36.0;

use Carp ();
use Params::Util qw(_HASHLIKE);
use Slack::BlockKit;

use Sub::Exporter -setup => {
  exports => [
    qw( rich ),
    qw( section list preformatted quote ), # top-level
    qw( channel emoji link text user usergroup ), # deeper
  ],
  groups  => {
    richtext => [
      qw( rich ),
      qw( section list preformatted quote ),
      qw( channel emoji link text user usergroup ),
    ],
  },
};

my sub _textify (@things) {
  [
    map {;  ref($_)
        ? $_
        : Slack::BlockKit::Block::RichText::Text->new({ text => $_ })
        } @things
  ]
}

my sub _sectionize (@things) {
  [
    map {;  ref($_)
        ? $_
        : Slack::BlockKit::Block::RichText::Section->new({
            elements => _textify($_),
          })
        } @things
  ];
}

# the rich text block itself

sub rich (@elements) {
  Slack::BlockKit::Block::RichText->new({
    elements => _sectionize(@elements),
  })
}

## things you can put in a `rich_text` block (in order of Slack docs)

sub section (@elements) {
  Slack::BlockKit::Block::RichText::Section->new({
    elements => _textify(@elements),
  });
}

# maybe also supply ulist and olist for bullet and ordered styles
sub list ($arg, @sections) {
  # my $arg = _HASHLIKE($sections[0]) ? (shift @sections) : {};
  Slack::BlockKit::Block::RichText::List->new({
    %$arg,
    elements => _sectionize(@sections),
  });
}

# ({...}, @( elem | text )
sub preformatted (@elements) {
  my $arg = _HASHLIKE($elements[0]) ? (shift @elements) : {};

  Slack::BlockKit::Block::RichText::Preformatted->new({
    %$arg,
    elements => _textify(@elements),
  });
}

# ({...}, @( elem | text )
sub quote (@elements) {
  my $arg = _HASHLIKE($elements[0]) ? (shift @elements) : {};

  Slack::BlockKit::Block::RichText::Quote->new({
    %$arg,
    elements => _textify(@elements),
  });
}

## things you can put in (section, list, preformatted, or quote)

sub channel {
  my ($arg, $id)
    = @_ == 2 ? @_
    : @_ == 1 ? ({}, $_[0])
    : Carp::croak("BlockKit channel sugar called with wrong number of arguments");

  Slack::BlockKit::Block::RichText::Channel->new({
    %$arg,
    channel_id => $id,
  });
}

sub emoji ($name) {
  Slack::BlockKit::Block::RichText::Emoji->new({
    name => $name,
  });
}

# (url) or (url, text) or (url, text, {...}) or (url, {...})
# signature provided to limit arity to 3
sub link {
  Carp::croak("BlockKit link sugar called with wrong number of arguments")
    if @_ > 3 || @_ < 1;

  my $url  = $_[0];
  my $text = ref $_[1] ? undef : $_[1];
  my $arg  = ref $_[1] ? $_[1] : ($_[2] // {});

  Slack::BlockKit::Block::RichText::Link->new({
    %$arg,
    (defined $text ? (text => $text) : ()),
    url => $url,
  });
}

# ($text) or ($text, {})
sub text ($text, $arg=undef) {
  $arg //= {};

  Slack::BlockKit::Block::RichText::Text->new({
    %$arg,
    text => $text,
  });
}

sub user {
  my ($arg, $id)
    = @_ == 2 ? @_
    : @_ == 1 ? ({}, $_[0])
    : Carp::croak("BlockKit user sugar called with wrong number of arguments");

  Slack::BlockKit::Block::RichText::User->new({
    %$arg,
    user_id => $id,
  });
}

sub usergroup {
  my ($arg, $id)
    = @_ == 2 ? @_
    : @_ == 1 ? ({}, $_[0])
    : Carp::croak("BlockKit usergroup sugar called with wrong number of arguments");

  Slack::BlockKit::Block::RichText::UserGroup->new({
    %$arg,
    user_group_id => $id,
  });
}

1;
