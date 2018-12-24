% display home screen of app

% initialize a figure
screen = figure('Position', [78, 50, 1280, 720], 'Color', [211/256, 228/256, 255/256], 'Name', 'PhotoLAB');

% move figure to center of screen
movegui(screen, 'center')

% remove axes
axis off

% display welcome message
text(0.5, 0.8, 'PhotoLAB', 'FontSize', 84, 'HorizontalAlignment', 'center',...
    'FontName', 'Helvetica');
text(0.5, 0.65, 'Ian Ong & Hunter Liu', 'FontSize', 28, 'HorizontalAlignment',...
    'center', 'FontName', 'Helvetica');
text(0.5, 0.55, 'Press anything to start!', 'FontSize', 16, 'HorizontalAlignment',...
    'center', 'FontName', 'Helvetica');

% display controls dialog
text(0.5, 0.4, 'Controls:', 'FontSize', 32, 'HorizontalAlignment',...
    'center', 'FontName', 'Helvetica', 'Color', [224/256, 211/256, 255/256]);
text(0.5, 0.3, 'Spacebar: take a picture and save it to the directory', 'FontSize', 22, 'HorizontalAlignment',...
    'center', 'FontName', 'Helvetica', 'Color', [211/256, 255/256, 238/256]);
text(0.5, 0.25, 'Backspace: delete the latest picture from the directory', 'FontSize', 22, 'HorizontalAlignment',...
    'center', 'FontName', 'Helvetica', 'Color', [211/256, 255/256, 238/256]);
text(0.5, 0.2, 'Swipe mouse up/down: control brightness', 'FontSize', 22, 'HorizontalAlignment',...
    'center', 'FontName', 'Helvetica', 'Color', [211/256, 255/256, 238/256]);
text(0.5, 0.15, 'Swipe mouse left/right: switch filter', 'FontSize', 22, 'HorizontalAlignment',...
    'center', 'FontName', 'Helvetica', 'Color', [211/256, 255/256, 238/256]);

% wait for a button to be pressed
try
    buttonPress = waitforbuttonpress;
catch error
    % in case the user closes out the program
end

% close splash screen and launch main screen
close gcf
detectAndTrackFaces;

