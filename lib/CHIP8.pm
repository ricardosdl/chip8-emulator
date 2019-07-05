package CHIP8;
use strict;
use warnings;
use 5.010;
use Fonts;

use Exporter qw(import);
our @EXPORT = qw (get_register_value set_register_value get_pc_value initialize
    get_index_value get_display_buffer_at get_key_input set_key_input
);

my @key_inputs = (0) x 16;
my $SCREEN_WIDTH = 64;
my $SCREEN_HEIGHT = 32;
my $NUM_PIXELS = $SCREEN_WIDTH * $SCREEN_HEIGHT;
my @display_buffer = (0) x $NUM_PIXELS;
my @memory = (0) x 4096;
my @gpio = (0) x 16;#16 8-bit registers
my $sound_timer = 0;
my $delay_timer = 0;
my $index = 0;#16-bit index register
my $opcode = 0;
my $pc = 0;#16-bit program counter
my @stack = ();#stack pointer
my ($vx, $vy);#registers adresses
my $LOGGING = 1;

my $should_draw = 0;#boolean value

my %func_map = (
    0x0000 => \&_0ZZZ,
    0x00e0 => \&_0ZZ0,
    0x00ee => \&_0ZZE,
    0x1000 => \&_1ZZZ,
    0x6000 => \&_6ZZZ,
    0x7000 => \&_7ZZZ,
    0x8000 => \&_8ZZZ,
    0x8FF0 => \&_8ZZ0,
    0x8FF1 => \&_8ZZ1,
    0x8FF2 => \&_8ZZ2,
    0x8FF3 => \&_8ZZ3,
    0x8FF4 => \&_8ZZ4,
    0x8FF5 => \&_8ZZ5,
    0x8FF6 => \&_8ZZ6,
    0x8FF7 => \&_8ZZ7,
    0x8FFE => \&_8ZZE,
    0x9000 => \&_9ZZZ,
    0xA000 => \&_AZZZ,
    0xB000 => \&_BZZZ,
    0xC000 => \&_CZZZ,
    0xD000 => \&_DZZZ,
    0xE000 => \&_EZZZ,
    0xE00E => \&_EZZE,
    0xE001 => \&_EZZ1,
    0xF000 => \&_FZZZ,
    0xF007 => \&_FZ07,
    0xF00A => \&_FZ0A,
    0xF015 => \&_FZ15,
    0xF018 => \&_FZ18,
    0xF01E => \&_FZ1E,
    0xF029 => \&_FZ29,
    0xF033 => \&_FZ33,
    0xF055 => \&_FZ55,
    0xF065 => \&_FZ65
);

sub logging {
    my ($new_logging) = @_;
    my $old_logging = $LOGGING;
    if (defined $new_logging) {
        $LOGGING = $new_logging;
        return $old_logging;
    }
    return $LOGGING;
}

sub log_message {
    my ($message) = @_;
    say $message if $LOGGING;
}

sub get_register_value {
    my ($register) = @_;
    return $gpio[$register];
}

sub set_register_value {
    my ($register, $value) = @_;
    $gpio[$register] = $value;
}

sub get_pc_value {
    return $pc;
}

sub get_index_value {
    return $index;
}

sub get_display_buffer_at {
    my ($x, $y) = @_;
    return $display_buffer[(64 * $y + $x) % $NUM_PIXELS];
}

sub get_memory_at {
    my ($address) = @_;
    return $memory[$address];
}

sub get_key_input {
    my ($key) = @_;
    return $key_inputs[$key];
}

sub set_key_input {
    my ($key) = @_;
    return $key_inputs[$key] = 1;
}

sub get_delay_timer {
    return $delay_timer;
}

sub get_sound_timer {
    return $sound_timer;
}

sub set_delay_timer {
    my ($new_delay_timer_value) = @_;
    $delay_timer = $new_delay_timer_value;
}

#chip8 instructions
sub _0ZZZ {
    my $extracted_op = $opcode & 0xf0ff;
    #we must regard for errors
    $func_map{$extracted_op}();
}

sub _0ZZ0 {
    log_message("Clears screen");
    #maybe just fill the array with zeroes without creating another
    @display_buffer = (0) x (64 * 32);
    $should_draw = 1;
}

sub _0ZZE {
    log_message("returns from subroutine");
    $pc = pop @stack;
}

sub _1ZZZ {
    log_message("jumps to address NNN");
    $pc = $opcode & 0x0fff;
}

sub _2ZZZ {
    
}

sub _3ZZZ {
    log_message("Skips the next instruction if Vx equals NN.");
    $pc += 2 if $gpio[$vx] == ($opcode & 0x00ff);
}

sub _4ZZZ {
    log_message("Skips the next instruction if VX doesn't equal NN.");
    $pc += 2 if $gpio[$vx] != ($opcode & 0x00ff);
}

