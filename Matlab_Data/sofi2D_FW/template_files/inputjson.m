fileID=fopen('sofi2D_template.json','r');
FILE=fread(fileID, [1 inf] ,'*char');
NAMES=strfind(FILE,'NAME');
nx=size(vp1,2);
ny=size(vp1,1);
formatSpec = '%3.2E';
FILE=regexprep(FILE,'DMPP',num2str(DMP));
FILE=regexprep(FILE,'SHAPESIG',num2str(shape));
FILE=regexprep(FILE,'PERIODIC',num2str(periodic_boundary));
FILE=regexprep(FILE,'NAME',name);
FILE=regexprep(FILE,'FWFRAME',num2str(abframe));
FILE=regexprep(FILE,'IDYY',num2str(IDXX));
FILE=regexprep(FILE,'IDXX',num2str(IDYY));
FILE=regexprep(FILE,'NXX',num2str(nx));
FILE=regexprep(FILE,'NYY',num2str(ny));
FILE=regexprep(FILE,'DHH',num2str(dh,formatSpec));
FILE=regexprep(FILE,'TMAX',num2str(T_max,formatSpec));
FILE=regexprep(FILE,'DTT',num2str(dt_mod,formatSpec));

FILE=regexprep(FILE,'LL',num2str(LL));
FILE=regexprep(FILE,'FREQ1',num2str(FLL(1)));
FILE=regexprep(FILE,'FREQ2',num2str(FLL(2)));
FILE=regexprep(FILE,'FREQ3',num2str(FLL(3)));
if numel(FLL)>3
FILE=regexprep(FILE,'FREQ4',num2str(FLL(4)));
end
FILE=regexprep(FILE,'S_TYPE',num2str(TYPE));
FILE=regexprep(FILE,'SNAP_ON',num2str(snap));
FILE=regexprep(FILE,'TTAU',num2str(0));
FILE=regexprep(FILE,'TSNAPP1',num2str(dt_mod,formatSpec));
FILE=regexprep(FILE,'TSNAPP2',num2str(T_max,formatSpec));
FILE=regexprep(FILE,'SSNAPINC',num2str(10*dt_mod,formatSpec));
FILE=regexprep(FILE,'SETYPE',num2str(SETYPE));
fid=fopen('sofi2D.json','wb');
fwrite(fid,FILE);
fclose(fid);