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

my $should_draw = 0;#boolean value

my %func_map = ();

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
    
    my $vx = ($opcode & 0x0f00) >> 8;
    my $vy = ($opcode & 0x00f0) >> 4;
    
    
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