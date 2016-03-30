% SOFI2D file prepare : forward modelling.


close all
clear all
clc

% Set the velocity model over here

Vp = [3000 5000 4000 7000];
Vs = Vp/1.7;
rho =[2000 2000 2000 2000];
depth = [30 20 30 30] % in # of cells !
NXX = 100; % Length in X in # of cells !
name = 'sofi2D_test';
% Time params
T_max=2.5;
dt_mod = 0.2E-3;
abframe = 15;
% Source parameters
source_frequency = 3 ; % [Hz]
vs_min = min(Vs); % Model size (source- dependent)
min_wavelength= vs_min/source_frequency;
discr = 15;

dh = round(min_wavelength/discr);

LENGTH_IN_X = NXX*dh + 2*abframe*dh;

LENGTH_IN_Y = sum(depth) + abframe;
first_rec = (abframe+1) * dh;
last_rec = (abframe+1 + NXX) * dh;
 % Shape and type of the input signal :
shape = 1;
S_TYPE = 1; % 	(point_source): explosive=1;force_in_x=2;force_in_y=3;rotated_force=4" 
x_rec = linspace(first_rec, last_rec, NXX);
y_rec = 1*ones(1,numel(x_rec)); % in m
t_delays = 0*ones(1,numel(x_rec));
freqs = source_frequency*ones(1,numel(x_rec));
amps = 1*ones(1,numel(x_rec));
source_matrix =  [x_rec; y_rec; t_delays; freqs; amps]';
dlmwrite('source.dat', source_matrix, 'delimiter', '\t');
receiver_matrix = [x_rec; y_rec]';
dlmwrite('receiver.dat', source_matrix, 'delimiter', '\t');


return


% Snapshot & receivers params 
num_rec= 100;
IDXX=1;
IDYY=1;
snap=0;
SETYPE = 1;

fileID=fopen('receiver.dat','w');

x1 = (abframe+4)*dh;
x2 = LENGTH_IN_X - x1;
%x1=100;
%x2=100;
y1 = 2*dh;
x=linspace(x1,x2,num_rec);

y=ones(1,length(x))*y1;
%x=[x 20*dh];
%y=[y 9*dh];
P_rec=[x', y'];
dlmwrite('receiver.dat',P_rec,'delimiter','\t','precision',7);
fclose(fileID);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NX = round(LENGTH_IN_X/dh)+1;
NY = round(LENGTH_IN_Y/dh)+1;
if mod(NY,2) == 1
NY = NY -1;
end
if mod(NX,2) == 1
NX = NX -1;
end
vp = zeros(NY,NX);
[X,Y] = meshgrid(0:dh:(NX-1)*dh,0:dh:(NY-1)*dh);
vp = 0.*X;
trial_depth = linspace(0,hypo_DE_depth(end),NY);

ind = find(trial_depth<hypo_DE_depth(1));
vp(ind,:) = hypo_DE_Vp(1)*ones(numel(ind),size(X,2));

for i=2:numel(hypo_DE_Vp)
ind = find(trial_depth > hypo_DE_depth(i-1) & trial_depth <=hypo_DE_depth(i) );
vp(ind,:) = hypo_DE_Vp(i)*ones(numel(ind),size(X,2));
end

if UNIFY==1
vel = linspace(min(min(vp)),max(max(vp)),NY);
for i=1:NY
vp(i,:)=vel(i);
end

end


vs=vp/1.83;

rho = 2000 + 0.*vp; % Density model

vp=kf.*vp;
vs=kf.*vs;

qp = 0.*vp + 250;
qs = 0.*vp + 250;

figure(1)
imagesc(X,Y,vp);
cmap = colormap('gray');
cmap=flipud(cmap);
colormap(cmap)
hold all
plot(P_rec(:,1),P_rec(:,2),'vr','MarkerSize',10,'MarkerFaceColor','green');
plot(x_src,y_src,'*g','MarkerSize',10,'MarkerFaceColor','green');

RHO_MAX=2000*1.1
VP_MAX=max(hypo_DE_Vp)*kf*1.1;
VS_MAX=VP_MAX./1.7;
VP_MIN =min(hypo_DE_Vp)*0.9;
VS_MIN =VP_MIN/1.7;


RTM_MOD_ON =0;
RTM_ON =0;
TIMELAPSE_ON = 0;
FILT_SIZE_CYL=7;
RADIUS_TAPER = FILT_SIZE_CYL*dh;
% Writing into the template file 
fileID=fopen('DENISE_forward_template.inp','r');
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




