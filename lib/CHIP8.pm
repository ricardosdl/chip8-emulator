package CHIP8;
use strict;
use warnings;
use 5.010;
use Fonts;

use Exporter qw(import);
our @EXPORT = qw (get_register_value set_register_value initialize
    _6ZZZ
    _7ZZZ
    _8ZZ0
    _8ZZ1
    _8ZZ2
    _8ZZ3
    _8ZZ4
    _8ZZ5);

my @key_inputs = (0) x 16;
my @display_buffer = (0) x (64 * 32);
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
    $gpio[0xf] = $gpio[$vy] > $gpio[$vx] ? 0 : 1;
    
    $gpio[$vx] = $gpio[$vx] - $gpio[$vy];
    
    $gpio[$vx] &= 0xff;
}

sub _FZ29 {
    log_message("Set index to point to a character");
    $index = (5 * $gpio[$vx]) & 0xfff;
}

sub _DZZZ {
    log_message("Draw sprite...");
    $gpio[0xf] = 0;
    my $x = $gpio[$vx] & 0xff;
    my $y = $gpio[$vy] & 0xff;
    
    my $height = $opcode & 0x000f;
    
    my $row = 0;
    while ($row < $height) {
        my $curr_row = $memory[$row + $index];
        my $pixel_offset = 0;
        while ($pixel_offset < 8) {
            my $loc = $x + $pixel_offset + (($y + $row) * 64);
            $pixel_offset += 1;
            if (($y + $row) >= 32 || ($x + $pixel_offset - 1) >= 64) {
                #ignore pixels outside of screen
                next;
            }
            my $mask = 1 << 8 - $pixel_offset;
            my $curr_pixel = ($curr_row & $mask) >> (8 - $pixel_offset);
            $display_buffer[$loc] ^= $curr_pixel;
            if ($display_buffer[$loc] == 0) {
                $gpio[0xf] = 1;
            }
            else {
                $gpio[0xf] = 0;
            }
        }
        $row += 1;
    }
    $should_draw = 1;
    
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