sub _5ZZZ {
    log_message("Skips the next instruction if Vx == Vy");
    $pc += 2 if $gpio[$vx] == $gpio[$vy];
}

sub _6ZZZ {
    log_message("Sets Vx to NN");
    $gpio[$vx] = $opcode & 0xff;
}

sub _7ZZZ {
    my $nn = $opcode & 0x00ff;
    log_message("Adds NN($nn) to Vx($vx)");
    $gpio[$vx] += $nn;
    $gpio[$vx] &= 0xff;
}

sub _8ZZZ {
    my $extracted_op = $opcode & 0xf00f;
    $extracted_op += 0xff0;
    #look for errors
    $func_map{$extracted_op}();
}

sub _8ZZ0 {
    log_message("Sets Vx to the value of Vy");
    $gpio[$vx] = $gpio[$vy];
    #$gpio[$vx] &= 0xff;
}

sub _8ZZ1 {
    log_message("Sets Vx to Vx or Vy");
    $gpio[$vx] |= $gpio[$vy];
}

sub _8ZZ2 {
    log_message("Set Vx = Vx AND Vy.");
    $gpio[$vx] &= $gpio[$vy];
}

sub _8ZZ3 {
    log_message('Set Vx = Vx XOR Vy.');
    $gpio[$vx] ^= $gpio[$vy];
}

sub _8ZZ4 {
    log_message("Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.");
    if ($gpio[$vx] + $gpio[$vy] > 0xff) {
        $gpio[0xf] = 1;
    }
    else {
        $gpio[0xf] = 0;
    }
    $gpio[$vx] += $gpio[$vy];
    $gpio[$vx] &= 0xff;
    
}

sub _8ZZ5 {
    log_message("VY is subtracted from VX. VF is set to 0 when there's a borrow, and 1 when there isn't");
    $gpio[0xf] = $gpio[$vx] > $gpio[$vy] ? 1 : 0;
    
    $gpio[$vx] = $gpio[$vx] - $gpio[$vy];
    
    $gpio[$vx] &= 0xff;
}

sub _8ZZ6 {
    log_message('Set Vx = Vx SHR 1.  VF is set to the value of the least significant bit of VX before the shift.');
    $gpio[0xf] = $gpio[$vx] & 0x0001;
    $gpio[$vx] = $gpio[$vx] >> 1;
}

sub _8ZZ7 {
    log_message("Set Vx = Vy - Vx, set VF = NOT borrow.");
    $gpio[0xf] = $gpio[$vy] > $gpio[$vx] ? 1 : 0;
    $gpio[$vx] = $gpio[$vy] - $gpio[$vx];
    $gpio[$vx] &= 0xff;
}

sub _8ZZE {
    log_message("Set Vx = Vx SHL 1. VF is set to the value of the most significant bit of VX before the shift");
    $gpio[0xf] = $gpio[$vx] >> 7;
    $gpio[$vx] = $gpio[$vx] << 1;
    $gpio[$vx] &= 0xff;
}

sub _9ZZZ {
    log_message('Skip next instruction if Vx != Vy.');
    $pc += 2 if $gpio[$vx] != $gpio[$vy];
}

sub _AZZZ {
    log_message('Set I = nnn.');
    $index = $opcode & 0x0fff;
}

sub _BZZZ {
    log_message('Jump to location nnn + V0.');
    $pc = ($opcode & 0x0fff) + $gpio[0];
}

sub _CZZZ {
    log_message('Set Vx = random byte AND kk.');
    my $random_byte = int rand(256);
    $gpio[$vx] = $random_byte & ($opcode & 0xff);
    $gpio[$vx] &= 0xff;
}

sub _DZZZ {
    log_message("Draw sprite...");
    my $x = $gpio[$vx] & 0xff;
    my $y = $gpio[$vy] & 0xff;
    
    my $height = $opcode & 0x000f;
    
    $gpio[0xf] = 0;
    
    my $row = 0;
    while ($row < $height) {
        my $byte = $memory[$index + $row];
        my $pixel_offset = 0;
        while ($pixel_offset < 8) {
            #the value of the bit in the sprite
            my $bit = ($byte >> $pixel_offset) & 0x1;
            
            my $current_pixel_x = ($x + 7 - $pixel_offset) % $SCREEN_WIDTH;
            my $current_pixel_y = (($y + $row) % $SCREEN_HEIGHT) * 64;
            
            #the value of the current pixel on screen
            my $current_pixel = $display_buffer[$current_pixel_y +
                $current_pixel_x];
            #$current_pixel &= 0x1;
            
            $gpio[0xf] = 1 if ($bit && $current_pixel);
            
            $display_buffer[$current_pixel_y +
                $current_pixel_x] = $current_pixel ^ $bit;
            
            $pixel_offset++;
        }
        $row += 1;
    }
    $should_draw = 1;
    
}

