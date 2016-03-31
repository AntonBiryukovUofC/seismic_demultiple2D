% SOFI2D file prepare : forward modelling.


close all
clear all
clc

% Set the velocity model over here

Vp = [3000 3000 4000 7000];
Vs = Vp/1.7;
rho =[2000 2000 2000 2000];
depth = [15 1 15 30] % in # of cells !
abframe = 15;
xbase = 60;
NXX =xbase +2*abframe; % Length in X in # of cells !
NYY = sum(depth) + abframe;
name = 'sofi2D_test';
% Time params
T_max=4.5;
dt_mod = 0.2E-3;
% Source parameters
source_frequency = 3 ; % [Hz]
vs_min = min(Vs); % Model size (source- dependent)
min_wavelength= vs_min/source_frequency;
discr = 15;

dh = round(min_wavelength/discr);

LENGTH_IN_X = NXX*dh;

LENGTH_IN_Y = NYY;
first_rec = (abframe+1) * dh;
last_rec = (-abframe-1+ NXX) * dh;
 % Shape and type of the input signal :
shape = 1;
S_TYPE = 1; % 	(point_source): explosive=1;force_in_x=2;force_in_y=3;rotated_force=4" 
x_rec = linspace(first_rec, last_rec, xbase);
y_rec = 1*ones(1,numel(x_rec)); % in m
t_delays = 0*ones(1,numel(x_rec));
freqs = source_frequency*ones(1,numel(x_rec));
amps = 1*ones(1,numel(x_rec));
source_matrix =  [x_rec; y_rec; t_delays; freqs; amps]';
dlmwrite('source.dat', source_matrix, 'delimiter', '\t');
receiver_matrix = [x_rec; y_rec]';
dlmwrite('receiver.dat', source_matrix, 'delimiter', '\t');

% Snapshot & receivers params 
IDXX=1;
IDYY=1;
snap=0;
SETYPE = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vps = zeros(NYY,NXX);
vss = zeros(NYY,NXX);
vps(1:depth(1),:) = Vp(1);
vss(1:depth(1),:) = Vs(1);
levels= cumsum(depth);

for i=numel(Vp):-1:1
	vps(1:levels(i),:) = Vp(i);
	vss(1:levels(i),:) = Vs(i);
	
	
end
vps(levels(end):end,:) = Vp(end);
vss(levels(end):end,:) = Vs(end);

% add chevron notch
ch_height = 9;
level_notch = round(linspace(levels(3),levels(3)+ch_height,NXX/2));
for i=1:NXX/2
	vps(levels(3):level_notch(i),i) = Vp(3);
	vss(levels(3):level_notch(i),i) = Vs(3);

	vps(levels(3):level_notch(i),NXX-i) = Vp(3);
	vss(levels(3):level_notch(i),NXX-i) = Vs(3);
end




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
plot(x_rec,40*y_rec,'vg','MarkerSize',10,'MarkerFaceColor','red');





% Writing into the template file 
fileID=fopen('./template_files/sofi2D_template.json','r');
FILE=fread(fileID, [1 inf] ,'*char');
fclose(fileID);

formatSpec = '%3.2E';
FILE=regexprep(FILE,'DMPP',num2str(DMPP));
FILE=regexprep(FILE,'FORMAT_SEISMOGRAM',FORMAT_SEISMOGRAM);
FILE=regexprep(FILE,'VP_MAX',num2str(VP_MAX));
FILE=regexprep(FILE,'VS_MAX',num2str(VS_MAX));
FILE=regexprep(FILE,'VS_MIN',num2str(VS_MIN));
FILE=regexprep(FILE,'VP_MIN',num2str(VP_MIN));
FILE=regexprep(FILE,'FILT_SIZE_CYL',num2str(FILT_SIZE_CYL));
FILE=regexprep(FILE,'RADIUS_TAPER',num2str(RADIUS_TAPER));

FILE=regexprep(FILE,'RHO_MAX',num2str(RHO_MAX));
FILE=regexprep(FILE,'TIMELAPSE_ON',num2str(TIMELAPSE_ON));

