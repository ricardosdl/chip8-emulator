use strict;
use warnings;
use 5.010;
use SDL;
use SDLx::App;

my $app = SDLx::App->new(width => 640,
    height => 320,
    title => 'Perl - CHIP8 emulator');

$app->update();

sleep(2);