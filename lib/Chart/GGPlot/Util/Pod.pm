package Chart::GGPlot::Util::Pod;

# ABSTRACT: Dev utilities for pod-related tasks of Chart::GGPlot

use Chart::GGPlot::Setup;

# VERSION

use parent qw(Exporter::Tiny);

our @EXPORT_OK = qw(layer_func_pod);

my $TMPL_COMMON_ARGS = <<'=cut';

=item * $mapping

Set of aesthetic mappings created by C<aes()>. If specified and
C<$inherit_aes> is true (the default), it is combined with the default
mapping at the top level of the plot.
You must supply mapping if there is no plot mapping.

=item * $data

The data to be displayed in this layer.
If C<undef>, the default, the data is inherited from the plot data as
specified in the call to C<ggplot()>.

=item * $stat

The statistical transformation to use on the data for this layer, as a
string.

=item * $position

Position adjustment, either as a string, or the result of a call to a
position adjustment function.

=item * $na_rm

If false, the default, missing values are removed with a warning.
If true, missing values are silently removed.

=item * $show_legend

Should this layer be included in the legends?
'auto', the default, includes if any aesthetics are mapped.
false never includes, and false always includes.

=item * $inherit_aes

If false, overrides the default aesthetics, rather than combining with them.
This is most useful for helper functions that define both data and
aesthetics and shouldn't inherit behaviour from the default plot
specification.

=item * %rest

Other arguments passed to C<Chart::GGPlot::Layer-E<gt>new()>.
These are often aesthetics, used to set an aesthetic to a fixed value,
like C<color =E<gt> "red", size =E<gt> 3>.
They may also be parameters to the paired geom/stat.

=cut

my %templates = (
    # common args used by the geom_* and stat_* functions
    TMPL_COMMON_ARGS => $TMPL_COMMON_ARGS,
);

sub x_pod {
    my ($tmpl_names) = @_;

    return sub {
        my ($text) = @_;
        for my $tmpl_name (@$tmpl_names) {
            my $tmpl_text = $templates{$tmpl_name};
            die "Invalid template name $tmpl_name" unless defined $tmpl_text;

            no strict 'refs';
            $text =~ s/\%$tmpl_name\%/$tmpl_text/g;
        }
        return $text;
    };
}

*layer_func_pod = x_pod([qw(TMPL_COMMON_ARGS)]);

1;

__END__

=head1 DESCRIPTION

This module is for Chart::GGPlot library developers only. 

