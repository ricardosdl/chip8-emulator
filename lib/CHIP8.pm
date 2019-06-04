package CHIP8;
use strict;
use warnings;
use 5.010;
use Fonts;

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

my $should_draw = 0;#boolean value

my %func_map = (
    0x0000 => \&_0ZZZ,
    0x00e0 => \&_0ZZ0,
    0x00ee => \&_0ZZE,
    0x1000 => \&_1ZZZ,
);

#chip8 instructions
sub _0ZZZ {
    my $extracted_op = $opcode & 0xf0ff;
    #we must regard for errors
    $func_map{$extracted_op}();
}

sub _0ZZ0 {
    say "Clears screen";
    #maybe just fill the array with zeroes without creating another
    @display_buffer = (0) x (64 * 32);
    $should_draw = 1;
}

sub _0ZZE {
    say "returns from subroutine";
    $pc = pop @stack;
}

sub _1ZZZ {
    say "jumps to address NNN";
    $pc = $opcode & 0x0fff;
}

sub _4ZZZ {
    say "Skips the next instruction if VX doesn't equal NN.";
    $pc += 2 if $gpio[$vx] != ($opcode & 0x00ff);
}

sub _5ZZZ {
    say "Skips the next instruction if Vx == Vy";
    $pc += 2 if $gpio[$vx] == $gpio[$vy];
}

sub _8ZZ4 {
    say "Adds VY to VX. VF is set to 1 when there's a carry, and to 0 when there isn't.";
    if ($gpio[$vx] + $gpio[$vy] > 0xff) {
        $gpio[0xf] = 1;
    }
    else {
        $gpio[0xf] = 0;
    }
    $gpio[$vx] += $gpio[$vy];
    $gpio[$vx] &= 0xff;
    
}

sub clear {
    #clear screen here
}

sub load_rom {
    my ($rom_path) = @_;
    say "Loading $rom_path...";
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

sub cycle {
    $opcode = $memory[$pc];
    
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
        say "Unknown instruction: $opcode";
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