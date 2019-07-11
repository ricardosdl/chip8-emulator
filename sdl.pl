use strict;
use warnings;
use 5.010;
use SDL;
use SDLx::App;
use SDLx::Sprite;
use SDL::Event;

my $app = SDLx::App->new(
    width => 640,
    height => 320,
    title => 'Perl - CHIP8 emulator',
    exit_on_quit => 1
);

$app->run();

$app->draw_rect([0, 0, 100, 100], [133, 78, 45, 255]);

$app->update();






###loading and drawing an image
#~ my $sprite = SDLx::Sprite->new(image => './data/images/hero-180x180.png');
#~ $sprite->draw_xy($app, 20, 20);

