use strict;
use warnings;
use 5.010;

use Graphics::Raylib '+family';
use Graphics::Raylib::XS ':all';
use Graphics::Raylib::Util qw(vector rectangle);
use Cwd 'abs_path';
use Getopt::Std;
use File::Basename 'dirname';
use CHIP8 qw(initialize load_rom_from_file);

getopts 's', \my %opts;

# Global Variables Declaration
use constant SCREEN_WIDTH  => 640;
use constant SCREEN_HEIGHT => 480;

my ($framesCounter, $game_over);
my (%fruit, @snake, @snakePosition, $allowMove, %offset, $counterTail);

init_emulator();

# Initialization
my $g = Graphics::Raylib->window(SCREEN_WIDTH, SCREEN_HEIGHT);

unless ($opts{s}) {
    InitAudioDevice();
}

$g->fps(60);

# Main game loop
while (!$g->exiting) {    # Detect window close button or ESC key
    # Update and Draw
    UpdateDrawFrame();
}

# De-Initialization
#UnloadGame();         # Unload loaded data (textures, sounds, models...)

# Module Functions Definitions (local)

# Initialize game variables
sub init_emulator {
    $framesCounter = 0;
    
    my $num_arguments = @ARGV;
    if ($num_arguments < 1) {
        die "Usage ./chip8-emulator rom_file [[logging] [sound]]";
    }
    
    my $rom_file = $ARGV[0];
    
    CHIP8::initialize();
    
    CHIP8::load_rom_from_file($rom_file);
    
    
}

# Update game (one frame)
sub UpdateGame {
    if ($game_over) {
        if (IsKeyPressed(KEY_ENTER)) {
            InitGame();
            $game_over = 0;
        }
        return;
    }
    
    
    
    $framesCounter++;
}

# Draw game (one frame)
sub DrawGame {
    Graphics::Raylib::draw {
        $g->clear;
    }
}

# Unload game variables
sub UnloadGame {
    # TODO: Unload all dynamic loaded data (textures, sounds, models...)
    CloseAudioDevice();
}

# Update and Draw (one frame)
sub UpdateDrawFrame {
    UpdateGame();
    DrawGame();
}
