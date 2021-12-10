function [DataRev] = COMfunction(DataSend)
%%
%About this function
% This fuction transfers and receives commands with CCU board.
% any change and copy of the connect is not permited.
%Made by Afshin
%%
%DataSend will be a structure containing the following information
%             DataSend.COM
%             DataSend.VNN                  % Voltage settings
%             DataSend.VPP                  % Voltage settings
%             DataSend.BiasPatern  
%             DataSend.VNNc                 % current max settings
%             DataSend.VPPc                 % current max settings
%             DataSend.Trigger1             % 0 ~ 1 
%             DataSend.Trigger2             % 0 ~ 1 
%             DataSend.TrOd                 %delay for triggerout
%             DataSend.ImgMode             
%             DataSend.Qswitch              % laser Qswitch
%             DataSend.delay2.En
%             DataSend.delay2.IniD          % delay
%             DataSend.delay2.lengthD       % active time
%             DataSend.delay2.Inv           % invert logic
%             DataSend.delay3.En
%             DataSend.delay3.IniD          % delay
%             DataSend.delay3.lengthD       % active time
%             DataSend.delay3.Inv           % invert logic
%             DataSend.delay4.En
%             DataSend.delay4.IniD          % delay
%             DataSend.delay4.lengthD       % active time
%             DataSend.delay4.Inv           % invert logic
%             DataSend.Operation            %1 setup, 0 update
%             DataSend.STOP                 % 0 or 1 
%             DataSend.intiation            % 0 or 1 
%             DataSend.VoltageTolerance=5;
%             DataSend.TimerInterval=5;
%%

%**************************************************************************
%Package calculations for transfer:
%There are three type of the packages
% sequence packages which every sequence will be coded into two packages, A
% and B
% CCU command packages which will be coded into 1 single package and will
% be transfered into CCU
% Update package, chich will be only transfered during imaging for updating
% GUI
%**************************************************************************
%%
COMPORT=DataSend.COM;  
%Find the COM port
if DataSend.intiation==1;  
    doublecheckport=find(ismember(seriallist, COMPORT));
    if isempty(doublecheckport)
        fprintf('This message is sent at time %s\n', datestr(now,'HH:MM:SS.FFF'))
        display(['***************************************************']);
        display(['*                Error 404                        *']); 
        display(['*                                                 *']); 
        display(['*    CCU not found! Check USB connection          *']); 
        display(['***************************************************']);
        DataRev.COM= 'NONO';
        DataRev.VNNen = 0;    % VNN enable   
        DataRev.VPPen = 0;    % VPP enable 

        DataRev.VNNac=0;      %VNN PS active
        DataRev.VPPav=0;      %VPP PS active

        DataRev.VNNccu = 0; % VNN read by CCU
        DataRev.VPPccu = 0; % VPP read by CCU

        DataRev.Card1Con=0;   %Card 1 connect status
        DataRev.Card2Con=0;   %Card 2 connect status
        DataRev.Card3Con=0;   %Card 3 connect status
        DataRev.Card4Con=0;   %Card 4 connect status


        DataRev.VNNc1 = 0; % VNN read by Card1
        DataRev.VPPc1 = 0; % VPP read by Card1
        DataRev.VNNc2 = 0; % VNN read by Card2
        DataRev.VPPc2 = 0; % VPP read by Card2
        DataRev.VNNc3 = 0; % VNN read by Card3
        DataRev.VPPc3 = 0; % VPP read by Card3
        DataRev.VNNc4 = 0; % VNN read by Card4
        DataRev.VPPc4 = 0; % VPP read by Card4

        DataRev.CurrentSeq = 0; % current imaging sequence
        DataRev.Delay1=0;
        DataRev.Delay2=0;
        DataRev.Delay3=0;
        DataRev.Delay4=0;
        DataRev.Trigger1=0;
        DataRev.Trigger2=0;
        DataRev.intiation=0;
        DataRev.intiation=0;
        DataRev.STOP=1;
DataRev.Operation=0;
        return;
    end
end
%%
if DataSend.intiation==0
	port=0;    
    doublecheckport=find(ismember(seriallist, COMPORT));
    
    if isempty(doublecheckport)
    
        display(['***************************************************']);
        fprintf('*    This message is sent at time %s    *\n', datestr(now,'HH:MM:SS.FFF'))
        display(['*                                                 *']);
        display(['*                Error 404                        *']); 
        display(['*                                                 *']);
        display(['*    CCU not found! Check USB connection          *']); 
        display(['***************************************************']);
        clear s;
        DataRev.COM= 'NONO';
        DataRev.VNNen = 0;    % VNN enable   
        DataRev.VPPen = 0;    % VPP enable 
        DataRev.VNNac=0;      %VNN PS active
        DataRev.VPPav=0;      %VPP PS active
        DataRev.VNNccu = 0; % VNN read by CCU
        DataRev.VPPccu = 0; % VPP read by CCU
        DataRev.Card1Con=0;   %Card 1 connect status
        DataRev.Card2Con=0;   %Card 2 connect status
        DataRev.Card3Con=0;   %Card 3 connect status
        DataRev.Card4Con=0;   %Card 4 connect status
        DataRev.VNNc1 = 0; % VNN read by Card1
        DataRev.VPPc1 = 0; % VPP read by Card1
        DataRev.VNNc2 = 0; % VNN read by Card2
        DataRev.VPPc2 = 0; % VPP read by Card2
        DataRev.VNNc3 = 0; % VNN read by Card3
        DataRev.VPPc3 = 0; % VPP read by Card3
        DataRev.VNNc4 = 0; % VNN read by Card4
        DataRev.VPPc4 = 0; % VPP read by Card4
        DataRev.CurrentSeq = 0; % current imaging sequence
        DataRev.Delay1=0;
        DataRev.Delay2=0;
        DataRev.Delay3=0;
        DataRev.Delay4=0;
        DataRev.Trigger1=0;
        DataRev.Trigger2=0;
        DataRev.intiation=0;
        DataRev.intiation=0;
        DataRev.STOP=1;
