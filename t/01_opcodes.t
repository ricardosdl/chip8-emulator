use strict;
use warnings;
use 5.010;
 
use Test::Simple tests => 4;
 
use CHIP8 qw(get_register_value initialize
    _6ZZZ
    _7ZZZ
    _8ZZ0
    _8ZZ1);
    
sub test_6ZZZ {
    CHIP8::initialize;
    #puts the value 0x2a(42) in the register V5
    my @rom_bytes = (0x65, 0x2a);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle();
    #V5 must be 0x2a
    return CHIP8::get_register_value(0x5) == 0x2a;
}

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

sub test_8ZZ0 {
    CHIP8::initialize;
    #puts the value 0x2a(42) in the reguster V1
    #and then Sets V0 to the value of V1
    my @rom_bytes = (0x61, 0x2a, 0x80, 0x10);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    
    return CHIP8::get_register_value(0x0) == 0x2a;
    
}

sub test_8ZZ1 {
    CHIP8::initialize;
    #finish here
}

ok(test_6ZZZ);
ok(test_7ZZZ);
ok(test_8ZZ0);