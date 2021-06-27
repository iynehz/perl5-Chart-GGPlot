# This file is generated by Dist::Zilla::Plugin::CPANFile v6.020
# Do not edit this file directly. To change prereqs, edit the `dist.ini` file.

requires "Alt::Data::Frame::ButMore" => "0.0056";
requires "Autoload::AUTOCAN" => "0";
requires "Carp" => "0";
requires "Chart::Plotly" => "0.041";
requires "Chart::Plotly::Image" => "0";
requires "Chart::Plotly::Plot" => "0";
requires "Chart::Plotly::Trace::Scatter::Textfont" => "0";
requires "Class::Method::Modifiers" => "0";
requires "Color::Brewer" => "0";
requires "Color::Library" => "0";
requires "Convert::Color::LCh" => "0";
requires "Convert::Color::RGB" => "0";
requires "Data::Dumper" => "0";
requires "Data::Dumper::Concise" => "0";
requires "Data::Frame::Autobox" => "0";
requires "Data::Frame::Types" => "0";
requires "Data::Frame::Util" => "0";
requires "Data::Munge" => "0";
requires "Eval::Quosure" => "0";
requires "Exporter::Tiny" => "0";
requires "Function::Parameters" => "2.001003";
requires "Hash::Util::FieldHash" => "0";
requires "Import::Into" => "0";
requires "JSON" => "0";
requires "JSON::XS" => "3.01";
requires "List::AllUtils" => "0";
requires "Log::Any" => "0";
requires "Log::Any::Adapter" => "0";
requires "Machine::Epsilon" => "0";
requires "Math::Gradient" => "0";
requires "Math::Interpolate" => "0";
requires "Math::Round" => "0";
requires "Math::SimpleHisto::XS" => "0";
requires "Math::Trig" => "0";
requires "Memoize" => "0";
requires "Module::Load" => "0.32";
requires "Moose" => "2.1400";
requires "Moose::Role" => "0";
requires "MooseX::Clone" => "0";
requires "MooseX::MungeHas" => "0.011";
requires "MooseX::Singleton" => "0";
requires "MooseX::StrictConstructor" => "0";
requires "Number::Format" => "1.75";
requires "PDL" => "2.019";
requires "PDL::Core" => "0";
requires "PDL::DateTime" => "0.004";
requires "PDL::Lite" => "0";
requires "PDL::Math" => "0";
requires "PDL::MatrixOps" => "0";
requires "PDL::Primitive" => "0";
requires "PDL::Ufunc" => "0";
requires "POSIX" => "0";
requires "Package::Stash" => "0";
requires "PerlX::Maybe" => "0";
requires "Ref::Util" => "0";
requires "Role::Tiny" => "0";
requires "Safe::Isa" => "1.000010";
requires "Scalar::Util" => "0";
requires "Storable" => "0";
requires "String::Util" => "0";
requires "Syntax::Keyword::Try" => "0";
requires "Time::Moment" => "0";
requires "Type::Library" => "0";
requires "Type::Params" => "0";
requires "Type::Utils" => "0";
requires "Types::PDL" => "0";
requires "Types::Standard" => "0";
requires "boolean" => "0";
requires "constant" => "0";
requires "feature" => "0";
requires "namespace::autoclean" => "0.20";
requires "overload" => "0";
requires "parent" => "0";
requires "perl" => "5.016";
requires "strict" => "0";
requires "utf8" => "0";
requires "warnings" => "0";
recommends "Math::LOESS" => "0";
recommends "PDL::GSL::CDF" => "0.75";
recommends "PDL::Stats::GLM" => "0.75";
recommends "Text::CSV_XS" => "0";

on 'test' => sub {
  requires "Data::Frame::Examples" => "0";
  requires "Test2::Tools::DataFrame" => "0";
  requires "Test2::Tools::PDL" => "0.0004";
  requires "Test2::V0" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Capture::Tiny" => "0";
  requires "Chart::Kaleido::Plotly" => "0";
  requires "FindBin" => "0";
  requires "Path::Tiny" => "0";
  requires "Test2::V0" => "0";
  requires "Test::Pod" => "1.41";
};
