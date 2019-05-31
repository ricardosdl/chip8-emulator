package CHIP8;
use strict;
use warnings;
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

sub clear {
}

sub initialize {
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
    
    for
    
}