use JSON::XS;

sub trim {
  @_ = $_ if not @_ and defined wantarray;
  @_ = @_ if defined wantarray;
  for (@_ ? @_ : $_) { s/^\s+//, s/\s+$// }
  return wantarray ? @_ : $_[0] if defined wantarray;
}

my $file = 'class-list.csv';
my $json = JSON::XS->new->ascii->pretty->allow_nonref;

# Fields: Subject, Section, Slots, Time, Days, Room, Unknown

my $data = {};
open( my $fh, '<', $file ) or die "Can't read file '$file' [$!]\n";

my $i = 0;
while ( my $line = <$fh> ) {
    #last if ( $i++ > 5 );
    chomp $line;
    my @fields = split( /,/, $line );

    for(my $z=0;$z<7;$z++){
      $fields[$z] = trim $fields[$z];
    }
    # Insert subject into hashmap
    $data{ subjects }{ $fields[0] }{ $fields[1] } =
      { slots => $fields[2]+0, time => $fields[3], days => trim $fields[4], room => trim $fields[5], pure => 1, units => 3, instructor => trim $fields[6] };

    # Check if lecture and set specifier
    my @section_split = split(/-/, $fields[1]);
    if(scalar(@section_split) > 1){
      if(defined($data{ subjects }{ $fields[0] }{ $section_split[0] })){
        $data{ subjects }{ $fields[0] }{ $fields[1] }{ lecture } = $section_split[0];
        $data{ subjects }{ $fields[0] }{ $section_split[0] }{ pure } = 0;
      } else {
        # print STDERR "$fields[0] $fields[1]\n"
      }
    }

    my %schedule = ( mon => [] ,tue => [] ,wed => [] ,thu => [] ,fri => [] ,sat => [] );
    if ($fields[3] =~ /(?<sh>[\d+])(?::(?<sm>[\d]+))?-(?<eh>[\d+])(?::(?<em>[\d]+))?/) {
        # Calculate start and end as hour offset from 7:00AM
        my $start = $+{sh} + 0;
        $start -= 7 if($+{sh} >= 7);
        $start += 5 if($+{sh} < 7);
        $start += $+{sm}/60.0 if(defined $+{sm});

        my $end = $+{eh} + 0;
        $end -= 7 if($+{eh} > 7);
        $end += 5 if($+{eh} <= 7);
        $end += $+{em}/60.0 if(defined $+{em});

        # Convert to 15-minute blocks
        my $startid = $start*4;
        my $endid = $end*4;

        my $days = $fields[4];
        if($days =~ s/M//g){ for(my $i=$startid;$i<$endid;$i+=1) {push @{ $schedule{mon} }, $i;} }
        # replace Th first to remove T's for Tuesdays
        if($days =~ s/Th//g){ for(my $i=$startid;$i<$endid;$i+=1) {push @{ $schedule{thu} }, $i;} }
        if($days =~ s/T//g){ for(my $i=$startid;$i<$endid;$i+=1) {push @{ $schedule{tue} }, $i;} }
        if($days =~ s/W//g){ for(my $i=$startid;$i<$endid;$i+=1) {push @{ $schedule{wed} }, $i;} }
        if($days =~ s/F//g){ for(my $i=$startid;$i<$endid;$i+=1) {push @{ $schedule{fri} }, $i;} }
        if($days =~ s/S//g){ for(my $i=$startid;$i<$endid;$i+=1) {push @{ $schedule{sat} }, $i;} }

        # Insert into final list
        $data{ subjects }{ $fields[0] }{ $fields[1] }{ hours } = [ $start, $end ];
        # $data{ subjects }{ $fields[0] }{ $fields[1] }{ schedule_code } = \%schedule;
        #print $json->encode(\%schedule);
    }
    $data{ subjects }{ $fields[0] }{ $fields[1] }{ schedule_code } =
        join('|',
            join(',', @{$schedule{mon}}),
            join(',', @{$schedule{tue}}),
            join(',', @{$schedule{wed}}),
            join(',', @{$schedule{thu}}),
            join(',', @{$schedule{fri}}),
            join(',', @{$schedule{sat}})
            );


      # push @data, \@fields;
}
print $json->encode( \%data );

# lecture sections are considered pure if they don't have dependent sections.
# pure sections are sections that users can enlist which includes normal
# sections and lecture sections that don't have dependers.
