function varargout = CFlush(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CFlush_OpeningFcn, ...
                   'gui_OutputFcn',  @CFlush_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before CFlush is made visible.
function CFlush_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = CFlush_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes on button press in RST.
function RST_Callback(hObject, eventdata, handles)
set(handles.ENDP,'BackgroundColor', 'white');
set(handles.MP,'BackgroundColor', 'yellow');
set(handles.eq, 'String', 0);
set(handles.ep, 'String', 0);
set(handles.OE, 'String', 0);
set(handles.CE, 'String', 0);
cla(handles.axes1,'reset');
cla(handles.axes2,'reset');
set(handles.PUP,'string',0);
guidata(hObject, handles); %updates the handles

% --- Executes on button press in Clac.
function Clac_Callback(hObject, eventdata, handles)
%flags
 flaQ = 1; flaP=0; diff=0; df=1; ddiff=0; z=0; open=0;FV=1;wfv=0;hf=1;fct=1;%0;
fill=0;clo=0; flush=1; Hw=0; pkd=0; ps=0; rr=1; r1 = 1; test=1;tr=0;hv=1;
          
% --- Dripper
q =str2num(get(handles.Q,'String'));%A(1);  %losses const
kd =str2num(get(handles.KD,'String'));% A(2); %const
k = str2num(get(handles.K,'String'));%A(3); %const
x =str2num(get(handles.X,'String')); %A(4); %const
pc =str2num(get(handles.PC,'String')); %A(4); %const

 % --- Lateral
[L,v1]= str2num(get(handles.PL,'String')); % Pipe length (m)
[D,v2] = str2num(get(handles.PD,'String')); % Pipe diameter (cm)
[sbd,v3] = str2num(get(handles.SBD,'String')); % space between droppers (m)
[endp,v4] = str2num(get(handles.ENDP,'String')); % End pressure (mH2O)
[h,v5] = str2num(get(handles.RH,'String')); % Row high

 % --- Submain
[NOE,v6] = str2num(get(handles.NOE,'String')); %Number Of Extentions
[sbe,v7] = str2num(get(handles.SBE,'String')); % space between extantions (m)
[De,v8] = str2num(get(handles.LD,'String')); % Line diameter (cm)
[lh,v9] = str2num(get(handles.LH,'String')); %line slop

 % --- Pump
[kf,v10]=str2num(get(handles.FVK,'String'));
[pf,v11]=str2num(get(handles.CP,'String'));
[eff,v12]=str2num(get(handles.EFF,'String'));
tm= get(handles.TM,'value');
gama=9.81*1000;

% --- Input check
if q<=0||kd<=0||k<=0||x<=0||D<=0
        errordlg('Check database Input','Error');
elseif  (v1*v2*v3*v4*v5*v6*v7*v8*v9*v10*v11*v12==0);
        errordlg('Input Must be Number','Error');
elseif        (0==L*D*sbd*endp*NOE)||((0==De*sbe)&&(NOE>1))
    errordlg('Check User Input','Error');
else   
    alpha=asind(h/L); %exention slop
    alphal = asind(lh/(NOE*sbe)); %exention slop
    set(handles.MP,'BackgroundColor', 'yellow');
%  tic;
if tm
    set(handles.ENDP,'BackgroundColor', 'red');
else set(handles.ENDP,'BackgroundColor', 'white');
end
while test&&NOE>1
    r=0;
    df=1;
       % --- solution for all extantions - algorithm B
    while r<NOE
        i=1; Hw=0; pkd=0; ps=0;
        r=r+1;flaQ = 1 ; flaP=0;
        if r==1
            p(r,i)=endp;
        else p(r,i)=p(r-1,1)+diff;
        end
        
        % --- Flusing Valve
        if pf> p(r,i)
            if tm
                Q(r,i)=300;
            else
                Q(r,i)=kf* (p(r,i))^0.5;
            end            
            if flush
                diff=0;
                df=1;
                open=1+open;
            end
        else   Q(r,i)=0;
            if flush
                diff=0;
                df=1;
                clo=1+clo;
            end
        end
        flush=1;
        
   % --- solution for one Lateral - algorithm A
        for i=2:1:(2*fix(L/sbd))+1
            if flaQ % Pressure remain
                p(r,i)=p(r,i-1);
                if p(r,i)<pc
                    Q(r,i)=(k*p(r,i)^x)+Q(r,i-1);
                    flaQ=0;
                else Q(r,i)=(k*pc^x)+Q(r,i-1);
                    flaQ=0;
                end
                if i==(2*fix(L/sbd))+1
                    Hw=Hw+(0.0000075837*sbd*(Q(r,i))^1.76)/((D/10)^4.76);
                    pkd=pkd+0.00000063755*kd*(Q(r,i))^2/((D/10)^4);
                     p(r,i)=p(r,1)+Hw+pkd+h;
                end
            end
            if flaP % Flow remain
                Q(r,i)=Q(r,i-1);
                Hw=Hw+(0.0000075837*sbd*(Q(r,i))^1.76)/((D/10)^4.76);
                pkd=pkd+0.00000063755*kd*(Q(r,i))^2/((D/10)^4);
                ps=(i-1)/2*(sbd*sind(alpha));
                p(r,i)=p(r,1)+Hw+pkd+ps;
                flaQ=1;
            end
            if flaQ
                flaP=0;
            else flaP=1;
            end
        end
        if get(handles.CFTL,'value')
            Q(r,i)=Q(r,i)*2;
        end
        if r==1
            eq(r)=Q(r,i);
            ep(r)=p(r,i);
            cg(r)=r;
            w(r)=gama*eq(r)*1/3600000*ep(r)/eff ;
        else eq(r)=Q(r,i)+eq(r-1);
            ep(r)=ep(r-1)+(0.0000075837*sbe*(eq(r))^1.76)/((De/10)^4.76)+(sbe*sind(alphal)) ;
            cg(r)=r;
            w(r)=gama*eq(r)*1/3600000*(ep(r))/eff;
            if df
                diff=ep(r)-ep(r-1)+p(r-1,1)/100;
            end
        end

        % pressure optimization
        if r>1
            if (p(r,i)/ep(r-1))>1.005
                diff=diff-(ep(r)-ep(r-1)+p(r-1,1)/100)*r/1050;
                r=r-1;
                flush=0;
                df=0;
            else 
                if  (p(r,i)/ep(r-1))<0.995;
                    diff=(ep(r)-ep(r-1))*r/950+diff+p(r-1,1)/100;
                    flush=0;
                    r=r-1;
                    df=0;
                end
            end
        end 
    end
    if tm==0
         break ;
    end
    %------TestMode------%   % --- F lushing Mode - algorithm C
    if tm
        if hv
            pgg=ep;
            qgg=eq;
            cggg=cg;
            wggg=gama*eq.*ep*1/3600000/eff ;
            wgg=gama*eq(r)*ep(r)*1/3600000/eff ;
            noe=NOE;
            hv=0;
            endp=3.9;%pf-NOE*0.009;
        end
        if hv==0
            if clo==0
                z=1;
                cgg=clo;
                wg=gama*eq(r)*ep(r)/3600000/eff ;
            else 
                if clo>=1&&z==0
                    ddiff=-endp/35;
                    endp=endp+ddiff;
                end
            end
        end
        if z
            if wg>wgg
                fct=2*fct;
                NOE= fix(NOE/2);
            else
                for t=1:1:NOE
                    pg(t)=ep(t);
                    qg(t)=eq(t);
                    wt(t)=gama*qg(t)*pg(t)/3600000/eff ;
                    ogg(t)=t;
                end
                test=0;
            end
        end
        flush=1;
        open=0;
        clo=0;
        diff=0;
    end
end
%--- Ploting
%these two lines of code clears both axes
cla(handles.axes1,'reset')
cla(handles.axes2,'reset')
if tm
    axes(handles.axes1)
    plot(qg,pg,'--rs','LineWidth',3,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',5);
    axis on
    grid on
    ylabel('P[mH2O]')
    xlabel('Q [m^3/s]')
    title('Test Mode')
if NOE>1
    axes(handles.axes2)
    plot(ogg,wt,'-.r*')
    text(cggg(NOE),w(NOE),' \leftarrow Flushing Freg. State','FontSize',8,'BackgroundColor',[1 1 .6])
    hold on
    plot(cggg,wggg,'--bs')
    text(cggg(NOE),wggg(NOE),' \leftarrow All Ext. Close','FontSize',8,'BackgroundColor',[1 1 .6])
    axis on
    grid on
    xlabel('No. of Ext.')
    ylabel('W [watt]')
    title('Test Mode')
end
else
    axes(handles.axes1)
    plot(eq,ep,'--rs','LineWidth',3,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',5);
axis on
grid on
ylabel('P[mH2O]')
xlabel('Q [m^3/s]')
title('P [mH2O] Vs. Q [m^3/s]')
if NOE>1
axes(handles.axes2)
 title('Ploting only with Test Mode.')
end
end
 eq = eq(r);
set(handles.eq, 'String', eq);
ep = ep(r);
set(handles.ep, 'String', ep);
if tm
    set(handles.PUP, 'String', wgg);
    set(handles.OE, 'String', ogg(t));
    set(handles.CE, 'String', (noe-ogg(t)));
    msgbox(['Pump size: ',num2str(wgg)],'PUMP')
    uiwait(gcf); 
    msgbox(['No. of Fragments: ',num2str(fct)],'FRAGMENT')
else 
    set(handles.PUP, 'String', w(r));
    set(handles.OE, 'String', open);
    set(handles.CE, 'String', clo);
end
%  toc;
if ep>str2num(get(handles.MP, 'String'))
    set(handles.MP,'BackgroundColor', 'red');
    errordlg('Please Check Pipe Max. Pressure','Error');
end
end
 
% --- Executes on button press in CFTL.
function CFTL_Callback(hObject, eventdata, handles)

function EFF_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function EFF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CP_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function CP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FVK_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function FVK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in TM.
function TM_Callback(hObject, eventdata, handles)

function SBE_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function SBE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LH_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function LH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LD_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function LD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NOE_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function NOE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PL_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function PL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SBD_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function SBD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ENDP_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ENDP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RH_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function RH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function PD_CreateFcn(hObject, eventdata, handles)

% --- Executes on selection change in Dripper Name.
function DN_Callback(hObject, eventdata, handles)
guidata(hObject, handles); %updates the handles
s= get(handles.DN, 'String');
if strcmp('Choose', s)
      [numdn,DN]=xlsread('data.xls', 'Dripper Name');%import excel data (driper names list)
      set(hObject, 'String',DN);
      set(hObject, 'UserData',DN);
      str=get(handles.DN,'UserData');
    val=get(handles.DN,'Value');
    [numfr,FR]=xlsread('data.xls', str{val},'A:A');
    set(handles.FR, 'String',numfr(:,1));
    [numpi,PI]=xlsread('data.xls', str{val},'E:F');
    set(handles.Pipe, 'String',numpi(:,1));
else
    str=get(handles.DN,'UserData');
    val=get(handles.DN,'Value');
    [numfr,fr]=xlsread('data.xls', str{val},'A:A');
    set(handles.FR, 'String',numfr(:,1));
    [numpi,PI]=xlsread('data.xls', str{val},'E:F');
    set(handles.Pipe, 'String',numpi(:,1));
end

% --- Executes during object creation, after setting all properties.
function DN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Flow Rate.
function FR_Callback(hObject, eventdata, handles)
guidata(hObject, handles); %updates the handles
 str=get(handles.DN,'String');
 val=get(handles.DN,'Value');
 if strcmp('Choose', str)
       errordlg('Choose Dripper First','Error');
 else
    str1=get(hObject,'String');
    val1=get(hObject,'Value');
    [numGT,gt]=xlsread('data.xls', str{val},'B:D');
    set(handles.K, 'String',numGT(val1,1));
    set(handles.X, 'String',numGT(val1,2));
    set(handles.PC, 'String',numGT(val1,3)); 
    set(handles.Q, 'String',str1(val1,:));
 end
  
% --- Executes during object creation, after setting all properties.
function FR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Pipe.
function Pipe_Callback(hObject, eventdata, handles)
guidata(hObject, handles); %updates the handles
str=get(handles.DN,'String');
val=get(handles.DN,'Value');
 if strcmp('Choose', str)
       errordlg('Choose Dripper First','Error');
 else
     set(handles.MP,'BackgroundColor', 'yellow');    
    str1=get(hObject,'String');
    val1=get(hObject,'Value');
    [numMP,mp]=xlsread('data.xls', str{val},'F:H');
    set(handles.KD, 'String',numMP(val1,2));
    set(handles.PD, 'String',numMP(val1,1));
    set(handles.MP, 'String',numMP(val1,3)) 
 end

% --- Executes during object creation, after setting all properties.
function Pipe_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