DataRev.Operation=0;
        return;
    
    else  %% we have board on the port!
        s = serial(COMPORT);  % Open the port
        s.BaudRate = 9600;
        newobjs = instrfind;
        fclose(newobjs)
        fopen(s);
        fwrite(s,'6ziieuJlUe7kamhNa4shpRfgzCbjB7Tvw0DAidJ1fG9dQgRP87WnO2rbuslTn2e2');
        pause(0.5);
        A= s.BytesAvailable;
        if A~=0
            data=convertCharsToStrings(char(fread(s,A)));
            if data =="6ettuJlUe7kamhNa4shpRfgzCbjB7ery0DAidJ1fG9dQgRP87WnO2rcarlTn2eo2" 
            port=1;
            clear s;
           
            display(['***************************************************']);
            fprintf('*    This message is sent at time %s    *\n', datestr(now,'HH:MM:SS.FFF'))
            display(['*                                                 *']); 
            display(['*                                                 *']); 
            display(['*                Connection OK                    *']); 
            display(['***************************************************']);
            
            end
        end
    end
    if port == 0  %if nothing didn't found, get out of the function.
        
        display(['***************************************************']);
        fprintf('*    This message is sent at time %s    *\n', datestr(now,'HH:MM:SS.FFF'))
        display(['*                                                 *']);
        display(['*                Error 404                        *']); 
        display(['*                                                 *']);
        display(['*    CCU not found! Check USB connection          *']); 
        display(['***************************************************']);

        clear s;
        DataRev.COM= 'NONO';
        DataRev.VNNen = 0;    % VNN enable   
        DataRev.VPPen = 0;    % VPP enable 
        DataRev.VNNac=0;      %VNN PS active
        DataRev.VPPav=0;      %VPP PS active
        DataRev.VNNccu = 0; % VNN read by CCU
        DataRev.VPPccu = 0; % VPP read by CCU
        DataRev.Card1Con=0;   %Card 1 connect status
        DataRev.Card2Con=0;   %Card 2 connect status
        DataRev.Card3Con=0;   %Card 3 connect status
        DataRev.Card4Con=0;   %Card 4 connect status
        DataRev.VNNc1 = 0; % VNN read by Card1
        DataRev.VPPc1 = 0; % VPP read by Card1
        DataRev.VNNc2 = 0; % VNN read by Card2
        DataRev.VPPc2 = 0; % VPP read by Card2
        DataRev.VNNc3 = 0; % VNN read by Card3
        DataRev.VPPc3 = 0; % VPP read by Card3
        DataRev.VNNc4 = 0; % VNN read by Card4
        DataRev.VPPc4 = 0; % VPP read by Card4
        DataRev.CurrentSeq = 0; % current imaging sequence
        DataRev.Delay1=0;
        DataRev.Delay2=0;
        DataRev.Delay3=0;
        DataRev.Delay4=0;
        DataRev.Trigger1=0;
        DataRev.Trigger2=0;
        DataRev.intiation=0;
        DataRev.intiation=0;
DataRev.Operation=0;
DataRev.STOP=1;
        return;
    end
