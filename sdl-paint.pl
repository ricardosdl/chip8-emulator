use strict;
use warnings;
use 5.010;
use SDL;
use SDLx::App;
use SDL::Event;
use Cwd;

my $app = SDLx::App->new( w => 600, h => 480, d => 32, title => "Simple Paint");
sub quit_event {

    my $event = shift;
    my $controller = shift;
    $controller->stop if $event->type == SDL_QUIT;

}

my @colors = (  0xFF0000FF, 0x00FF00FF,
        0x0000FFFF, 0xFFFF00FF,
        0xFF00FFFF, 0x00FFFFFF,
        0xCCFFCCFF, 0xFFCC33FF,
        0x000000FF, 0xFFFFFFFF );

my $brush_color = 0;

my $drawing = 0;
sub mouse_event {

    my $event = shift;

    if($event->type == SDL_MOUSEBUTTONDOWN || $drawing)
    {

        $drawing = 1;
        my $x =  $event->button_x;
        my $y =  $event->button_y;
        $app->draw_rect( [$x,$y, 2, 2],  $colors[$brush_color]);
        $app->update();
        say "here";
    }
    $drawing = 0 if($event->type == SDL_MOUSEBUTTONUP );
    say "inside mouse_event";
}

sub save_image {
    if (SDL::Video::save_BMP($app, 'painted.bmp') == 0 &&
    -e 'painted.bmp') {
        warn 'Saved painted.bmp to ' . cwd();
    }
    else {
        warn 'Could not save painted.bmp: ' . SDL::get_errors();
    }
}

sub keyboard_event {

    my $event = shift;
    my $controller = shift;
    if ( $event->type == SDL_KEYDOWN )
    {
        my $key_name = SDL::Events::get_key_name( $event->key_sym );

        $brush_color = $key_name if $key_name =~ /\d/;

        my $mod_state = SDL::Events::get_mod_state();        
        save_image if $key_name =~ /^s$/ && ($mod_state & KMOD_CTRL); 

        $app->draw_rect( [0,0,$app->w, $app->h], 0 ) if $key_name =~ /^c$/;
        $controller->stop() if $key_name =~ /^q$/
    }
    $app->update();
    say "also here";
    return 1;
}

$app->add_event_handler( \&quit_event );
$app->add_event_handler( \&mouse_event );
$app->add_event_handler( \&keyboard_event );
$app->run();