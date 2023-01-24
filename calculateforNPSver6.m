function [pulses]=calculateforNPSver6(indices,ym,yasls,samplerate,N,Length,Deff,szlength,sqlength,hchannel,baseymatrix,pulses,recovavg,stderror,numpul,info,numsq)
%indices should be matrix with 2+numsq*2 columns: 1=start sz 2=endsz 3=start sq1 4=
%end sq1... etc. 

%%pulses columns: 1) filename, 2) sizing start, 3) size end, 4) Iavg sz, 5)
%Iavgbaseline, 6)diameter, 7)uflow (sizing), 8) sqstart1, 9) sqend1, 10-13)
%same as 8,9 but for sq2,3, 14-16) vratio1-3, 17-19) strain1-3, 20) tau,
%21) Rsquared, 22) numpast sizing, 23) pressure, 24) geometry, 25) device
%num, 26) voltage, 27) dinput 
[m,~]=size(indices);
pulsesforprint=num2cell(pulses);
sizeptsexist=0;
sqorder=zeros(1,3);
        switch info(1,2) 
            case 789
                sqorder=[7 8 9];
            case 978
                sqorder=[9 7 8]; 
            case 897 
                sqorder=[8 9 7]; 
            case 987
                sqorder=[9 8 7];
            case 14
                sqorder=zeros(1,3);
        end
for i=1:m 
   
    if indices(i,1) ~=0 && indices(i,2) ~=0 %are there sizing points recorded (this shoudl always be true) 
      
        if pulses(i,20)~=0 %are there recovery pulses 
            startpulse=indices(i,1)-100;
            endpulse=indices(i,numpul*2)+100;
            relevantlength=endpulse-startpulse+1;
            baseline=baseymatrix(1:relevantlength,i);
            relevantsz=indices(i,2)-indices(i,1);
            pulses(i,5)=mean(baseline(101:relevantsz+101));%Ibaseline
        else %no recovery recorded
            pulses(i,5)=mean(yasls(indices(i,1):indices(i,2),1));%Ibaseline
        end
        sizeptsexist=1;
        szstart=indices(i,1);
        szend=indices(i,2);
        pulses(i,2)=szstart;
        pulses(i,3)=szend;
        pulses(i,4)=mean(ym(szstart:szend,1));%Ipore
        deltaI=pulses(i,5)-pulses(i,4);
        deltaIoverI=deltaI/pulses(i,5);%deltaI/I
        dtop=deltaIoverI*Length*(Deff^2);
        dbottom=1+(0.8*deltaIoverI*Length/Deff);
        pulses(i,6)=(dtop/dbottom)^(1/3); %calculated cell diameter
        deltaT=(szend-szstart)*N/samplerate;
        pulses(i,7)=szlength/deltaT; %flowspeed
        
        % calculate strain in each sq channel--> this assummes 3 squeeze
        % channels 
        if sqorder(1,1)~=0
            pulses(i,17:19)=(pulses(i,6)-sqorder)/pulses(i,6);
        end
        
    end
    
    %calculate vratios:
        %sq 1
        if indices(i,3) ~=0 && indices(i,4)~=0 % is sq 1 is recorded
            sqstart=indices(i,3);
            sqend=indices(i,4);
            pulses(i,8)=sqstart;
            pulses(i,9)=sqend;
            deltaTsq=(sqend-sqstart)*N/samplerate; 
            vsq=sqlength/deltaTsq;
            if sizeptsexist==1
                pulses(i,14)=vsq/pulses(i,7); %vratio1
            end
        end
        %sq 2
        if numsq>2
            if indices(i,5) ~=0 && indices(i,6)~=0 % is sq 2 is recorded
                sqstart=indices(i,5);
                sqend=indices(i,6);
                pulses(i,10)=sqstart;
                pulses(i,11)=sqend;
                deltaTsq=(sqend-sqstart)*N/samplerate; 
                vsq=sqlength/deltaTsq;
                if sizeptsexist==1
                    pulses(i,15)=vsq/pulses(i,7); %vratio2
                end
            end
            %sq 3
            if indices(i,7) ~=0 && indices(i,8)~=0 % is sq 3 is recorded
                sqstart=indices(i,7);
                sqend=indices(i,8);
                pulses(i,12)=sqstart;
                pulses(i,13)=sqend;
                deltaTsq=(sqend-sqstart)*N/samplerate; 
                vsq=sqlength/deltaTsq;
                if sizeptsexist==1
                    pulses(i,16)=vsq/pulses(i,7); %vratio3
                end
            end
        end
    
    
%     if pulses(i,20)~=0
%         %when do the recovery segments cross below the sizing drop
%         j=1;
%         while j<10
%             if recovavg(i,j)<=-deltaI && recovavg(i,j+1)-stderror<=-deltaI
%                 pulses(i,13)=j;
%                 j=11;
%             else
%                 j=j+1;
%             end
%             if j==10 
%                 pulses(i,13)=11;
%             end
%         end
%     end
    sizeptsexist=0;

end