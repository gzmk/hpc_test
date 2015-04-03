

% print the new values of parameters for every fminsearch iteration
sprintf('The new variables are: ro_s: %f ro_d: %f alphau: %f', var(1), var(2), var(3))

%% to write new conditions file with replaced params
% write to file in tabular form
% var = XBest; % this is to re-render the best fits
var = [0.0760; 0.2168; 0.1573]; % this is for test

% THIS IS FOR MULTISPECTRAL RENDERING
ro_s = ['300:',num2str(var(1)/(var(1)+var(2))),' 800:',num2str(var(1)/(var(1)+var(2)))];
ro_d = ['300:', num2str(var(2)/(var(1)+var(2))), ' 800:', num2str(var(2)/(var(1)+var(2)))];
alphau = var(3); % alphau and alphav should always be the same value for isotropic brdf
light = ['300:', num2str(var(1)+var(2)), ' 800:',num2str(var(1)+var(2))];
mycell = {ro_s, ro_d, alphau,light};

T = cell2table(mycell, 'VariableNames', {'ro_s' 'ro_d' 'alphau' 'light'});
writetable(T,'/scratch/gk925/hpc_test/sphere_3params_Conditions.txt','Delimiter','\t')
%% Rendering bit

% Set preferences
setpref('RenderToolbox3', 'workingFolder', '/scratch/gk925/render-toolbox');

% use this scene and condition file. 
parentSceneFile = 'test_sphere.dae';
% WriteDefaultMappingsFile(parentSceneFile); % After this step you need to edit the mappings file

conditionsFile = 'sphere_3params_Conditions.txt';
mappingsFile = 'sphere_3params_DefaultMappings.txt';

% Make sure all illuminants are added to the path. 
addpath(genpath(pwd))

% Choose batch renderer options.

hints.imageWidth = 668;% this is isotropic scaling (orig. size divided by 4)
hints.imageHeight = 1005;
hints.renderer = 'Mitsuba';

datetime=datestr(now);
datetime=strrep(datetime,':','_'); %Replace colon with underscore
datetime=strrep(datetime,'-','_');%Replace minus sign with underscore
datetime=strrep(datetime,' ','_');%Replace space with underscore
%hints.recipeName = ['Test-SphereFit' datetime];
hints.recipeName = ['Test-SphereFit' date];

ChangeToWorkingFolder(hints);

% nativeSceneFiles = MakeSceneFiles(parentSceneFile, '', mappingsFile, hints);
nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);

%comment all this out
toneMapFactor = 10;
isScale = true;
montageName = sprintf('%s (%s)', 'Test-SphereFit', hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);

return

% load the monochromatic image and display it
% imPath = ['/scratch/gk925/render-toolbox/', hints.recipeName, '/renderings/Mitsuba/test_sphere-001.mat']
% load(imPath, 'multispectralImage');
% im2 = multispectralImage;
% figure;imshow(im2(:,:,1))

