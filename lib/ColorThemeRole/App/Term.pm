package Color::Theme::Role::ANSI;

# DATE
# VERSION

use 5.010001;
use Moo::Role;

use Color::ANSI::Util ();
with 'Color::Theme::Role';
with 'Term::App::Role::Attrs';

sub theme_color_to_ansi {
    my ($self, $c, $args, $is_bg) = @_;

    # empty? skip
    return '' if !defined($c) || !length($c);

    # resolve coderef color
    if (ref($c) eq 'CODE') {
        $args //= {};
        $c = $c->($self, %$args);
    }

    my $coldepth = $self->color_depth;

    if ($coldepth >= 2**24) {
        if (ref $c) {
            my $ansifg = $c->{ansi_fg};
            $ansifg //= Color::ANSI::Util::ansi24bfg($c->{fg})
                if defined $c->{fg};
            $ansifg //= "";
            my $ansibg = $c->{ansi_bg};
            $ansibg //= Color::ANSI::Util::ansi24bbg($c->{bg})
                if defined $c->{bg};
            $ansibg //= "";
            $c = $ansifg . $ansibg;
        } else {
            $c = $is_bg ? Color::ANSI::Util::ansi24bbg($c) :
                Color::ANSI::Util::ansi24bfg($c);
        }
    } elsif ($coldepth >= 256) {
        if (ref $c) {
            my $ansifg = $c->{ansi_fg};
            $ansifg //= Color::ANSI::Util::ansi256fg($c->{fg})
                if defined $c->{fg};
            $ansifg //= "";
            my $ansibg = $c->{ansi_bg};
            $ansibg //= Color::ANSI::Util::ansi256bg($c->{bg})
                if defined $c->{bg};
            $ansibg //= "";
            $c = $ansifg . $ansibg;
        } else {
            $c = $is_bg ? Color::ANSI::Util::ansi256bg($c) :
                Color::ANSI::Util::ansi256fg($c);
        }
    } else {
        if (ref $c) {
            my $ansifg = $c->{ansi_fg};
            $ansifg //= Color::ANSI::Util::ansi16fg($c->{fg})
                if defined $c->{fg};
            $ansifg //= "";
            my $ansibg = $c->{ansi_bg};
            $ansibg //= Color::ANSI::Util::ansi16bg($c->{bg})
                if defined $c->{bg};
            $ansibg //= "";
            $c = $ansifg . $ansibg;
        } else {
            $c = $is_bg ? Color::ANSI::Util::ansi16bg($c) :
                Color::ANSI::Util::ansi16fg($c);
        }
    }
    $c;
}

sub get_theme_color_as_ansi {
    my ($self, $item_name, $args) = @_;
    $self->theme_color_to_ansi(
        $self->get_theme_color($item_name),
        {name=>$item_name, %{ $args // {} }},
        $item_name =~ /_bg$/,
    );
}

1;
# ABSTRACT: Role for class wanting to support color themes (ANSI support)

=head1 DESCRIPTION

This role consumes L<Color::Theme::Role> and L<Term::App::Role::Attrs>.


=head1 METHODS


=head2 $cl->theme_color_to_ansi($color) => str

=head2 $cl->get_theme_color_as_ansi($item_name, \%args) => str

Like C<get_theme_color>, but if the resulting color value is a coderef, will
call that coderef, passing C<%args> to it and returning the value. Also, will
convert color theme to ANSI color escape codes.

When converting to ANSI code, will consult C<color_depth> from
L<Term::App::Role::Attr>.


=head2 SEE ALSO

L<Color::Theme::Util::ANSI>

L<Color::Theme>
