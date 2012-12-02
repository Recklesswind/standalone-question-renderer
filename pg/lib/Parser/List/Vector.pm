#########################################################################
#
#  Implements the Vector class
#
package Parser::List::Vector;
use strict;
our @ISA = qw(Parser::List);

#
#  The basic List class does nearly everything.
#

#
#  Check that the coordinates are numbers (avoid <i+j+k>)
#
sub _check {
  my $self = shift; return if $self->context->flag("allowBadOperands");
  foreach my $x (@{$self->{coords}}) {
    unless ($x->isNumber) {
      my $type = $x->type;
      $type = (($type =~ m/^[aeiou]/i)? "an ": "a ") . $type;
      $self->{equation}->Error(["Coordinates of Vectors must be Numbers, not %s",$type]);
    }
  }
}

my $ijk_string = ['i','j','k','0'];
my $ijk_TeX = ['\boldsymbol{i}','\boldsymbol{j}','\boldsymbol{k}','\boldsymbol(0)'];

sub ijk {
  my $self = shift;
  my $method = shift || 'TeX'; my $ijk = shift || $ijk_TeX;
  my @coords = @{$self->{coords}};
  $self->Error("Method 'ijk' can only be used on vectors in three-space")
    unless (scalar(@coords) <= 3);
  my $prec = $self->{equation}{context}->operators->get('*')->{precedence};
  my $string = ''; my $n; my $term;
  foreach $n (0..scalar(@coords)-1) {
    $term = $coords[$n]->$method($prec);
    if ($term ne '0') {
      $term = '' if $term eq '1'; $term = '-' if $term eq '-1';
      $term = '+' . $term unless $string eq '' or $term =~ m/^-/;
      $string .= $term . $ijk->[$n];
    }
  }
  $string = $ijk->[3] if $string eq '';
  return $string;
}

sub TeX {
  my $self = shift;
  if ($self->{ijk} || $self->{equation}{ijk} || $self->{equation}{context}->flag("ijk")) 
    {return $self->ijk}
  return $self->SUPER::TeX;
}

sub string {
  my $self = shift;
  if ($self->{ijk} || $self->{equation}{ijk} || $self->{equation}{context}->flag("ijk")) 
    {return $self->ijk('string',$ijk_string)}
  return $self->SUPER::string;
}

#########################################################################

1;
