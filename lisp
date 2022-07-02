#!/usr/bin/perl

use strict;
use warnings;

my %VARIABLES = (
    '+' => ['builtin', sub { return ['number', shift()->[1]+shift()->[1]] }],
    '-' => ['builtin', sub { return ['number', shift()->[1]-shift()->[1]] }],
    '*' => ['builtin', sub { return ['number', shift()->[1]*shift()->[1]] }],
    '/' => ['builtin', sub { return ['number', shift()->[1]/shift()->[1]] }],
);
my @TOKENS;

print "user> ";
while (my $line = <>) {
    chomp $line;
    rep($line);
    print "user> ";
}

sub rep {
    my ($l) = @_;
    print _print(_eval(_read($l))) . "\n";
}

# turn the given string into a form
sub _read {
    my ($str) = @_;
    my @tokens;
    while ($str =~ s/^\s*([()]|[a-zA-Z0-9._\-+#']+|;.*)\s*//) {
        push @tokens, $1 unless $1 =~ /^;/;
    }
    if ($str ne '') {
        print STDERR "garbage after end: $str\n";
        return undef;
    }
    @TOKENS = @tokens;
    return read_form();
}

# evaluate the given form
sub _eval {
    my ($form) = @_;
    #print "EVAL: " . _print($form) . "\n";
    return undef if !defined $form;
    my $type = $form->[0];
    #print " ---> $type\n";
    if ($type eq 'pair') {
        my $operator = _eval($form->[1]);
        my @operands;
        $form = $form->[2];
        while ($form) {
            push @operands, _eval($form->[1]);
            $form = $form->[2];
        }
        return call($operator, @operands);
    } elsif ($type eq 'symbol') {
        # symbol evaluates to the variable associated with the name
        my $name = $form->[1];
        if (exists $VARIABLES{$name}) {
            return $VARIABLES{$name};
        } else {
            print STDERR "unrecognised symbol: $name\n";
            return undef;
        }
    } elsif ($type eq 'number') {
        # number evaluates to itself
        return $form;
    }
}

# turn the given form into a string
sub _print {
    my ($form) = @_;
    return print_form($form);
}

sub call {
    my ($operator, @operands) = @_;
    my $type = $operator->[0];
    if ($type eq 'procedure') {
        print STDERR "calling procedures not implemented\n";
        return undef;
    } elsif ($type eq 'builtin') {
        my $fn = $operator->[1];
        return $fn->(@operands);
    } else {
        print STDERR "called non-callable: $type\n";
        return undef;
    }
}

sub tpeek {
    if (@TOKENS == 0) {
        print STDERR "tpeek: token stream underflow\n";
        return undef;
    }
    return $TOKENS[0];
}

sub tnext {
    if (@TOKENS == 0) {
        print STDERR "tnext: token stream underflow\n";
        return undef;
    }
    return shift @TOKENS;
}

sub read_form {
    if (tpeek() eq '(') {
        tnext();
        return read_list();
    } else {
        return read_atom();
    }
}

sub read_list {
    if (tpeek() eq ')') { # empty list?
        tnext();
        return undef;
    }

    my $list = ['pair', read_form(), undef];
    my $p = $list;

    while (defined tpeek() && tpeek() ne ')') {
        $p->[2] = ['pair', read_form(), undef];
        $p = $p->[2];
    }
    tnext();

    return $list;
}

sub read_atom {
    my $token = tnext();
    return undef if !defined $token;

    if ($token =~ /^\d/) { # number
        return ['number', int($token)];
    } else { # symbol
        return ['symbol', $token];
    }
}

sub print_form {
    my ($form) = @_;

    return '()' if !defined $form;
    my $type = $form->[0];
    if ($type eq 'number' || $type eq 'symbol') {
        return $form->[1];
    } elsif ($type eq 'pair') {
        if (is_list($form)) {
            return '(' . print_list($form) . ')';
        } else {
            return '(' . print_form($form->[1]) . ' . ' . print_form($form->[2]) . ')';
        }
    } else {
        print STDERR "unrecognised type: $type\n";
        return '()';
    }
}

sub is_list {
    my ($form) = @_;
    while (defined $form) {
        return 0 if $form->[0] ne 'pair';
        $form = $form->[2];
    }
    return 1;
}

sub print_list {
    my ($form) = @_;
    if (defined $form->[2]) {
        return print_form($form->[1]) . ' ' . print_list($form->[2]);
    } else {
        return print_form($form->[1]);
    }
}
