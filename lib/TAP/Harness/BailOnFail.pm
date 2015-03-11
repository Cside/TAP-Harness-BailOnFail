package TAP::Harness::BailOnFail;
use 5.008001;
use strict;
use warnings;
use parent qw(TAP::Harness);

our $VERSION = "0.01";

sub _aggregate_single {
    my ( $self, $aggregate, $scheduler ) = @_;

    JOB:
    while ( my $job = $scheduler->get_job ) {
        next JOB if $job->is_spinner;

        my ( $parser, $session ) = $self->make_parser($job);

        while ( defined( my $result = $parser->next ) ) {
            $session->result($result);
            unless ($result->is_ok) {
                1 while $scheduler->get_job;
                1 while $parser->next;
            }
            if ( $result->is_bailout ) {
                1 while $parser->next;
                $self->_bailout($result);
            }
        }

        $self->finish_parser( $parser, $session );
        $self->_after_test( $aggregate, $job, $parser );
        $job->finish;
    }

    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

TAP::Harness::BailOnFail - Aborts tests automatically if any test failed

=head1 SYNOPSIS

    prove --harness TAP::Harness::BailOnFail t/

=head1 LICENSE

Copyright (C) Hiroki Honda.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Hiroki Honda E<lt>cside.story@gmail.comE<gt>

=cut

