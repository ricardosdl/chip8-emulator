use strict;
use warnings;
use 5.010;
 
use Test::Simple tests => 1;
 
use CHIP8 qw(get_register_value initialize _7ZZZ);

sub test_7ZZZ {
    my $op = 0x7;#7 - the op code
    my $vx = 0xa;#10 - the register
    my $kk = 0x4f;#79 - the value of the operation
    
    CHIP8::initialize;
    
    #adds 0x4f to Va and then adds 0xb to Va
    my @rom_bytes = (0x7a, 0x4f, 0x7a, 0xb);
    
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle();
    
    #Va must be 0x4f
    my $test1 = CHIP8::get_register_value($vx) == $kk;
    
    CHIP8::cycle();
    
    #Va must be 0x4f + 0xb
    my $test2 = CHIP8::get_register_value($vx) == ($kk + 0xb);
    
    return $test1 && $test2;
}

ok(test_7ZZZ);