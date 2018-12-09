package Chart::GGPlot::Position;

# ABSTRACT: The position role

use Chart::GGPlot::Role;

# VERSION

use PDL::Primitive qw(which);
use Types::Standard qw(CodeRef);
use namespace::autoclean;

with qw(Chart::GGPlot::HasRequiredAes);

method setup_params($data) { return {}; }

method setup_data ($data, $params) {
    $self->check_required_aes($data->names);
    return $data;
}

method compute_layer ($data, $params, $layout) {
    my $panel_data = $data->at('PANEL'); 
    my $splitted = $data->split($panel_data);

    my $new_df = Data::Frame::More->new();
    for my $panel (keys %$splitted) {
        my $func = fun($df) {
            return $df if ($df->isempty);
            my $scales = $layout->get->scales($panel);
            return $self->compute_panel($df, $params, $scales);
        };
        $new_df = $new_df->append($func->($splitted->{$panel}));
    }
}

method compute_panel($data, $params, $scales) { ... }


1;

__END__

=head1 DESCRIPTION

The positon object is for adjusting the position of overlapping
geoms.
