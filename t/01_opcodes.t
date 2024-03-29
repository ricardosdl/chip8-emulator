use strict;
use warnings;
use 5.010;
 
use Test::Simple tests => 38;
 
use CHIP8 qw(get_register_value initialize get_pc_value get_display_buffer_at);
    
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

sub test_3_7ZZZ {
    CHIP8::initialize(0);
    
    #add 0x45 to V5 and then adds 0xc0 to V5
    my @rom_bytes = (0x75, 0x45, 0x75, 0xc0);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle();
    CHIP8::cycle();
    
    #V5 must be 5, because the registers are 8-bits and only the lower
    #8 bits are kept
    return CHIP8::get_register_value(0x5) == 5;
    
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

sub test_1_8ZZ5 {
    CHIP8::initialize(0);
    
    #puts the value 0xd in V8, then puts the value 0xb in V7,
    #and then V8 = V8 - V7
    my @rom_bytes = (0x68, 0xd, 0x67, 0xb, 0x88, 0x75);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return (CHIP8::get_register_value(0x8) == 2) && (CHIP8::get_register_value(0xf) == 1);
}

sub test_2_8ZZ5 {
    CHIP8::initialize(0);
    
    #puts the value 0xf2 in V8, then puts the value 0xff in V7,
    #and then V8 = V8 - V7
    my @rom_bytes = (0x68, 0xf2, 0x67, 0xff, 0x88, 0x75);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return (CHIP8::get_register_value(0x8) == 243) && (CHIP8::get_register_value(0xf) == 0);
}

sub test_1_8ZZ6 {
    CHIP8::initialize(0);
    
    #puts the value 0xf2 in V3, and then V3 = V3 >> 1
    my @rom_bytes = (0x63, 0xf2, 0x83, 0x6);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    return (CHIP8::get_register_value(0x3) == 121) &&
        (CHIP8::get_register_value(0xf) == 0);
}

sub test_2_8ZZ6 {
    CHIP8::initialize(0);
    
    #puts the value 0xf3 in V3, and then V3 = V3 >> 1
    my @rom_bytes = (0x63, 0xf3, 0x83, 0x6);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    return (CHIP8::get_register_value(0x3) == 121) &&
        (CHIP8::get_register_value(0xf) == 1);
}

sub test_1_8ZZ7 {
    CHIP8::initialize(0);
    
    #puts the value 0x67 in V4, then puts the value 0x78
    #in V6, then V4 = V6 - V4
    my @rom_bytes = (0x64, 0x67, 0x66, 0x78, 0x84, 0x67);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return (CHIP8::get_register_value(0x4) == 0x11) &&
        (CHIP8::get_register_value(0xf) == 1);
    
    
    return 0;
}

sub test_2_8ZZ7 {
    CHIP8::initialize(0);
    
    #puts the value 0x78 in V4, then puts the value 0x69
    #in V6, then V4 = V6 - V4
    my @rom_bytes = (0x64, 0x78, 0x66, 0x69, 0x84, 0x67);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return (CHIP8::get_register_value(0x4) == 241) &&
        (CHIP8::get_register_value(0xf) == 0);
    
    
    return 0;
}

sub test_1_8ZZE {
    CHIP8::initialize(0);
    
    #puts the value 0x43 in V7, then V7 = V7 SHL 1.
    my @rom_bytes = (0x67, 0x43, 0x87, 0xe);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return (CHIP8::get_register_value(0x7) == 134) &&
        (CHIP8::get_register_value(0xf) == 0);
    
}

sub test_2_8ZZE {
    CHIP8::initialize(0);
    
    #puts the value 0xC7 in V7, then V7 = V7 SHL 1.
    my @rom_bytes = (0x67, 0xc7, 0x87, 0xe);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return (CHIP8::get_register_value(0x7) == 142) &&
        (CHIP8::get_register_value(0xf) == 1);
    
}

sub test_1_9ZZZ {
    CHIP8::initialize(0);
    
    #puts the value 0x13 in V3, then puts the value 0x13 in VD then
    #skips the next instruction if V3 != VD
    my @rom_bytes = (0x63, 0x13, 0x6d, 0x13, 0x93, 0xd0);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    my $old_pc_value = CHIP8::get_pc_value();
    CHIP8::cycle;
    
    return CHIP8::get_pc_value() == ($old_pc_value + 2);  
}

sub test_2_9ZZZ {
    CHIP8::initialize(0);
    
    #puts the value 0x13 in V3, then puts the value 0x66 in VD then
    #skips the next instruction if V3 != VD
    my @rom_bytes = (0x63, 0x13, 0x6d, 0x66, 0x93, 0xd0);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    my $old_pc_value = CHIP8::get_pc_value();
    CHIP8::cycle;
    
    return CHIP8::get_pc_value() == ($old_pc_value + 4);  
}

sub test_AZZZ {
    CHIP8::initialize(1);
    
    #sets I (index) to the value 0x518
    my @rom_bytes = (0xa5, 0x18);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    return CHIP8::get_index_value() == 0x518;
}

sub test_BZZZ {
    CHIP8::initialize(0);
    
    #puts the value 0x40 in V0, then jumps to the address 0x628 + V0
    my @rom_bytes = (0x60, 0x40, 0xB6, 0x28);
    CHIP8::load_rom_from_array(@rom_bytes);
    
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return CHIP8::get_pc_value() == 1640;
}

sub test_CZZZ {
    CHIP8::initialize(1);
    
    #sets V5 to random byte and 0x67
    my @rom_bytes = (0xc5, 0x67);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    
    return (CHIP8::get_register_value(0x5) & 0x67) == CHIP8::get_register_value(0x5);
    
}

sub test_1_DZZZ {
    #tests drawing a sprite in the screen with no collision
    CHIP8::initialize(0);
    
    #sets V1(vx) to 0x1c and V2(vy) to 0xd then
    #load the adress of the font 0x2 into the index register then
    #draws the sprite 0x2 in the middle of the screen
    my @rom_bytes = (0x61, 0x1c, 0x62, 0xd, 0xa0, 0xa, 0xd1, 0x25);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    #the display buffer is a linear array of 64 * 32 pixels
    return CHIP8::get_display_buffer_at(0x1c, 0xd) == 1 &&
        CHIP8::get_register_value(0xf) == 0;
}

sub test_2_DZZZ {
    #checks if the collision register is set
    CHIP8::initialize(0);
    
    #sets V1(vx) to 0x1c and V2(vy) to 0xd then
    #load the adress of the font 0x2 into the index register then
    #draws the sprite 0x2 in the middle of the screen
    my @rom_bytes = (0x61, 0x1c, 0x62, 0xd, 0xa0, 0xa, 0xd1, 0x25);
    
    #sets V1(vx) 0x19 and V2(vy) to 0xd then
    #load the address of the font 0x0 into the index register then
    #draws the sprite 0x0 a little to the left of the middle of the screen
    my @more_rom_bytes = (0x61, 0x19, 0x62, 0xd, 0xa0, 0x0, 0xd1, 0x25);
    
    push @rom_bytes, @more_rom_bytes;
    
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::cycle;
    
    #the display buffer is a linear array of 64 * 32 pixels
    return CHIP8::get_register_value(0xf) == 1;
}

sub test_3_DZZZ {
    #tests drawing a sprite in the screen with horizontal wrap
    CHIP8::initialize(0);
    
    #sets V1(vx) to 0x3d and V2(vy) to 0xd then
    #load the adress of the font 0x3 into the index register then
    #draws the sprite 0x3 far right end of the screen
    my @rom_bytes = (0x61, 0x3d, 0x62, 0xd, 0xa0, 0xf, 0xd1, 0x25);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    #the right side of the 0x3 sprite went to the start of the screen?
    return CHIP8::get_display_buffer_at(0x0, 0xd) == 1;
}

sub test_4_DZZZ {
    #tests the drawing with vertical wrap
    
    CHIP8::initialize(0);
    #sets V1(vx) to 0x1c and V2(vy) to 0x3e then
    #load the adress of the font 0xC (0x3c) into the index register then
    #draws the sprite 0xC near the screen bottom
    my @rom_bytes = (0x61, 0x1c, 0x62, 0x3e, 0xa0, 0x3c, 0xd1, 0x25);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return CHIP8::get_display_buffer_at(0x1c, 0x0) == 1;
}

sub test_EZZE {
    #tests if the next instruction will be skipped if key is pressed
    CHIP8::initialize(0);
    
    #stores 0xa in V6(vx) then
    #skip next instruction if key with the value of Vx is pressed.
    my @rom_bytes = (0x66, 0xa, 0xe6, 0x9e);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::set_key_input(0xa);
    CHIP8::cycle;
    CHIP8::logging(1);
    my $last_pc = CHIP8::get_pc_value();
    CHIP8::cycle;
    
    return CHIP8::get_pc_value() == ($last_pc + 4);
}

sub test_EZZ1 {
    #tests if the next instruction will be skipped if key isn't pressed
    CHIP8::initialize(0);
    
    #stores 0xa in V6(vx) then
    #skip next instruction if key with the value of Vx isn't pressed.
    my @rom_bytes = (0x66, 0xa, 0xe6, 0xa1);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::logging(1);
    my $last_pc = CHIP8::get_pc_value();
    CHIP8::cycle;
    
    return CHIP8::get_pc_value() == ($last_pc + 4);
}

sub test_FZ07 {
    #tests if Vx is set to the value of the delay timer
    CHIP8::initialize(1);
    
    #Set Vx(x=9) to delay timer value.
    my @rom_bytes = (0xf9, 0x7);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::set_delay_timer(0xf9);
    CHIP8::cycle;
    
    return CHIP8::get_register_value(0x9) == 0xf9;
}

sub test_FZ15 {
    #tests if the delay timer value was copied to Vx
    CHIP8::initialize();
    
    #stores the value 0x8f in V8 and then
    #copy the value of Vx (x=8) to the delay timer
    my @rom_bytes = (0x68, 0x8f, 0xf8, 0x15);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    #the cycle will always decrement the delay timer by one
    return (CHIP8::get_delay_timer() + 1) == 0x8f;
}

sub test_FZ18 {
    #tests if the sound timer was set to Vx
    
    CHIP8::initialize();
    
    #stores the value 0x65 in Vd and then
    #stores the value of Vd in the sound timer
    my @rom_bytes = (0x6d, 0x65, 0xfd, 0x18);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return (CHIP8::get_sound_timer() + 1) == 0x65;
}

sub test_1_FZ1E {
    #tests adding Vx to the index register
    CHIP8::initialize;
    
    #sets the value of Vx(x=3) to 0x56 and then
    #stores the value 0xf09 in I
    #set the value of index(I) to I  = I + Vx
    my @rom_bytes = (0x63, 0x56, 0xaf, 0x9, 0xf3, 0x1e);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return (CHIP8::get_index_value() == (0xf09 + 0x56)) &&
        (CHIP8::get_register_value(0xf) == 0);
}

sub test_2_FZ1E {
    #tests adding Vx to the index register with overflow
    CHIP8::initialize(0);
    
    #sets the value of Vx(x=3) to 0x56 and then
    #stores the value 0xfb9 in I
    #set the value of index(I) to I  = I + Vx
    my @rom_bytes = (0x63, 0x56, 0xaf, 0xb9, 0xf3, 0x1e);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return (CHIP8::get_index_value() == 0xf) &&
        (CHIP8::get_register_value(0xf) == 1);
}

sub test_FZ29 {
    #tests if the index is pointing to the character indicated by Vx
    CHIP8::initialize(0);
    #stores the value 0xc in Vx (x=4) and then
    #Set I = location of sprite for digit Vx.
    my @rom_bytes = (0x64, 0xc, 0xf4, 0x29);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::logging(1);
    CHIP8::cycle;
    
    return CHIP8::get_index_value() == 60;
}

sub test_FZ33 {
    #tests if the number 666 (stored in Vx) will be stores in BCD (binary codede decimal)
    CHIP8::initialize(0);
    
    #stores the value 166(0xa6) in Vx (x=3) and then
    #sets I to the memory location 0xf9b and then
    #stores the BCD of Vx in I, I + 1 and I + 2
    my @rom_bytes = (0x63, 0xa6, 0xaf, 0x9b, 0xf3, 0x33);
    CHIP8::load_rom_from_array(@rom_bytes);
    CHIP8::cycle;
    CHIP8::cycle;
    
    CHIP8::logging(1);
    CHIP8::cycle;
    
    my $hundreds = CHIP8::get_memory_at(CHIP8::get_index_value());
    my $tenths = CHIP8::get_memory_at(CHIP8::get_index_value() + 1);
    my $units = CHIP8::get_memory_at(CHIP8::get_index_value() + 2);
    
    return ($hundreds == 1) && ($tenths == 6) && ($units == 6);
}

sub test_FZ55 {
    #tests if the registers from V0 to Vx will be copied to the locations
    #I through I + Vx
    CHIP8::initialize(0);
    
    #stores the values 42, 22 and 12 at V0, V1 and V2
    #sets I to the memory location 0xf9b and then
    #stores the registsers V0 through V2 starting at I
    my @rom_bytes = (0x60, 0x2a, 0x61, 0x16, 0x62, 0xc,
        0xaf, 0x9b, 0xf2, 0x55
    );
    CHIP8::load_rom_from_array(@rom_bytes);
    
    #executes all but the last instruction
    foreach my $i (0..3) {
        CHIP8::cycle();
    }
    
    CHIP8::logging(1);
    CHIP8::cycle();
    
    my $first_value = CHIP8::get_memory_at(0xf9b);
    my $second_value = CHIP8::get_memory_at(0xf9b + 1);
    my $third_value = CHIP8::get_memory_at(0xf9b + 2);
    
    return ($first_value == 42) && ($second_value == 22) &&
        ($third_value == 12);
}

sub test_FZ65 {
    #tests if the values from memory, starting at I through Vx
    #will be copied to V0 through Vx
    CHIP8::initialize(0);
    
    my @rom_bytes = (
        #stores the values 42, 22 and 12 at V0, V1 and V2
        0x60, 0x2a, 0x61, 0x16, 0x62, 0x0c,
        #sets I to the memory location 0xf9b and then
        0xaf, 0x9b,
        #stores the registsers V0 through V2 starting at I and then
        0xf2, 0x55,
        #set the registers V0 through V2 to zero and then
        0x60, 0x00, 0x61, 0x00, 0x62, 0x00,
        #sets I to the memory location 0xf9b
        0xaf, 0x9b,
        #Set the values of V0 through V2 to the values of I(0xf9b), I + 1,
        #I + 2
        0xf2, 0x65
    );
    
    CHIP8::load_rom_from_array(@rom_bytes);
    
    foreach my $i(0..8) {
        CHIP8::cycle();
    }
    
    CHIP8::logging(1);
    CHIP8::cycle();
    
    my ($first_value, $second_value, $third_value);
    $first_value = CHIP8::get_register_value(0);
    $second_value = CHIP8::get_register_value(1);
    $third_value = CHIP8::get_register_value(2);
    
    return ($first_value == 42) && ($second_value == 22) && ($third_value == 12);
}


ok(test_6ZZZ);
ok(test_1_7ZZZ);
ok(test_2_7ZZZ);
ok(test_3_7ZZZ);
ok(test_8ZZ0);
ok(test_8ZZ1);
ok(test_8ZZ2);
ok(test_8ZZ3);
ok(test_nocarry_8ZZ4);
ok(test_withcarry_8ZZ4);
ok(test_1_8ZZ5);
ok(test_2_8ZZ5);
ok(test_1_8ZZ6);
ok(test_2_8ZZ6);
ok(test_1_8ZZ7);
ok(test_2_8ZZ7);
ok(test_1_8ZZE);
ok(test_2_8ZZE);
ok(test_1_9ZZZ);
ok(test_2_9ZZZ);
ok(test_AZZZ);
ok(test_BZZZ);
ok(test_CZZZ);
ok(test_1_DZZZ);
ok(test_2_DZZZ);
ok(test_3_DZZZ);
ok(test_4_DZZZ);
ok(test_EZZE);
ok(test_EZZ1);
ok(test_FZ07);
ok(test_FZ15);
ok(test_FZ18);
ok(test_1_FZ1E);
ok(test_2_FZ1E);
ok(test_FZ29);
ok(test_FZ33);
ok(test_FZ55);
ok(test_FZ65);