end
%%
if DataSend.intiation==0
%Step 1 bias pattern generation and transfer
%for this step every sequence will be devided to two packets,
%packet A will include channels from 1 to 127 (126 channels)
%packet B will include channels from 128 to 256 (128 channels)
% Every byte in packes will include 3 channel setting as following
% MSB                             LSB
% [ 1 1 Ch1a Ch1b Ch2a Ch2b Ch3a Ch3b]
%pckat will be formed as bellow
%Hi bytes(64)                                                 low byte (1)
%[S E Q U E N C E - Frame#2 Frame#1 **********  43 bytes for the channels]
    pattern = DataSend.BiasPatern ;
    patternsize = size(pattern) ; %patternsize(1) is sequence, patternsize(2) is channels

    if patternsize(2)~= 256
        display(['*************************************************************']);
        fprintf('*        This message is sent at time %s          *\n', datestr(now,'HH:MM:SS.FFF'))
        display(['*                                                           *']);
        display('*                       CCU ERROR 101                       *')
        display(['*                                                           *']);
        display('*    All 256 channels must be programmed. Process Stopped   *')
        display('*************************************************************')
        newobjs = instrfind;
        fclose(newobjs)
        DataRev.COM= 'NONO';
         DataRev.VNNen = 0;    % VNN enable   
 DataRev.VPPen = 0;    % VPP enable 

 DataRev.VNNac=0;      %VNN PS active
 DataRev.VPPav=0;      %VPP PS active

DataRev.VNNccu = 0; % VNN read by CCU
DataRev.VPPccu = 0; % VPP read by CCU

DataRev.Card1Con=0;   %Card 1 connect status
DataRev.Card2Con=0;   %Card 2 connect status
DataRev.Card3Con=0;   %Card 3 connect status
DataRev.Card4Con=0;   %Card 4 connect status


DataRev.VNNc1 = 0; % VNN read by Card1
DataRev.VPPc1 = 0; % VPP read by Card1
DataRev.VNNc2 = 0; % VNN read by Card2
DataRev.VPPc2 = 0; % VPP read by Card2
DataRev.VNNc3 = 0; % VNN read by Card3
DataRev.VPPc3 = 0; % VPP read by Card3
DataRev.VNNc4 = 0; % VNN read by Card4
DataRev.VPPc4 = 0; % VPP read by Card4

DataRev.CurrentSeq = 0; % current imaging sequence
DataRev.Delay1=0;
DataRev.Delay2=0;
DataRev.Delay3=0;
DataRev.Delay4=0;
DataRev.Trigger1=0;
DataRev.Trigger2=0;
DataRev.intiation=0;
DataRev.intiation=0;
DataRev.Operation=0;
DataRev.STOP=1;
close all force ;
        return
    end
maxSeq=patternsize(1);
    if maxSeq> 512
        display(['*******************************************************************']);
        fprintf('*           This message is sent at time %s             *\n', datestr(now,'HH:MM:SS.FFF'))
        display(['*                                                                 *']);
        display('*                         CCU ERROR 102                           *')
        display(['*                                                                 *']);
        display('*    Maximum number of the sequences are 512. Process Stopped    *')
        display('*******************************************************************')
        newobjs = instrfind;
        fclose(newobjs)
        DataRev.COM= 'NONO';
                 DataRev.VNNen = 0;    % VNN enable   
 DataRev.VPPen = 0;    % VPP enable 

 DataRev.VNNac=0;      %VNN PS active
 DataRev.VPPav=0;      %VPP PS active

DataRev.VNNccu = 0; % VNN read by CCU
DataRev.VPPccu = 0; % VPP read by CCU

DataRev.Card1Con=0;   %Card 1 connect status
DataRev.Card2Con=0;   %Card 2 connect status
DataRev.Card3Con=0;   %Card 3 connect status
DataRev.Card4Con=0;   %Card 4 connect status


DataRev.VNNc1 = 0; % VNN read by Card1
DataRev.VPPc1 = 0; % VPP read by Card1
DataRev.VNNc2 = 0; % VNN read by Card2
DataRev.VPPc2 = 0; % VPP read by Card2
DataRev.VNNc3 = 0; % VNN read by Card3
DataRev.VPPc3 = 0; % VPP read by Card3
DataRev.VNNc4 = 0; % VNN read by Card4
DataRev.VPPc4 = 0; % VPP read by Card4

DataRev.CurrentSeq = 0; % current imaging sequence
DataRev.Delay1=0;
DataRev.Delay2=0;
DataRev.Delay3=0;
DataRev.Delay4=0;
DataRev.Trigger1=0;
DataRev.Trigger2=0;
DataRev.intiation=0;
DataRev.intiation=0;
DataRev.Operation=0;
DataRev.STOP=1;
close all force ;
        return
    end
 %%
 patternsize = size(pattern);
 maxSeq=patternsize(1);
 TrasPack(1:4*maxSeq,1:64)=128;
 
 SeqCount=0;
 for P=1:maxSeq
     TrasPack(P,1:10)=double('SEQUENCE-A');  %contins channels 1 to 64
     
     SeqCount=SeqCount+1;
     if SeqCount>999
        TrasPack(P,12:15)=double(num2str(SeqCount));
       
    elseif SeqCount>99
        TrasPack(P,12)=double('0');    
        TrasPack(P,13:15)=double(num2str(SeqCount));       
    elseif SeqCount>9
        TrasPack(P,12:13)=double('00');    
        TrasPack(P,14:15)=double(num2str(SeqCount));
    else
        TrasPack(P,12:14)=double('000');    
        TrasPack(P,15)=double(num2str(SeqCount));  
    end
     
     
     
 end 
 SeqCount=0;
 for P=maxSeq+1:maxSeq*2
     TrasPack(P,1:10)=double('SEQUENCE-B'); % contains channels 65 to128
     
     SeqCount=SeqCount+1;
     if SeqCount>999
        TrasPack(P,12:15)=double(num2str(SeqCount));
       
    elseif SeqCount>99
        TrasPack(P,12)=double('0');    
        TrasPack(P,13:15)=double(num2str(SeqCount));       
    elseif SeqCount>9
        TrasPack(P,12:13)=double('00');    
        TrasPack(P,14:15)=double(num2str(SeqCount));
    else
        TrasPack(P,12:14)=double('000');    
        TrasPack(P,15)=double(num2str(SeqCount));  
     end
    
     
 end
 
 SeqCount=0;
 for P=(maxSeq*2+1):maxSeq*3
     TrasPack(P,1:10)=double('SEQUENCE-C'); % 129 to 192
     
     SeqCount=SeqCount+1;
     if SeqCount>999
        TrasPack(P,12:15)=double(num2str(SeqCount));
       
    elseif SeqCount>99
        TrasPack(P,12)=double('0');    
        TrasPack(P,13:15)=double(num2str(SeqCount));       
    elseif SeqCount>9
        TrasPack(P,12:13)=double('00');    
        TrasPack(P,14:15)=double(num2str(SeqCount));
    else
        TrasPack(P,12:14)=double('000');    
        TrasPack(P,15)=double(num2str(SeqCount));  
     end
    
 end
 
 SeqCount=0;
 for P=(maxSeq*3+1):maxSeq*4
     TrasPack(P,1:10)=double('SEQUENCE-D');% 193 to 256
     
     SeqCount=SeqCount+1;
     if SeqCount>999
        TrasPack(P,12:15)=double(num2str(SeqCount));
       
    elseif SeqCount>99
        TrasPack(P,12)=double('0');    
        TrasPack(P,13:15)=double(num2str(SeqCount));       
    elseif SeqCount>9
        TrasPack(P,12:13)=double('00');    
        TrasPack(P,14:15)=double(num2str(SeqCount));
    else
        TrasPack(P,12:14)=double('000');    
        TrasPack(P,15)=double(num2str(SeqCount));  
    end
 end
 
%place maxSeq on all of them!
for P=1:4*maxSeq
   if maxSeq>999
        TrasPack(P,16:19)=double(num2str(maxSeq));
    elseif maxSeq>99
        TrasPack(P,16)=double('0');    
        TrasPack(P,17:19)=double(num2str(maxSeq));      
    elseif maxSeq>9
        TrasPack(P,16:17)=double('00');    
        TrasPack(P,18:19)=double(num2str(maxSeq));
    else
        TrasPack(P,16:18)=double('000');    
        TrasPack(P,19)=double(num2str(maxSeq));  
   end
    if P>999
        TrasPack(P,60:63)=double(num2str(P));
    elseif P>99
        TrasPack(P,60)=double('0');    
        TrasPack(P,61:63)=double(num2str(P));      
    elseif P>9
        TrasPack(P,60:61)=double('00');    
        TrasPack(P,62:63)=double(num2str(P));
    else
        TrasPack(P,60:62)=double('000');    
        TrasPack(P,63)=double(num2str(P));  
    end 
   
   
   
end
 
%loop 1  calculating the channels 1 to 64!
BitStream(1:maxSeq,1:64)=zeros(maxSeq,64); %creat a copy of stream
BitStream(1:maxSeq,1:64)=pattern(1:maxSeq,1:64);
SeqCount=0;
for P=1:maxSeq
    SeqCount=SeqCount+1;
for Ch=1:64
    bytenum = ceil(Ch/2)+19;  %we will use bytes from 20 t0 52 (32 bytes!)
    value = BitStream(SeqCount,Ch);
        if value==-1
            value = 2;
            elseif value==0
            value = 3;
            elseif value == 1
            value = 1;
            else
            value = 0;
        end
        if floor(Ch/2)==Ch/2
          value=value*4;
        end
         TrasPack(P,bytenum)=TrasPack(P,bytenum)+value;  
end 
end
%loop 2  calculating the channels 65 to 128!
BitStream(1:maxSeq,1:64)=zeros(maxSeq,64); %creat a copy of stream
BitStream(1:maxSeq,1:64)=pattern(1:maxSeq,65:128);
SeqCount=0;
for P=maxSeq+1:maxSeq*2
    SeqCount=SeqCount+1;
for Ch=1:64
    bytenum = ceil(Ch/2)+19;  %we will use bytes from 20 t0 52 (32 bytes!)
    value = BitStream(SeqCount,Ch);
        if value==-1
            value = 2;
            elseif value==0
            value = 3;
            elseif value == 1
            value = 1;
            else
            value = 0;
        end
        if floor(Ch/2)==Ch/2
          value=value*4;
        end
         TrasPack(P,bytenum)=TrasPack(P,bytenum)+value;  
end 
end
%loop 3  calculating the channels 129 to 192!
BitStream(1:maxSeq,1:64)=zeros(maxSeq,64); %creat a copy of stream
BitStream(1:maxSeq,1:64)=pattern(1:maxSeq,129:192);
SeqCount=0;
for P=(maxSeq*2+1):maxSeq*3
    SeqCount=SeqCount+1;
for Ch=1:64
    bytenum = ceil(Ch/2)+19;  %we will use bytes from 20 t0 52 (32 bytes!)
    value = BitStream(SeqCount,Ch);
        if value==-1
            value = 2;
            elseif value==0
            value = 3;
            elseif value == 1
            value = 1;
            else
            value = 0;
        end
        if floor(Ch/2)==Ch/2
          value=value*4;
        end
         TrasPack(P,bytenum)=TrasPack(P,bytenum)+value;  
end 
end
%loop 1  calculating the channels 193 to 256!
BitStream(1:maxSeq,1:64)=zeros(maxSeq,64); %creat a copy of stream
BitStream(1:maxSeq,1:64)=pattern(1:maxSeq,193:256);
SeqCount=0;
for P=(maxSeq*3+1):maxSeq*4
    SeqCount=SeqCount+1;
for Ch=1:64
    bytenum = ceil(Ch/2)+19;  %we will use bytes from 20 t0 52 (32 bytes!)
    value = BitStream(SeqCount,Ch);
        if value==-1
            value = 2;
            elseif value==0
            value = 3;
            elseif value == 1
            value = 1;
            else
            value = 0;
        end
        if floor(Ch/2)==Ch/2
          value=value*4;
        end
         TrasPack(P,bytenum)=TrasPack(P,bytenum)+value;  
end 
end

%%
%Step 2 forming the commands for CCU itself

% first 3 bytes will be CCU  indicating that they are for CCU it self
% Byte 4     VNN
% Byte 5     VPP
% Byte 6~8   VPPc
% Byte 9~11   VNNc
% Byte 12    1 0  Tr1 Tr2 imgMd STOP intiation Operation
% Byte 13~16 TrOd
% Byte 17~19 Qswitch
% Byte 20    1 0 Dly2En Dly2Inv 0 0 0 0
% Byte 21~24 Dly2IniD
% Byte 25~28 Dly2lengthD
% Byte 29    1 0 Dly3En Dly3Inv 0 0 0 0
% Byte 30~33 Dly3IniD
% Byte 34~37 Dly3lengthD
% Byte 38    1 0 Dly4En Dly4Inv 0 0 0 0
% Byte 39~42 Dly4IniD
% Byte 43~46 Dly4lengthD
% Byte 47    VoltageTolerance
% Byte 48~64 128
    commandnumber=patternsize(1)*4+1;
    TrasPack(commandnumber,1:3)=double('CCU');
    TrasPack(commandnumber,4)=abs(DataSend.VNN+1);  % we can't send zero, we will deduct 1 in other end
    TrasPack(commandnumber,5)=DataSend.VPP+1;  % we can't send zero, we will deduct 1 in other end

    TrasPack(commandnumber,6:8)=double(num2str(DataSend.VPPc));
    TrasPack(commandnumber,9:11)=double(num2str(DataSend.VNNc));

    if DataSend.Operation ==1
        TrasPack(commandnumber,12)=TrasPack(commandnumber,12)+1;
    end
    if DataSend.intiation ==1
        TrasPack(commandnumber,12)=TrasPack(commandnumber,12)+2;
    end
    if DataSend.STOP ==1
        TrasPack(commandnumber,12)=TrasPack(commandnumber,12)+4;
    end
    if DataSend.ImgMode =='PA'
        TrasPack(commandnumber,12)=TrasPack(commandnumber,12)+8;
    end
    if DataSend.Trigger2 ==1
        TrasPack(commandnumber,12)=TrasPack(commandnumber,12)+16;
    end
    if DataSend.Trigger1 ==1
        TrasPack(commandnumber,12)=TrasPack(commandnumber,12)+32;
    end
    if DataSend.TrOd>999
        TrasPack(commandnumber,13:16)=double(num2str(DataSend.TrOd));
    elseif DataSend.TrOd>99
        TrasPack(commandnumber,13)=double(num2str(0));    
        TrasPack(commandnumber,14:16)=double(num2str(DataSend.TrOd));
    elseif DataSend.TrOd>9
        TrasPack(commandnumber,13:14)=double(num2str(0));    
        TrasPack(commandnumber,15:16)=double(num2str(DataSend.TrOd));
    else
        TrasPack(commandnumber,13:15)=double(num2str(0));    
        TrasPack(commandnumber,16)=double(num2str(DataSend.TrOd));  
    end
        TrasPack(commandnumber,17:19)=double(num2str(DataSend.Qswitch)); 

    %delay 2
    if DataSend.delay2.En ==1
        TrasPack(commandnumber,20)=TrasPack(commandnumber,20)+32;
    end
    if DataSend.delay2.Inv ==1
        TrasPack(commandnumber,20)=TrasPack(commandnumber,20)+16;
    end
    if DataSend.delay2.IniD>999
        TrasPack(commandnumber,21:24)=double(num2str(DataSend.delay2.IniD));
    elseif DataSend.delay2.IniD>99
        TrasPack(commandnumber,21)=double(num2str(0));    
        TrasPack(commandnumber,22:24)=double(num2str(DataSend.delay2.IniD));
    elseif DataSend.delay2.IniD>9
        TrasPack(commandnumber,21:22)=double(num2str(0));    
        TrasPack(commandnumber,23:24)=double(num2str(DataSend.delay2.IniD));
    else
        TrasPack(commandnumber,21:23)=double(num2str(0));    
        TrasPack(commandnumber,24)=double(num2str(DataSend.delay2.IniD));  
    end

    if DataSend.delay2.lengthD>999
        TrasPack(commandnumber,25:28)=double(num2str(DataSend.delay2.lengthD));
    elseif DataSend.delay2.lengthD>99
        TrasPack(commandnumber,25)=double(num2str(0));    
        TrasPack(commandnumber,26:28)=double(num2str(DataSend.delay2.lengthD));
    elseif DataSend.delay2.lengthD>9
        TrasPack(commandnumber,25:26)=double(num2str(0));    
        TrasPack(commandnumber,27:28)=double(num2str(DataSend.delay2.lengthD));
    else
        TrasPack(commandnumber,25:27)=double(num2str(0));    
        TrasPack(commandnumber,28)=double(num2str(DataSend.delay2.lengthD));  
    end

    %delay 3
    if DataSend.delay3.En ==1
        TrasPack(commandnumber,29)=TrasPack(commandnumber,29)+32;
    end
    if DataSend.delay3.Inv ==1
        TrasPack(commandnumber,29)=TrasPack(commandnumber,29)+16;
    end
    if DataSend.delay3.IniD>999
        TrasPack(commandnumber,30:33)=double(num2str(DataSend.delay3.IniD));
    elseif DataSend.delay3.IniD>99
        TrasPack(commandnumber,30)=double(num2str(0));    
        TrasPack(commandnumber,31:33)=double(num2str(DataSend.delay3.IniD));
    elseif DataSend.delay3.IniD>9
        TrasPack(commandnumber,30:31)=double(num2str(0));    
        TrasPack(commandnumber,32:33)=double(num2str(DataSend.delay3.IniD));
    else
        TrasPack(commandnumber,30:32)=double(num2str(0));    
        TrasPack(commandnumber,33)=double(num2str(DataSend.delay3.IniD));  
    end

    if DataSend.delay3.lengthD>999
        TrasPack(commandnumber,34:37)=double(num2str(DataSend.delay3.lengthD));
    elseif DataSend.delay3.lengthD>99
        TrasPack(commandnumber,34)=double(num2str(0));    
        TrasPack(commandnumber,35:37)=double(num2str(DataSend.delay3.lengthD));
    elseif DataSend.delay3.lengthD>9
        TrasPack(commandnumber,34:35)=double(num2str(0));    
        TrasPack(commandnumber,36:37)=double(num2str(DataSend.delay3.lengthD));
    else
        TrasPack(commandnumber,34:36)=double(num2str(0));    
        TrasPack(commandnumber,37)=double(num2str(DataSend.delay3.lengthD));  
    end

    %delay 4
    if DataSend.delay4.En ==1
        TrasPack(commandnumber,38)=TrasPack(commandnumber,38)+32;
    end
    if DataSend.delay4.Inv ==1
        TrasPack(commandnumber,38)=TrasPack(commandnumber,38)+16;
    end
    if DataSend.delay4.IniD>999
        TrasPack(commandnumber,39:42)=double(num2str(DataSend.delay4.IniD));
    elseif DataSend.delay4.IniD>99
        TrasPack(commandnumber,39)=double(num2str(0));    
        TrasPack(commandnumber,40:42)=double(num2str(DataSend.delay4.IniD));
    elseif DataSend.delay4.IniD>9
        TrasPack(commandnumber,39:40)=double(num2str(0));    
        TrasPack(commandnumber,41:42)=double(num2str(DataSend.delay4.IniD));
    else
        TrasPack(commandnumber,39:41)=double(num2str(0));    
        TrasPack(commandnumber,42)=double(num2str(DataSend.delay4.IniD));  
    end

    if DataSend.delay4.lengthD>999
        TrasPack(commandnumber,43:46)=double(num2str(DataSend.delay4.lengthD));
    elseif DataSend.delay4.lengthD>99
        TrasPack(commandnumber,43)=double(num2str(0));    
        TrasPack(commandnumber,44:46)=double(num2str(DataSend.delay4.lengthD));
    elseif DataSend.delay4.lengthD>9
        TrasPack(commandnumber,43:44)=double(num2str(0));    
        TrasPack(commandnumber,45:46)=double(num2str(DataSend.delay4.lengthD));
    else
        TrasPack(commandnumber,43:45)=double(num2str(0));    
        TrasPack(commandnumber,46)=double(num2str(DataSend.delay4.lengthD));  
    end
        TrasPack(commandnumber,47)=DataSend.VoltageTolerance; 
         
%%
%*************************************************************************
TransferTime= floor(0.15 * patternsize(1));

     display(['Card Programming in progress']);
     display(['Board initilization can take up to ' num2str(TransferTime) ' seconds']);
 textprogressbar('Transferring packages into CCU:');
    s = serial(COMPORT);  % Open the port
    s.BaudRate = 9600;
    newobjs = instrfind;
    fclose(newobjs)
    fopen(s);
    n=0;
    A=0;
    for i=1:patternsize(1)*4+1
        n=n+1;
        fwrite(s,TrasPack(n,:), 'uint8');
             while(1)
             A= s.BytesAvailable;
                 if A~=0
                     break
                 end
             end
        g(n,1:A)=fread(s,A);
        if g(n,1:64)~= TrasPack(n,:)
         n=n-1;
        end
        PersentValue=n/(patternsize(1)*4)*100;
        if PersentValue>100
            PersentValue=100;
        end
        textprogressbar(PersentValue);
    end

    textprogressbar(' done!');  
    s = serial(COMPORT);  % Open the port
    s.BaudRate = 9600;
     newobjs = instrfind;
     fclose(newobjs)
     fopen(s);
end
%%

if DataSend.Operation==1
    pattern = DataSend.BiasPatern ;
     patternsize = size(pattern) ;
    commandnumber=patternsize(1)*4+1;
    TrasPack(1:commandnumber,1:64)=0;
    TrasPack(commandnumber,1:3)=double('CCU');
    TrasPack(commandnumber,4)=abs(DataSend.VNN+1);  % we can't send zero, we will deduct 1 in other end
    TrasPack(commandnumber,5)=DataSend.VPP+1;  % we can't send zero, we will deduct 1 in other end

    TrasPack(commandnumber,6:8)=double(num2str(DataSend.VPPc));
    TrasPack(commandnumber,9:11)=double(num2str(DataSend.VNNc));

    if DataSend.Operation ==1
        TrasPack(commandnumber,12)=TrasPack(commandnumber,12)+1;
    end
    if DataSend.intiation ==1
        TrasPack(commandnumber,12)=TrasPack(commandnumber,12)+2;
    end
    if DataSend.STOP ==1
        TrasPack(commandnumber,12)=TrasPack(commandnumber,12)+4;
    end
    if DataSend.ImgMode =='PA'
        TrasPack(commandnumber,12)=TrasPack(commandnumber,12)+8;
    end
    if DataSend.Trigger2 ==1
        TrasPack(commandnumber,12)=TrasPack(commandnumber,12)+16;
    end
    if DataSend.Trigger1 ==1
        TrasPack(commandnumber,12)=TrasPack(commandnumber,12)+32;
    end
    if DataSend.TrOd>999
        TrasPack(commandnumber,13:16)=double(num2str(DataSend.TrOd));
    elseif DataSend.TrOd>99
        TrasPack(commandnumber,13)=double(num2str(0));    
        TrasPack(commandnumber,14:16)=double(num2str(DataSend.TrOd));
    elseif DataSend.TrOd>9
        TrasPack(commandnumber,13:14)=double(num2str(0));    
        TrasPack(commandnumber,15:16)=double(num2str(DataSend.TrOd));
    else
        TrasPack(commandnumber,13:15)=double(num2str(0));    
        TrasPack(commandnumber,16)=double(num2str(DataSend.TrOd));  
    end
        TrasPack(commandnumber,17:19)=double(num2str(DataSend.Qswitch)); 

    %delay 2
    if DataSend.delay2.En ==1
        TrasPack(commandnumber,20)=TrasPack(commandnumber,20)+32;
    end
    if DataSend.delay2.Inv ==1
        TrasPack(commandnumber,20)=TrasPack(commandnumber,20)+16;
    end
    if DataSend.delay2.IniD>999
        TrasPack(commandnumber,21:24)=double(num2str(DataSend.delay2.IniD));
    elseif DataSend.delay2.IniD>99
        TrasPack(commandnumber,21)=double(num2str(0));    
        TrasPack(commandnumber,22:24)=double(num2str(DataSend.delay2.IniD));
    elseif DataSend.delay2.IniD>9
        TrasPack(commandnumber,21:22)=double(num2str(0));    
        TrasPack(commandnumber,23:24)=double(num2str(DataSend.delay2.IniD));
    else
        TrasPack(commandnumber,21:23)=double(num2str(0));    
        TrasPack(commandnumber,24)=double(num2str(DataSend.delay2.IniD));  
    end

    if DataSend.delay2.lengthD>999
        TrasPack(commandnumber,25:28)=double(num2str(DataSend.delay2.lengthD));
    elseif DataSend.delay2.lengthD>99
        TrasPack(commandnumber,25)=double(num2str(0));    
        TrasPack(commandnumber,26:28)=double(num2str(DataSend.delay2.lengthD));
    elseif DataSend.delay2.lengthD>9
        TrasPack(commandnumber,25:26)=double(num2str(0));    
        TrasPack(commandnumber,27:28)=double(num2str(DataSend.delay2.lengthD));
    else
        TrasPack(commandnumber,25:27)=double(num2str(0));    
        TrasPack(commandnumber,28)=double(num2str(DataSend.delay2.lengthD));  
    end

    %delay 3
    if DataSend.delay3.En ==1
        TrasPack(commandnumber,29)=TrasPack(commandnumber,29)+32;
    end
    if DataSend.delay3.Inv ==1
        TrasPack(commandnumber,29)=TrasPack(commandnumber,29)+16;
    end
    if DataSend.delay3.IniD>999
        TrasPack(commandnumber,30:33)=double(num2str(DataSend.delay3.IniD));
    elseif DataSend.delay3.IniD>99
        TrasPack(commandnumber,30)=double(num2str(0));    
        TrasPack(commandnumber,31:33)=double(num2str(DataSend.delay3.IniD));
    elseif DataSend.delay3.IniD>9
        TrasPack(commandnumber,30:31)=double(num2str(0));    
        TrasPack(commandnumber,32:33)=double(num2str(DataSend.delay3.IniD));
    else
        TrasPack(commandnumber,30:32)=double(num2str(0));    
        TrasPack(commandnumber,33)=double(num2str(DataSend.delay3.IniD));  
    end

    if DataSend.delay3.lengthD>999
        TrasPack(commandnumber,34:37)=double(num2str(DataSend.delay3.lengthD));
    elseif DataSend.delay3.lengthD>99
        TrasPack(commandnumber,34)=double(num2str(0));    
        TrasPack(commandnumber,35:37)=double(num2str(DataSend.delay3.lengthD));
    elseif DataSend.delay3.lengthD>9
        TrasPack(commandnumber,34:35)=double(num2str(0));    
        TrasPack(commandnumber,36:37)=double(num2str(DataSend.delay3.lengthD));
    else
        TrasPack(commandnumber,34:36)=double(num2str(0));    
        TrasPack(commandnumber,37)=double(num2str(DataSend.delay3.lengthD));  
    end

    %delay 4
    if DataSend.delay4.En ==1
        TrasPack(commandnumber,38)=TrasPack(commandnumber,38)+32;
    end
    if DataSend.delay4.Inv ==1
        TrasPack(commandnumber,38)=TrasPack(commandnumber,38)+16;
    end
    if DataSend.delay4.IniD>999
        TrasPack(commandnumber,39:42)=double(num2str(DataSend.delay4.IniD));
    elseif DataSend.delay4.IniD>99
        TrasPack(commandnumber,39)=double(num2str(0));    
        TrasPack(commandnumber,40:42)=double(num2str(DataSend.delay4.IniD));
    elseif DataSend.delay4.IniD>9
        TrasPack(commandnumber,39:40)=double(num2str(0));    
        TrasPack(commandnumber,41:42)=double(num2str(DataSend.delay4.IniD));
    else
        TrasPack(commandnumber,39:41)=double(num2str(0));    
        TrasPack(commandnumber,42)=double(num2str(DataSend.delay4.IniD));  
    end

    if DataSend.delay4.lengthD>999
        TrasPack(commandnumber,43:46)=double(num2str(DataSend.delay4.lengthD));
    elseif DataSend.delay4.lengthD>99
        TrasPack(commandnumber,43)=double(num2str(0));    
        TrasPack(commandnumber,44:46)=double(num2str(DataSend.delay4.lengthD));
    elseif DataSend.delay4.lengthD>9
        TrasPack(commandnumber,43:44)=double(num2str(0));    
        TrasPack(commandnumber,45:46)=double(num2str(DataSend.delay4.lengthD));
    else
        TrasPack(commandnumber,43:45)=double(num2str(0));    
        TrasPack(commandnumber,46)=double(num2str(DataSend.delay4.lengthD));  
    end
        TrasPack(commandnumber,47)=DataSend.VoltageTolerance;     
    

    n=0;
    A=0;
s=DataSend.sending;
        n=patternsize(1)*4+1;
        fwrite(s,TrasPack(n,:), 'uint8');
             while(1)
             A= s.BytesAvailable;
                 if A~=0
                     break
                 end
             end
        g(n,1:A)=fread(s,A);

    display('CCU: High Voltage Power supplies reprogramming is in progress.'); 
    display('This process may take up to 15 seconds to take place!');
    DataRev.Operation=0;
end
%%
%Step 3, Updating GUI
TrasPack2(1:64)=48; % all info to be sent    <<< MUST be 128 for final code
TrasPack2(1:10)=double('UpdateComm');
TrasPack2(11)= TrasPack2(11)+DataSend.STOP;
TrasPack2(12)= TrasPack2(12)+DataSend.Operation;
TrasPack2(13)= TrasPack2(13)+DataSend.intiation;
TrasPack2(16)=DataSend.VPP+1;
TrasPack2(17)=abs(DataSend.VNN-1);
if DataSend.intiation==1
s=DataSend.sending;
end
     fwrite(s,TrasPack2(:), 'uint8');
     while(1)
     A= s.BytesAvailable;
     if A~=0
         break
     end
     end
     %clear g;
     g(1:A)=fread(s,A);
if g(1:10)~=TrasPack2(1:10)

            display(['***************************************************']);
            fprintf('*    This message is sent at time %s    *\n', datestr(now,'HH:MM:SS.FFF'))
            display(['*                                                 *']);
            display(['*                    EROR 104                     *']); 
            display(['*                                                 *']); 
            display(['*                Failed to update                 *']); 
            display(['***************************************************']);
%DataRev is an structure containing the following information
 DataRev.COM= COMPORT;
 DataRev.VNNen = 0;    % VNN enable   
 DataRev.VPPen = 0;    % VPP enable 

 DataRev.VNNac=0;      %VNN PS active
 DataRev.VPPav=0;      %VPP PS active

DataRev.VNNccu = 0; % VNN read by CCU
DataRev.VPPccu = 0; % VPP read by CCU

DataRev.Card1Con=0;   %Card 1 connect status
DataRev.Card2Con=0;   %Card 2 connect status
DataRev.Card3Con=0;   %Card 3 connect status
DataRev.Card4Con=0;   %Card 4 connect status


DataRev.VNNc1 = 0; % VNN read by Card1
DataRev.VPPc1 = 0; % VPP read by Card1
DataRev.VNNc2 = 0; % VNN read by Card2
DataRev.VPPc2 = 0; % VPP read by Card2
DataRev.VNNc3 = 0; % VNN read by Card3
DataRev.VPPc3 = 0; % VPP read by Card3
DataRev.VNNc4 = 0; % VNN read by Card4
DataRev.VPPc4 = 0; % VPP read by Card4

DataRev.CurrentSeq = 0; % current imaging sequence
DataRev.Delay1=0;
DataRev.Delay2=0;
DataRev.Delay3=0;
DataRev.Delay4=0;
DataRev.Trigger1=0;
DataRev.Trigger2=0;
DataRev.intiation=0;
DataRev.Operation=0;   
DataRev.STOP=1;
else
    DataRev.COM= COMPORT;
    DataRev.VNNen = str2num(char(g(15)));    % VNN enable  
    DataRev.VPPen = str2num(char(g(16)));    % VPP enable  
    DataRev.VNNac = str2num(char(g(17)));      %VNN PS active
    DataRev.VPPac = str2num(char(g(18)));      %VPP PS active    
    DataRev.VNNccu =-str2num(char(g(19:21)));
    DataRev.VPPccu = str2num(char(g(22:24))); % VPP read by CCU
    DataRev.Card1Con=str2num(char(g(25)));   %Card 1 connect status
    DataRev.Card2Con=str2num(char(g(26)));   %Card 2 connect status
    DataRev.Card3Con=str2num(char(g(27)));   %Card 3 connect status
    DataRev.Card4Con=str2num(char(g(28)));   %Card 4 connect status
    DataRev.VNNc1 = -str2num(char(g(29:31))); % VNN read by Card1
    DataRev.VPPc1 = str2num(char(g(32:34))); % VPP read by Card1
    DataRev.VNNc2 = -str2num(char(g(35:37))); % VNN read by Card2
    DataRev.VPPc2 = str2num(char(g(38:40))); % VPP read by Card2
    DataRev.VNNc3 = -str2num(char(g(41:43))); % VNN read by Card3
    DataRev.VPPc3 = str2num(char(g(44:46))); % VPP read by Card3
    DataRev.VNNc4 = -str2num(char(g(47:49))); % VNN read by Card4
    DataRev.VPPc4 = str2num(char(g(50:52))); % VPP read by Card4
    DataRev.CurrentSeq = str2num(char(g(53:56))); % current imaging sequence
    DataRev.Delay1=str2num(char(g(57)));
    DataRev.Delay2=str2num(char(g(58)));
    DataRev.Delay3=str2num(char(g(59)));
    DataRev.Delay4=str2num(char(g(60)));
    DataRev.Trigger1=str2num(char(g(61)));
    DataRev.Trigger2=str2num(char(g(62)));
    DataRev.STOP=str2num(char(g(63)));
    DataRev.intiation=1;
    DataRev.Operation=0;   
       
end
end