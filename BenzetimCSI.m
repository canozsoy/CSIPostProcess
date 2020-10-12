%{
This is a post-process tool for numerical model CSI (2007). 

BenzetimCSI takes CSI output, Shoreline x and y as inputs. It implement
one-line results to the actual shoreline for visualization. Code's outputs
will be named as desiredX and desiredY. 

Sections named inputs should be investigated. CSI output figure or x and y
coordinates can be given as inputs to the program.
 
Important note on inputs!

Note that shoreline coordinates should be given monothonically left to
right to the program.

C. Özsoy (2020)
%}


clc
clear
close all
tic

%% Inputs --General

orgShore=dlmread('shoreline.txt');                                          % Enter original shoreline as x,y (note that it should be ordered as original shore)
startX=640860;                                                              % Start of x-coordinate of CSI Model Area
inputType=2;                                                                % Enter input type, (1):x and y, (2):figure
sampleRate=0.01;                                                            % It is important on accuracy of the program (0.01 is advised)
saveDoc=0;                                                                  % To save coordinates (1)
outputFileName='outputCoordinatesCopernicus.txt';                                 % Enter output filename and file extension

%% Inputs --inputType==1

xName='x.mat';                                                              % Enter x coordinates filename
yName='y.mat';                                                              % Enter y coordinates filename

%% Inputs --inputType==2

figName='CSIOutput.fig';                                        % Enter figure name (if inputType==2)

%% Calculations

switch inputType
    case 1
        xCSI=load(xName);
        yCSI=load(yName);
    case 2
        fig=openfig(figName,'invisible');
        axObjs=fig.Children;
        dataObjs=axObjs.Children;
        xCSI=dataObjs(end).XData;
        yCSI=dataObjs(end).YData;
        close(gcf);
        clear fig axObjs dataObjs;
end

[rowOrg,colOrg]=size(orgShore);
j=1;
k=1;

for i=1:(rowOrg-1)
    if i==1
        prevCheckCond=1;
    else
        if i==214
            can=1;
        end
        checkCond=orgShore(i+1,1)-orgShore(i,1);
        if checkCond*prevCheckCond<0
            splitShore{1,j}=orgShore(k:i,1:2);
            splitShore{1,j+1}=orgShore(i:end,1:2);
            j=j+1;
            k=i;
        end
        prevCheckCond=checkCond;
    end
end

[numbSplit]=numel(splitShore);

for i=1:numbSplit
    if mod(i,2)==1
        iniGridX{1,i}=splitShore{1,i}(1,1):sampleRate:splitShore{1,i}(end,1);
    else
        iniGridX{1,i}=splitShore{1,i}(1,1):-sampleRate:splitShore{1,i}(end,1);
    end
    iniGridY{1,i}=interp1(splitShore{1,i}(:,1),splitShore{1,i}(:,2),iniGridX{1,i});
    if i==1
        gridX=iniGridX{1,i};
        gridY=iniGridY{1,i};
    else
        tempX=iniGridX{1,i};
        tempY=iniGridY{1,i};
        gridX=horzcat(gridX,tempX);
        gridY=horzcat(gridY,tempY);
    end
end

[numbGrid]=numel(gridX);
distX=zeros(1,numbGrid);
distY=zeros(1,numbGrid);
dist=zeros(1,numbGrid);
angle=zeros(1,numbGrid);

for i=1:(numbGrid-1)
    distX(i+1)=gridX(i+1)-gridX(i);
    distY(i+1)=gridY(i+1)-gridY(i);
    dist(i+1)=sqrt(distX(i+1)^2+distY(i+1)^2);
    angle(i+1)=atan2(distY(i+1),distX(i+1));
end

cumDist=cumsum(dist);
deltaX=xCSI(2)-xCSI(1);
samplePoints=min(cumDist):deltaX:max(cumDist);
[index]=knnsearch(cumDist',samplePoints');
desiredPoints=cumDist(index);
desiredX=gridX(index);
desiredY=gridY(index);
desiredAngle=angle(index);
indexStart=knnsearch(desiredX',startX);
updatedX=desiredX;
updatedY=desiredY;
numbCSI=numel(xCSI);
updatedX(indexStart:(indexStart+numbCSI-1))=desiredX(indexStart:...
    (indexStart+numbCSI-1))+yCSI.*abs(sin(desiredAngle(indexStart:(indexStart...
    +numbCSI-1))));
updatedY(indexStart:(indexStart+numbCSI-1))=desiredY(indexStart:...
    (indexStart+numbCSI-1))+yCSI.*abs(cos(desiredAngle(indexStart:(indexStart...
    +numbCSI-1))));

figure;
plot(orgShore(:,1),orgShore(:,2));
hold on;
plot(updatedX,updatedY);
scatter(updatedX(indexStart),updatedY(indexStart));
scatter(updatedX(indexStart+numbCSI-1),updatedY(indexStart+numbCSI-1));
ax=gca;
ax.FontName='Calibri';
ax.FontSize=25;
legend('Original','CSI Result','Start Point','End Point');
grid on;
axis equal;

if saveDoc==1
    docWrite(:,1)=updatedX;
    docWrite(:,2)=updatedY;
    dlmwrite(outputFileName,docWrite,'delimiter',...
        ',','precision','%.10f');
end

toc;