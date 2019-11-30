%% extract information from the name
function times=read_protocol(protocol)
%     index=strfind(genotype,'@');
    
    %Let the genotype be: Basin4@UAS_Chrimson@t94@r_LED100_45s2x30s30s#n#n#n@100
        %Genotype must be in the format above
        
    %driver: Basin4
    %effector: UAS_Chrimson
    %tracker: t94
    %protocol: r_LED100_45s2x30s30s#n#n#n
%     driver=genotype(1:index(1)-1);
%     effector=genotype(index(1)+1:index(2)-1);
%     tracker=genotype(index(2)+1:index(3)-1);
%     protocol=genotype(index(3)+1:index(4)-1);

    sindex=strfind(protocol,'s');
    tindex=strfind(protocol,'x');
    waiting=str2double(protocol(sindex(1)-2:sindex(1)-1));
    circles=str2double(protocol(sindex(1)+1:tindex(1)-1));
    if strcmp(protocol(tindex(1)+1:sindex(2)-1),'05')==1
        stimdur=0.5;
        stimint=30.5;
    else
        stimdur=str2double(protocol(tindex(1)+1:sindex(2)-1));
        stimint=str2double(protocol(sindex(2)+1:sindex(3)-1));
    end
    
    %waiting: 45
    %circles: 2
    %stimdur: 30
    %stimint: 30
    times=[];
    times.waiting=waiting;
    times.circles=circles;
    times.stimdur=stimdur;
    times.stimint=stimint;
end