sub _EZZZ {
    my $extracted_op = $opcode & 0xf00f;
    #treat errors when op not found
    $func_map{$extracted_op}();
}

sub _EZZE {
    log_message('Skip next instruction if key with the value of Vx is pressed.');
    my $key = $gpio[$vx] & 0xf;
    $pc += 2 if $key_inputs[$key];
}

sub _EZZ1 {
    log_message('Skip next instruction if key with the value of Vx is not pressed.');
    my $key = $gpio[$vx] & 0xf;
    $pc += 2 unless $key_inputs[$key];
}

sub _FZZZ {
    my $extracted_op = $opcode & 0xf0ff;
    #treat errors when op not found
    $func_map{$extracted_op}();
}

sub _FZ07 {
    log_message('Set Vx = delay timer value.');
    $gpio[$vx] = $delay_timer;
}

sub _FZ0A {
    #TODO: write a test for this op code
    log_message('Wait for a key press, store the value of the key in Vx.');
    #TODO: get key here
    my $key = -1;
    if ($key >= 0) {
        $gpio[$vx] = $key;
    }
    else {
        $pc -= 2;
    }
}

sub _FZ15 {
    log_message('Set delay timer = Vx.');
    $delay_timer = $gpio[$vx];
}

sub _FZ18 {
    log_message('Set sound timer = Vx.');
    $sound_timer = $gpio[$vx];
}

sub _FZ1E {
    log_message('Set I = I + Vx. if overflow Vf is set to 1');
    $gpio[0xf] = ($index + $gpio[$vx]) > 0xfff ? 1 : 0;
    $index += $gpio[$vx];
    $index &= 0xfff;
}

sub _FZ29 {
    log_message("Set index to point to a character");
    $index = (5 * $gpio[$vx]) & 0xfff;
}

sub _FZ33 {
    log_message('Store BCD representation of Vx in memory locations I, I+1, and I+2.');
    $memory[$index] = int($gpio[$vx] / 100);
    $memory[$index + 1] = int(($gpio[$vx] % 100) / 10);
    $memory[$index + 2] = $gpio[$vx] % 10;
}

sub _FZ55 {
    log_message('Store registers V0 through Vx in memory starting at location I.');
    my $i = 0;
    while($i <= $vx) {
        $memory[$index + $i] = $gpio[$i];
        $i = $i + 1;
    }
    $index = $index + $i + 1;
}

sub _FZ65 {
    log_message('Read registers V0 through Vx from memory starting at location I.');
    my $i = 0;
    while($i <= $vx) {
        $gpio[$i] = $memory[$index + $i];
        $i = $i + 1;
    }
    $index = $index + $i + 1;
}

sub clear {
    #clear screen here
}

sub load_rom_from_file {
    my ($rom_path) = @_;
    log_message("Loading $rom_path...");
    open my $rom_file, '<:raw', $rom_path or die "Could not open rom file: $!";
    my $i = 0;
    while (1) {
        my $read_bytes = read $rom_file, my $byte, 1;
        die "Error reading rom file:$!" if not defined $read_bytes;
        $memory[$i + 0x200] = $byte;
        $i++;
        last if not $read_bytes;
    }
    close $rom_file;
}

sub load_rom_from_array {
    my @bytes_array = @_;
    my $size = @bytes_array;
    log_message("Loading from array of bytes, array size: $size bytes");
    my $i = 0;
    foreach my $byte (@bytes_array) {
        $memory[$i + 0x200] = $byte;
        $i++;
    }
}

sub cycle {
    $opcode = ($memory[$pc] << 8) | $memory[$pc + 1];
    
    $vx = ($opcode & 0x0f00) >> 8;
    $vy = ($opcode & 0x00f0) >> 4;
    
    
    #process the op code
    
    #After
    $pc += 2;
    
    my $extracted_op = $opcode & 0xf000;
    if (exists $func_map{$extracted_op}) {
        $func_map{$extracted_op}();
    }
    else {
        log_message("Unknown instruction: $opcode");
    }
    
    #decrement timers
    if ($delay_timer > 0) {
        $delay_timer -= 1;
    }
    if ($sound_timer > 0) {
        $sound_timer -= 1;
        if ($sound_timer == 0) {
            #play sound here
        }
    }
    
    
}


sub initialize {
    my ($logging) = @_;
    if (defined $logging) {
        $LOGGING = $logging;
    }
    clear;
    @memory = (0) x 4096;
    @gpio = (0) x 16;
    @display_buffer = (0) x (64 * 32);
    @stack = ();
    @key_inputs = (0) * 16;
    $opcode = 0;
    $index = 0;
    
    $delay_timer = 0;
    $sound_timer = 0;
    $should_draw = 0;
    
    $pc = 0x200;
    
    for my $i (0..79) {
        $memory[$i] = Fonts::get_font_byte($i);
    }
    
}