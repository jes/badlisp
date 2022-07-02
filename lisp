#!/usr/bin/perl

use strict;
use warnings;

my %VARIABLES = (
    '#t' => ['symbol', '#t'],
    '+' => ['builtin', sub { return ['number', shift()->[1]+shift()->[1]] }],
    '-' => ['builtin', sub { return ['number', shift()->[1]-shift()->[1]] }],
    '*' => ['builtin', sub { return ['number', shift()->[1]*shift()->[1]] }],
    '/' => ['builtin', sub { return ['number', shift()->[1]/shift()->[1]] }],
    'car' => ['builtin', sub { return shift()->[1] }],
    'cdr' => ['builtin', sub { return shift()->[2] }],
    'cons' => ['builtin', sub {
        my ($car, $cdr) = @_;
        return ['pair', $car, $cdr];
    }],
);
my @TOKENS;

my $FALSE = undef;
my $TRUE = $VARIABLES{'#t'};

print "user> ";
while (my $line = <>) {
    chomp $line;
    rep($line) if $line =~ /\S/;
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
    while ($str =~ s/^\s*([()]|[a-zA-Z0-9._\-+*\/#']+|;.*)\s*//) {
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
        if ($form->[1][0] eq 'symbol') {
            if ($form->[1][1] eq 'lambda') {
                my @formals;
                if (!defined $form->[2][1] || $form->[2][1][0] eq 'pair') {
                    # zero or many arguments
                    @formals = collect_formals($form->[2][1]);
                } elsif ($form->[2][1][0] eq 'symbol') {
                    # one argument
                    # TODO: this should pass the arguments as a list
                    @formals = ($form->[2][1][1]);
                }
                return ['procedure', \@formals, $form->[2][2][1]];
            } elsif ($form->[1][1] eq 'def') {
                my $name;
                if ($form->[2][1][0] eq 'symbol') {
                    $name = $form->[2][1][1];
                } else {
                    print STDERR "def should have a symbol\n";
                    return undef;
                }
                #print "declare $name = " . _print($form->[2][2][1]) . "\n";
                $VARIABLES{$name} = undef;
                $VARIABLES{$name} = _eval($form->[2][2][1]);
                return $VARIABLES{$name};
            } elsif ($form->[1][1] eq 'if') {
                my $cond = $form->[2][1];
                my $then = $form->[2][2][1];
                my $else = $form->[2][2][2][1];
                if (_eval($cond)) {
                    return _eval($then);
                } else {
                    return _eval($else);
                }
            }
        }

        my @operands;
        while ($form) {
            push @operands, _eval($form->[1]);
            $form = $form->[2];
        }
        # first operand is function, rest are args
        return call(@operands);
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

sub collect_formals {
    my ($list) = @_;
    if (!is_list($list)) {
        print STDERR "non-list of formals\n";
        return undef;
    }
    my @formals;
    while ($list) {
        if ($list->[1][0] ne 'symbol') {
            print STDERR "non-symbol formal\n";
            return undef;
        }
        push @formals, $list->[1][1];
        $list = $list->[2];
    }
    return @formals;
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
        #print "eval procedure with arguments: " . join(',',map { _print($_) } @operands) . "\n";
        # XXX: we shouldn't stick function parameters in global scope!
        if (@operands != @{ $operator->[1] }) {
            print STDERR "called procedure with wrong number of arguments\n";
            return undef;
        }
        for my $formal (@{ $operator->[1] }) {
            $VARIABLES{$formal} = shift @operands;
            #print " ... $formal = " . _print($VARIABLES{$formal}) . "\n";
        }
        #print "procedure = " . _print($operator->[2]) . "\n";
        return _eval($operator->[2]);
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
        if ($token eq '#f') {
            return $FALSE;
        }
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
    } elsif ($type eq 'builtin') {
        return "#<builtin>";
    } elsif ($type eq 'procedure') {
        return "#<procedure>";
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
