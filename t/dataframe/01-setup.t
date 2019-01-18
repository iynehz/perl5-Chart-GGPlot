#!perl

use strict;
use warnings;

use Test2::V0;

use Data::Frame::More::Setup;

pass("Data::Frame::More::Setup successfully loaded");

like(
    dies { Data::Frame::More::Setup->import(":doesnotexist"); },
    qr/^":doesnotexist" is not exported by the Data::Frame::More::Setup module/,
    "dies on a wrong import parameter"
);

done_testing;