FILE=regexprep(FILE,'SHAPESIG',num2str(shape));
FILE=regexprep(FILE,'RTM_MOD_ON',num2str(RTM_MOD_ON));
FILE=regexprep(FILE,'RTM_ON',num2str(RTM_ON));
FILE=regexprep(FILE,'NAME',name);
FILE=regexprep(FILE,'FWFRAME',num2str(abframe));
FILE=regexprep(FILE,'IDYY',num2str(IDXX));
FILE=regexprep(FILE,'IDXX',num2str(IDYY));
FILE=regexprep(FILE,'NXX',num2str(NX));
FILE=regexprep(FILE,'NYY',num2str(NY));
FILE=regexprep(FILE,'DHH',num2str(dh,formatSpec));
FILE=regexprep(FILE,'TMAX',num2str(T_max,formatSpec));
FILE=regexprep(FILE,'DTT',num2str(dt_mod,formatSpec));
FILE=regexprep(FILE,'RUN_MODE',num2str(RUN_MODE));
FILE=regexprep(FILE,'S_TYPE',num2str(S_TYPE));
FILE=regexprep(FILE,'SNAP_ON',num2str(snap));
FILE=regexprep(FILE,'SOURCE_FREQ',num2str(source_frequency));

FILE=regexprep(FILE,'TSNAPP1',num2str(dt_mod,formatSpec));
FILE=regexprep(FILE,'TSNAPP2',num2str(T_max,formatSpec));
FILE=regexprep(FILE,'SSNAPINC',num2str(10*dt_mod,formatSpec));
FILE=regexprep(FILE,'SETYPE',num2str(SETYPE));
fid=fopen([name 'denise_fw.json'],'wb');
fwrite(fid,FILE);
fclose(fid);
system(['mkdir -p /home/nanoanton/Inversion_DENISE/DENISE_v0/par/su/' name]);
system(['mkdir -p /home/nanoanton/Inversion_DENISE/DENISE_v0/par/model/' name]);
system(['mkdir -p /home/nanoanton/Inversion_DENISE/DENISE_v0/par/snap/' name]);

fid=fopen(['/home/nanoanton/Inversion_DENISE/DENISE_v0/par/model/' name '/' name '.vp'],'wb');
fwrite(fid,vp,'float');
fclose(fid);

fid=fopen(['/home/nanoanton/Inversion_DENISE/DENISE_v0/par/model/' name '/' name '.rho'],'wb');
fwrite(fid,rho,'float');
fclose(fid);

fid=fopen(['/home/nanoanton/Inversion_DENISE/DENISE_v0/par/model/' name '/' name '.vs'],'wb');
fwrite(fid,vs,'float');
fclose(fid);

fid=fopen(['/home/nanoanton/Inversion_DENISE/DENISE_v0/par/model/' name '/' name '.qp'],'wb');
fwrite(fid,qp,'float');
fclose(fid);

fid=fopen(['/home/nanoanton/Inversion_DENISE/DENISE_v0/par/model/' name '/' name '.qs'],'wb');
fwrite(fid,qs,'float');
fclose(fid);

fid=fopen(['/home/nanoanton/Inversion_DENISE/DENISE_v0/par/' name 'denise_fw.inp' ],'wb');
fwrite(fid,FILE);
fclose(fid);

fileID=fopen('run_denise_copy_files.sh','r');
FILE=fread(fileID, [1 inf] ,'*char');
FILE=regexprep(FILE,'NAME',name);
FILE=regexprep(FILE,'MODE','fw');
fclose(fileID)


fileID=fopen('receiver.dat','w');

dlmwrite(['/home/nanoanton/Inversion_DENISE/DENISE_v0/par/receiver/' name 'receiver.dat'] ,P_rec,'delimiter','\t','precision',7);
fclose(fileID);


fid=fopen(['/home/nanoanton/Inversion_DENISE/DENISE_v0/par/' name '_run_denise_copy_files.sh'],'wb');
fwrite(fid,FILE);
fclose(fid);
system(['chmod +x /home/nanoanton/Inversion_DENISE/DENISE_v0/par/' name '_run_denise_copy_files.sh']);




