# Tests for Math::Project3D::Plot
# (c) 2002 Steffen Mueller, all rights reserved

use strict;
use warnings;

use Test::More tests => 4;

use Math::Project3D::Plot;

ok(1, 'Module compiled.'); # If we made it this far, we're ok.

my $img  = Imager->new(xsize => 100, ysize => 100);
my $proj = Math::Project3D->new(
   plane_basis_vector => [ 0, 0, 0 ],
   plane_direction1   => [ .4, 1, 0 ],
   plane_direction2   => [ .4, 0, 1 ],
);

$proj->new_function(
  't,u', '$t', '$u', '$t + $u',
);

my $color = Imager::Color->new(255, 0, 0);
my $background = Imager::Color->new(255,255,255);
$img->flood_fill(x=>0,y=>0,color=>$background);

ok(ref $img eq 'Imager', "Created Imager image and Math::Project3D object.");

my $plotter = Math::Project3D::Plot->new(
  image      => $img,
  projection => $proj,
  scale      => 2,
);

ok(ref $plotter eq 'Math::Project3D::Plot', "Created plotter object.");

foreach (0..10) {
   $plotter->plot(color => $color, params=> [$_,$_]);
   $plotter->plot(color => $color, params=> [0,$_]);
   $plotter->plot(color => $color, params=> [$_,0]);
}

ok(1, "plot did not croak.");

# $img->write(file=>'t.png') or
#         die $img->errstr;
