package Chart::GGPlot::HasDefaultAes;

# ABSTRACT: The role for the 'default_aes' attr

use Chart::GGPlot::Role;
use namespace::autoclean;

# VERSION

use Types::Standard qw(InstanceOf);

use Chart::GGPlot::Aes;

has default_aes => (
    is      => 'ro',
    isa     => InstanceOf["Chart::GGPlot::Aes"],
    default => sub { Chart::GGPlot::Aes->new() },
);

1;

__END__


