package Chart::GGPlot::Theme;

# ABSTRACT: Class for themes

use Chart::GGPlot::Setup;
use Function::Parameters qw(classmethod);

# VERSION

use parent qw(Chart::GGPlot::Params);

use Autoload::AUTOCAN;
use List::AllUtils qw(reduce pairmap);
use Types::Standard qw(ArrayRef Bool HashRef InstanceOf Num Str);

use Chart::GGPlot::Global;
use Chart::GGPlot::Theme::ElementTree;
use Chart::GGPlot::Types qw(:all);

# AUTOLOAD for theme properties.
method AUTOCAN ($method) {
    if ( $self->exists($method) ) {
        return sub {
            my ($self) = @_;
            $self->at($method);
        };
    }
    return undef;
}

classmethod new ( @rest ) {
    my %params = @rest == 1 ? %{ $rest[0] } : @rest;
    return $class->_theme(%params);
}

classmethod _theme (:$complete = false, %elements ) {

    # Check that all elements have the correct class (element_text, unit, etc)
    %elements =
      map { $_ => $class->_validate_element( $elements{$_}, $_ ); }
      (sort keys %elements);

    # If complete theme set all non-blank elements to inherit from blanks
    if ($complete) {
        %elements = pairmap {
            my $el = $b;
            if ( $el->$_DOES('Chart::GGPlot::Theme::Element')
                and !$el->$_DOES('Chart::GGPlot::Theme::Element::Blank') )
            {
                $el->inherit_blank(true);
            }
            $a => $el;
        }
        %elements;
    }

    return bless(
        {
            _hash    => \%elements,
            complete => $complete,
        },
        $class
    );
}

fun _make_attr ($name) {
    return method(@rest) {
        if ( @rest > 0 ) {
            $self->{$name} = $rest[0];
        }
        return $self->{$name};
    };
}

*complete = _make_attr('complete');

# override Chart::GGPlot::Aes's transform_key().
method transform_key ($key) {
    return Chart::GGPlot::Theme::ElementTree->transform_key($key);
}

=method calc_element($theme)

Calculate the element properties, by inheriting properties from its parents.

=cut

method calc_element ($elname) {
    my $message = "$elname -->";

    # If this is element_blank, don't inherit anything from parents
    my $el = $self->at($elname);
    if ( $el->$_DOES('Chart::GGPlot::Theme::Element::Blank') ) {
        $log->debug( $message . 'element_blank (no inheritance)' );
        return $el;
    }

    # If the element is defined (and not just inherited), check that
    # it is of the class specified in .element_tree
    my $eldef = Chart::GGPlot::Global->element_tree->at($elname);

    my $eldef_type = $eldef->{type};
    if ( defined $el and not $eldef_type->check($el) ) {
        die( "Invalid element type for '$elname': "
              . $eldef_type->get_message() );
    }

    # Get the names of parents from the inheritance tree
    my $pnames = $eldef->{inherit};

    # If no parents, this is a "root" node. Just return this element.
    if ( !@$pnames ) {
        my $nullprops = $el->parameters->grep( sub { !defined $el->$_ } );
        if (@$nullprops) {
            die( sprintf "Theme element '%s' has undef property: %s",
                $elname, join( ", ", @$nullprops ) );
        }
        $log->debug( $message . 'nothing (top level)' );
        return $el;
    }

    # Calculate the parent objects' inheritance
    $log->debug( $message . join( ', ', @$pnames ) );
    my $parents = $pnames->map( sub { $self->calc_element($_) } );

    return reduce { $self->_combine_elements( $a, $b ) } $el, @$parents;
}

=method render_element(:$elname='', :$name=undef, %rest)

Return a grob for the element.

=cut

method render_element ($elname=undef, :$name=undef, %rest) {
    my $el = $self->calc_element($elname);
    unless ( defined $el ) {
        warn("Theme element $self missing");
        return zero_grob();
    }
    my $name = join( '.', $elname, ( $name // () ) );
    return $el->grob( %rest, name => $name );
}

# Check that an element object has the proper class
classmethod _validate_element ( $el, $elname ) {
    my $eldef = Chart::GGPlot::Global->element_tree->at($elname);
    unless ($eldef) {
        die("'$elname' is not a valid theme element name.");
    }

    # undef values for elements are OK
    return undef unless defined $el;

    my $eldef_type = $eldef->{type};
    eval {
        ($el) = Type::Params::validate([$el], $eldef_type);
    };
    if ($@) {
        unless ($el->$_DOES('Chart::GGPlot::Theme::Element::Blank')) {
            die( "Invalid element type for '$elname': $@" );
        }
    }
    return $el;
}

classmethod _combine_elements ($e1, $e2) {
    return $e1
      if ( !defined $e2
        or $e1->$_DOES("Chart::GGPlot::Theme::Element::Blank") );
    return $e2 unless defined $e1;
    if ( $e2->$_DOES("Chart::GGPlot::Theme::Element::Blank") ) {
        return ( $e1->inherit_blank ? $e2 : $e1 );
    }

    my $rslt = $e1->clone;
    for ( $e2->parameters->flatten ) {
        unless ( defined $e1->$_ ) {
            $rslt->$_( $e2->$_ );
        }
    }

    # Calculate relative sizes
    if ( $e1->size and $e1->size->$_DOES('Chart::GGPlot::Theme::Element::Rel') )
    {
        $rslt->size( $e2->size * $e1->size );
    }

    return $rslt;
}

=method add_theme($other)

Modify properties of an element in a theme object

=cut

method add_theme (Theme $other) {

    # Iterate over the elements that are to be updated
    for my $item ( $other->names ) {
        my $x = $self->at($item);
        my $y = $other->at($item);

        if ( !defined $x or $x->$_DOES('Chart::GGProt::Theme::Element::Blank') )
        {
            $x = $y;
        }
        elsif (!defined $y
            or $y->$_DOES('Chart::GGProt::Theme::Element::Blank')
            or ref($y) )
        {
            $x = $y;
        }
        else {
            $x = $x->merge($y);
        }

        # Assign it back to $self
        $self->set( $item, $x );
    }

    # If either theme is complete, then the combined theme is complete
    $self->complete( $self->complete or $other->complete );
    return $self;
}

method replace (Theme $other) {
    my $new = $self->clone;
    for my $elname ( $other->names->flatten ) {
        $new->set( $elname, $other->at($elname) );
    }
    $new->complete( $other->complete );
    return $new;
}

=method string()

=cut

method string () {
    return Dumper( $self->elements );
}

1;

__END__

=head1 DESCRIPTION

Themes are a powerful way to customize the non-data components of your
plots: i.e. titles, labels, fonts, background, gridlines, and legends.
Themes can be used to give plots a consistent customized look.

