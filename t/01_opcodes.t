use strict;
use warnings;
use 5.010;
 
use Test::Simple tests => 1;
 
use CHIP8 qw(initialize _7ZZZ);

sub test_7ZZZ {
    CHIP8::initialize;
    my $op = 0x7;#7
    my $vx = 0xa;#10
    my $kk = 0x4f;#79
    
    my @rom_bytes = ($op, $vx, $kk);
    
    my $opcode = $op;
    $opcode = ($opcode << 4) | $vx;
    $opcode = ($opcode << 8) | $kk;
    #the opcode means adds the value of $kk to the registser $vx
    #and stores the result in $vx
    
    CHIP8::load_rom_from_array(@rom_bytes);
    
    return 0;
}

ok(test_7ZZZ);