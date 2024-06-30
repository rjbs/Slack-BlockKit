package Slack::BlockKit::Sugar;
use v5.36.0;

use Carp ();
use Params::Util qw(_HASHLIKE);
use Slack::BlockKit;

use experimental 'builtin';

use Sub::Exporter -setup => {
  exports => [
    # top-level
    qw( blocks ),

    # Rich Text
    qw( richblock ),
    qw( richsection list preformatted quote ), # top-level
    qw( olist ulist ), # specialized list()
    qw( channel emoji link richtext user usergroup ), # deeper
    qw( bold code italic strike ), # specialized richtext()

    # Other Things
    qw( divider header mrkdwn text section )
  ],
};

my sub _rtextify (@things) {
  [
    map {;  ref($_)
        ? $_
        : Slack::BlockKit::Block::RichText::Text->new({ text => $_ })
        } @things
  ]
}

my sub _rsectionize (@things) {
  [
    map {;  ref($_)
        ? $_
        : Slack::BlockKit::Block::RichText::Section->new({
            elements => _rtextify($_),
          })
        } @things
  ];
}

# the top-level block collection
sub blocks (@blocks) {
  return Slack::BlockKit::BlockCollection->new({
    blocks => [ map {; ref($_) ? $_ : section(mrkdwn($_)) } @blocks ]
  });
}

# the rich text block itself

sub richblock (@elements) {
  Slack::BlockKit::Block::RichText->new({
    elements => _rsectionize(@elements),
  })
}

## things you can put in a `rich_text` block (in order of Slack docs)

sub richsection (@elements) {
  Slack::BlockKit::Block::RichText::Section->new({
    elements => _rtextify(@elements),
  });
}

sub list ($arg, @sections) {
  Slack::BlockKit::Block::RichText::List->new({
    %$arg,
    elements => _rsectionize(@sections),
  });
}

sub olist (@sections) {
  my $arg = _HASHLIKE($sections[0]) ? (shift @sections) : {};
  Slack::BlockKit::Block::RichText::List->new({
    %$arg,
    style => 'ordered',
    elements => _rsectionize(@sections),
  });
}

sub ulist (@sections) {
  my $arg = _HASHLIKE($sections[0]) ? (shift @sections) : {};
  Slack::BlockKit::Block::RichText::List->new({
    %$arg,
    style => 'bullet',
    elements => _rsectionize(@sections),
  });
}

# ({...}, @( elem | text )
sub preformatted (@elements) {
  my $arg = _HASHLIKE($elements[0]) ? (shift @elements) : {};

  Slack::BlockKit::Block::RichText::Preformatted->new({
    %$arg,
    elements => _rtextify(@elements),
  });
}

# ({...}, @( elem | text )
sub quote (@elements) {
  my $arg = _HASHLIKE($elements[0]) ? (shift @elements) : {};

  Slack::BlockKit::Block::RichText::Quote->new({
    %$arg,
    elements => _rtextify(@elements),
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

# ($text) or ([styles], $text)
sub richtext {
  my ($styles, $text)
    = @_ == 2   ? (@_)
    : @_ == 1   ? ([], $_[0])
    : @_ == 0   ? Carp::croak("BlockKit richtext sugar called too few arguments")
    : @_  > 2   ? Carp::croak("BlockKit richtext sugar called too many arguments")
    : Carp::confess("unreachable code");

  my $arg = {};
  $arg->{style}{$_} = 1 for $styles->@*;

  Slack::BlockKit::Block::RichText::Text->new({
    %$arg,
    text => $text,
  });
}

sub bold   ($text) { richtext(['bold'], $text) }
sub code   ($text) { richtext(['code'], $text) }
sub italic ($text) { richtext(['italic'], $text) }
sub strike ($text) { richtext(['strike'], $text) }

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

sub divider () {
  Slack::BlockKit::Block::Divider->new();
}

# This isn't great, it should have the $text,$arg format.
sub header ($arg) {
  if (builtin::blessed $arg) {
    # I am unfairly assuming this is a Text block, but I can tighten this up
    # later. -- rjbs, 2024-06-29
    Carp::croak("non-Text section passed as argument to BlockKit header sugar")
      unless $arg->isa('Slack::BlockKit::CompObj::Text');

    return Slack::BlockKit::Block::Header->new({ text => $arg })
  }

  if (ref $arg) {
    return Slack::BlockKit::Block::Header->new($arg);
  }

  return Slack::BlockKit::Block::Header->new({ text => text($arg) });
}

# It's weird, so you can't get much sugar here.  It must have either a single
# text block or a JSON Object of "fields".  The only thing I will venture here
# is to say that if $arg is a string, we generate a mrkdwn text section.
# If it's a Text object, that's the text.  Otherwise, just pass in args.
sub section ($arg) {
  if (builtin::blessed $arg) {
    # I am unfairly assuming this is a Text block, but I can tighten this up
    # later. -- rjbs, 2024-06-29
    Carp::croak("non-Text section passed as argument to BlockKit section sugar")
      unless $arg->isa('Slack::BlockKit::CompObj::Text');

    return Slack::BlockKit::Block::Section->new({ text => $arg })
  }

  if (ref $arg) {
    return Slack::BlockKit::Block::Section->new($arg);
  }

  return Slack::BlockKit::Block::Section->new({ text => mrkdwn($arg) });
}

sub mrkdwn ($text, $arg=undef) {
  $arg //= {};

  Slack::BlockKit::CompObj::Text->new({
    %$arg,
    type => 'mrkdwn',
    text => $text,
  });
}

sub text ($text, $arg=undef) {
  $arg //= {};

  Slack::BlockKit::CompObj::Text->new({
    %$arg,
    type => 'plain_text',
    text => $text,
  });
}

1;