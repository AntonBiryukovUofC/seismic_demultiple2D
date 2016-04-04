% SOFI2D file prepare : forward modelling.


close all
clear all
clc
% Set the velocity model over here

Vp = [3000 3000 3000 7000];
VPMAX = max(Vp);
Vs = Vp/1.7;
rho =[2000 2200 2200 2300];
depth = [25 1 25 40] % in # of cells !
abframe = 15;
xbase = 150;
NXX =xbase +2*abframe; % Length in X in # of cells !
NYY = sum(depth) + abframe;
name = 'sofi2D_test';

delete(['/home/geoanton/Matlab_Data/sofi2D/par/model/' name '.vp'])
delete(['/home/geoanton/Matlab_Data/sofi2D/par/model/' name '.vs'])
delete(['/home/geoanton/Matlab_Data/sofi2D/par/model/' name '.rho'])
delete(['/home/geoanton/Matlab_Data/sofi2D/par/sources/*.dat'])
delete(['/home/geoanton/Matlab_Data/sofi2D/par/receiver/*.dat'])
delete(['/home/geoanton/Matlab_Data/sofi2D/par/in_and_out/*.json'])
delete(['/home/geoanton/Matlab_Data/sofi2D/par/su/*.*'])
delete(['/home/geoanton/Matlab_Data/sofi2D/par/snap/*.*'])


% Time params
T_max=7.5;
dt_mod = 8E-4;
% Source parameters
source_frequency = 4 ; % [Hz]
vs_min = min(Vs); % Model size (source- dependent)
min_wavelength= vs_min/source_frequency;
discr = 19;


FREE_AT_TOP = 1;
MULT_SHOT = 0;
ABS_COND_TYPE = 1;

dh = round(min_wavelength/discr);

LENGTH_IN_X = NXX*dh;

LENGTH_IN_Y = NYY;
first_rec = (abframe+2) * dh;
last_rec = first_rec + xbase*dh;
 % Shape and type of the input signal :
shape = 1;
S_TYPE = 1; % 	(point_source): explosive=1;force_in_x=2;force_in_y=3;rotated_force=4" 
x_rec = linspace(first_rec, last_rec, xbase);
y_rec = dh*2*ones(1,numel(x_rec)); % in m
t_delays = 0*ones(1,numel(x_rec));
freqs = source_frequency*ones(1,numel(x_rec));
amps = 1*ones(1,numel(x_rec));
source_matrix =  [x_rec; y_rec; t_delays; freqs; amps]';
dlmwrite('source.dat', source_matrix, 'delimiter', '\t');
receiver_matrix = [x_rec; y_rec]';
dlmwrite('receiver.dat', receiver_matrix, 'delimiter', '\t');

% Snapshot & receivers params 
IDXX=1;
IDYY=1;
snap=2;
SETYPE = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vps = zeros(NYY,NXX);
vss = zeros(NYY,NXX);
rhos= zeros(NYY,NXX);
vps(1:depth(1),:) = Vp(1);
vss(1:depth(1),:) = Vs(1);
rhos(1:depth(1),:) = rhos(1);
levels= cumsum(depth);

for i=numel(Vp):-1:1
	vps(1:levels(i),:) = Vp(i);
	vss(1:levels(i),:) = Vs(i);
	rhos(1:levels(i),:) = rho(i);
	
end
vps(levels(end):end,:) = Vp(end);
vss(levels(end):end,:) = Vs(end);
rhos(levels(end):end,:) = rho(end);

% add chevron notch
ch_height = 9;
level_notch = round(linspace(levels(3),levels(3)+ch_height,NXX/2));
for i=1:NXX/2
	vps(levels(3):level_notch(i),i) = Vp(3);
	vss(levels(3):level_notch(i),i) = Vs(3);
	rhos(levels(3):level_notch(i),i) = rho(3);

	vps(levels(3):level_notch(i),NXX-i) = Vp(3);
	vss(levels(3):level_notch(i),NXX-i) = Vs(3);
	rhos(levels(3):level_notch(i),NXX-i) = rho(3);


