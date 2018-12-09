#!perl

use Data::Frame::More::Setup;

use Test2::V0;

use Data::Frame::More::Types qw(:all);

isa_ok(DataFrame, ['Type::Tiny'], 'DataFrame type');

done_testing;
