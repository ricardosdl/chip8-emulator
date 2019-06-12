use strict;
use warnings;
use 5.010;
 
use Test::Simple tests => 9;
 
use CHIP8 qw(get_register_value initialize
    _6ZZZ
    _7ZZZ
    _8ZZ0
    _8ZZ1
    _8ZZ2
    _8ZZ3
    _8ZZ4);
    
sub test_6ZZZ {
    CHIP8::initialize;
    #puts the value 0x2a(42) in the register V5
    my @rom_bytes = (0x65, 0x2a);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle();
    #V5 must be 0x2a
    return CHIP8::get_register_value(0x5) == 0x2a;
}

sub test_1_7ZZZ {
    my $op = 0x7;#7 - the op code
    my $vx = 0xa;#10 - the register
    my $kk = 0x4f;#79 - the value of the operation
    
    CHIP8::initialize;
    CHIP8::logging(0);#disable logging for now
    
    #adds 0x4f to Va and then adds 0xb to Va
    my @rom_bytes = (0x7a, 0x4f, 0x7a, 0xb);
    
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle();
    
    #Va must be 0x4f
    return CHIP8::get_register_value($vx) == $kk;
}

sub test_2_7ZZZ {
    my $op = 0x7;#7 - the op code
    my $vx = 0xa;#10 - the register
    my $kk = 0x4f;#79 - the value of the operation
    
    CHIP8::initialize;
    CHIP8::logging(0);#disable logging for now
    
    #adds 0x4f to Va and then adds 0xb to Va
    my @rom_bytes = (0x7a, 0x4f, 0x7a, 0xb);
    
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle();
    
    CHIP8::logging(1);
    CHIP8::cycle();
    
    #Va must be 0x4f + 0xb
    return CHIP8::get_register_value($vx) == ($kk + 0xb);
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
    #puts the value 0x13(19) in V9, then puts the value
    #0x44(68) in the register VC and then sets V9 to V9 or VC
    my @rom_bytes = (0x69, 0x13, 0x6c, 0x44, 0x89, 0xc1);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::cycle;
    
    return CHIP8::get_register_value(0x9) == 87;
}

sub test_8ZZ2 {
    CHIP8::initialize;
    CHIP8::logging(0);#disable logging for now
    
    #puts the value 0x13(19) in V9, then puts the value
    #0x44(68) in the register VC and then sets V9 to V9 and VC
    my @rom_bytes = (0x69, 0x13, 0x6c, 0x44, 0x89, 0xc2);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);#disable logging for now
    CHIP8::cycle;
    return CHIP8::get_register_value(0x9) == 0;
    
}

sub test_8ZZ3 {
    CHIP8::initialize;
    CHIP8::logging(0);#disable logging for now
    
    #puts the value 0x13(19) in V9, then puts the value
    #0x44(68) in the register VC
    my @rom_bytes = (0x69, 0x13, 0x6c, 0x44, 0x89, 0xc3);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);#disable logging for now
    CHIP8::cycle;
    return CHIP8::get_register_value(0x9) == 87;
    
}

sub test_nocarry_8ZZ4 {
    CHIP8::initialize(0);
    
    #puts the value 0x2a in Va, then puts the value 0x27 in Ve,
    #and then Va = Va + Ve, the carry (if any) is set in Vf
    my @rom_bytes = (0x6a, 0x2a, 0x6e, 0x27, 0x8a, 0xe4);
    
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return (CHIP8::get_register_value(0xa) == 0x51) &&
        (CHIP8::get_register_value(0xf) == 0);
}

sub test_withcarry_8ZZ4 {
    CHIP8::initialize(0);
    #puts the value 0xc1 in Vb, then puts the value 0x45 in Vd,
    #and then Vb = Vb + Vd, the carry (if any) is set in Vf
    my @rom_bytes = (0x6b, 0xc1, 0x6d, 0x45, 0x8b, 0xd4);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return (CHIP8::get_register_value(0xb) == 0x6) &&
        (CHIP8::get_register_value(0xf) == 1);
}

ok(test_6ZZZ);
ok(test_1_7ZZZ);
ok(test_2_7ZZZ);
ok(test_8ZZ0);
ok(test_8ZZ1);
ok(test_8ZZ2);
ok(test_8ZZ3);
ok(test_nocarry_8ZZ4);
ok(test_withcarry_8ZZ4);
