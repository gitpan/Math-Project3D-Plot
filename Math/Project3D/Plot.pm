
# See the POD documentation at the end of this
# document for detailed copyright information.
# (c) 2002 Steffen Mueller, all rights reserved.

package Math::Project3D::Plot;

use 5.006;
use strict;
use warnings;

use Carp;

use Math::Project3D;
use Imager;

use vars qw/$VERSION/;
$VERSION = 1.001;


# Constructor class and object method new
# 
# Creates a new Math::Project3D::Plot instance and returns it.
# Takes a list of object attributes as arguments.

sub new {
   my $proto = shift;
   my $class = ref $proto || $proto;

   my %args = @_;

   # check for require attributes
   my $missing = _require_attributes(\%args, 'image', 'projection');

   croak "Required attribute $missing missing."
     if $missing;
   
   # We might croak a lot.
   my $croaker = sub { croak "Attribute '$_[0]' is bad." };

   my $self = {};

   # valid image and projection?
   ref $args{image} or $croaker->('image');
   $self->{image} = $args{image};

   ref $args{projection} eq 'Math::Project3D' or $croaker->('projection');
   $self->{proj} = $args{projection};

   # defaults
   $self = {
     %$self,
     scale    => 10,
     origin_x => $self->{image}->getwidth() / 2,
     origin_y => $self->{image}->getheight() / 2,
   };

   my @valid_args = qw(
     origin_x origin_y
     scale
   );

   # Take all valid args from the user input and
   # put them into our object.
   foreach my $arg (@valid_args) {
      $self->{$arg} = $args{$arg} if exists $args{$arg};
   }

   bless $self => $class;

   # get min/max logical x/y coordinates
   ( $self->{min_x}, $self->{min_y} ) = $self->_g_l(0, 0);
   ( $self->{max_x}, $self->{max_y} ) = $self->_g_l(
                                          $self->{image}->getwidth(),
                                          $self->{image}->getheight(),
                                        );

   return $self;
}


# Method plot
# Takes argument pairs: color => Imager color
# and params => array ref of params
# projects the point associated with the parameters.
# Plots the point.
# Returns the graphical coordinates of the point that
# was plotted.

sub plot {
   my $self   = shift;
   my %args   = @_;

   ref $args{params} eq 'ARRAY' or
     croak "Invalid parameters passed to plot().";

   my ($coeff1, $coeff2, $distance) = $self->{proj}->project(@{$args{params}});
   my ($g_x, $g_y) = $self->_l_g($coeff1, $coeff2);

   $self->{image}->setpixel(color=>$args{color}, x=>$g_x, y=>$g_y);

   return $g_x, $g_y;
}


# Private method _require_attributes
# 
# Arguments must be a list of attribute names (strings).
# Tests for the existance of those attributes.
# Returns the missing attribute on failure, undef on success.

sub _require_attributes {
   my $self = shift;
   exists $self->{$_} or return $_ foreach @_;
   return undef;
}


# Private method _l_g (logical to graphical)
# Takes an x/y pair of logical coordinates as
# argument and returns the corresponding graphical
# coordinates.

sub _l_g {
   my $self = shift;
   my $x    = shift;
   my $y    = shift;

   # A logical unit is a graphical one displaced by the origin
   # and multiplied with the appropriate scaling factor.

   $x = $self->{origin_x} + $x * $self->{scale};

   $y = $self->{origin_y} - $y * $self->{scale};

   return $x, $y;
}


# Private method _g_l (graphical to logical)
# Takes an x/y pair of graphical coordinates as
# argument and returns the corresponding
# logical coordinates.

sub _g_l {
   my $self = shift;
   my $x = shift;
   my $y = shift;

   # A graphical unit is a logical one displaced by the origin
   # and divided by the appropriate scaling factor.

   $x = ( $x - $self->{origin_x} ) / $self->{scale};

   $y = ( $y - $self->{origin_y} ) / $self->{scale};

   return $x, $y;
}



1;

__END__

=pod

=head1 NAME

Math::Project3D::Plot - Perl extension for plotting projections of 3D functions

=head1 VERSION

Current version is 1.001. Alpha software distributed for testing purposes.

=head1 SYNOPSIS

  use Math::Project3D::Plot;

  # Create new image or open an existing one
  my $img = Imager->new(...);

  # Create new projection
  my $projection = Math::Project3D->new(
    # see Math::Project3D manpage!
  );

  my $plotter = Math::Project3D::Plot->new(
    image      => $img,
    projection => $projection,

    # 1 logical unit => 10 pixels
    scale      => 10

    # x/y coordinates of the origin in pixels
    origin_x   => $img->getwidth()  / 2,
    origin_y   => $img->getheight() / 2,
  );

  $plotter->plot(
    params   => [@parameters],
    color    => $color, # see Imager manpage about colors
  );

  $plotter->plot_list(
    params => [
                [@parameter_set1],
                [@parameter_set2],
                # ...
              ],
    color  => $color, # see Imager manpage about colors
    type   => 'line', # connect points with lines
  );

  $plotter->plot_range(
    params => [
                [$lower_boundary1, $upper_boundary1, $increment1],
                [$lower_boundary2, $upper_boundary2, $increment2],
                # ...
              ],
    color  => $color,   # see Imager manpage about colors
    type   => 'points', # draw the points only 
  );

  # Use Imager methods on $img to save the image to a file

=head1 DESCRIPTION

No description yet. This is alpha software. Read the source.

=head1 AUTHOR

Steffen Mueller, E<lt>project3d-module at steffen-mueller dot net<gt>

=head1 COPYRIGHT

Copyright (c) 2002 Steffen Mueller. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Math::Project3D>
L<Math::Project3D::Function>
L<Math::MatrixReal>

=cut