end






%system(['mkdir -p /home/geoanton/Matlab_Data/sofi2D/par/su/' name]);
%system(['mkdir -p /home/geoanton/Matlab_Data/sofi2D/par/model/' name]);
%system(['mkdir -p /home/geoanton/Matlab_Data/sofi2D/par/snap/' name]);


fid=fopen(['/home/geoanton/Matlab_Data/sofi2D/par/model/' name '.vp'],'wb');
fwrite(fid,vps,'float');
fclose(fid);

fid=fopen(['/home/geoanton/Matlab_Data/sofi2D/par/model/' name '.rho'],'wb');
fwrite(fid,rhos,'float');
fclose(fid);

fid=fopen(['/home/geoanton/Matlab_Data/sofi2D/par/model/' name '.vs'],'wb');
fwrite(fid,vss,'float');
fclose(fid);



hf = figure(1);
set(hf,'Position',[10 10 600 800]);
pcolor((1:NXX)*dh,(1:NYY)*dh,vps);
cmap = colormap('gray');
cmap=flipud(cmap);
colormap(cmap)
shading interp
hold all
for i=1:numel(Vp)
	%hl = line([0 NXX*dh],[levels(i)*dh levels(i)*dh],'Color','r','LineWidth',4.5);
end
set(gca,'YDir','reverse')
plot(x_rec,y_rec,'vg','MarkerSize',10,'MarkerFaceColor','red');







% Writing into the template file 
fileID=fopen('./template_files/sofi2D_template.json','r');
FILE=fread(fileID, [1 inf] ,'*char');
fclose(fileID);

formatSpec = '%3.2E';
FILE=regexprep(FILE,'VPMAX',num2str(VPMAX));

FILE=regexprep(FILE,'NAME',name);
FILE=regexprep(FILE,'FWFRAME',num2str(abframe));
FILE=regexprep(FILE,'IDYY',num2str(IDXX));
FILE=regexprep(FILE,'IDXX',num2str(IDYY));
FILE=regexprep(FILE,'NXX',num2str(NXX));
FILE=regexprep(FILE,'NYY',num2str(NYY));
FILE=regexprep(FILE,'DHH',num2str(dh,formatSpec));
FILE=regexprep(FILE,'TMAX',num2str(T_max,formatSpec));
FILE=regexprep(FILE,'DTT',num2str(dt_mod,formatSpec));
FILE=regexprep(FILE,'SNAP_ON',num2str(snap));
FILE=regexprep(FILE,'SOURCE_FREQ',num2str(source_frequency));
FILE=regexprep(FILE,'MULT_SHOT',num2str(MULT_SHOT));
FILE=regexprep(FILE,'FREE_AT_TOP',num2str(FREE_AT_TOP));

FILE=regexprep(FILE,'ABS_COND_TYPE',num2str(ABS_COND_TYPE));


FILE=regexprep(FILE,'TSNAPP1',num2str(dt_mod,formatSpec));
FILE=regexprep(FILE,'TSNAPP2',num2str(T_max,formatSpec));
FILE=regexprep(FILE,'SSNAPINC',num2str(10*dt_mod,formatSpec));
FILE=regexprep(FILE,'SETYPE',num2str(SETYPE));
SEIS_FILE_FOLDER = ['/home/geoanton/Matlab_Data/sofi2D/par/su/' name ];
FILE=regexprep(FILE,'SEIS_FILE_FOLDER',num2str(SEIS_FILE_FOLDER));

fid=fopen(['/home/geoanton/Matlab_Data/sofi2D/par/in_and_out/' name '.json'],'wb');
fwrite(fid,FILE);
fclose(fid);
copyfile('receiver.dat','/home/geoanton/Matlab_Data/sofi2D/par/receiver/receiver.dat')
copyfile('source.dat','/home/geoanton/Matlab_Data/sofi2D/par/sources/source.dat')



