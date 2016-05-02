%% Daniel Felipe Forero Sánchez
% 201415069
% Taller 3 - Laboratorio de Sísmica y Sismología
% Universidad de Los Andes
% Semestre 201610
clear all
%% Importar segy
[D, H, TH]=ReadSegy('710_80_Total_48Ch.sgy', 'revision', 0, 'dsf', 1);
%%
dt=H(1, 1).dt/1e6; %s
%% Ganancia AGC
[D_Gain] = AGCgain(D,dt,0.5,1);
%WriteSegy('710_80_Total_48Ch_Gain.sgy', D_Gain, 'dt', dt, 'dsf', 1, 'revision', 1);

%% Filtro
% Filtrado pasabanda:  bajas= ground roll, altas= alta resolucion.
N=100; cut_off=[15, 60];
[D_Gain_Filter, D_Gain_filter_f]=bpf_fir(D_Gain, dt, N, cut_off);
%WriteSegy('710_80_Total_48Ch_Gain_Filter.sgy', D_Gain_Filter, 'dt', dt, 'dsf', 1, 'revision', 1);

%% Deconvolución
max_lag=0.2; mu=0.1;
D_Gain_Filter_Decon = spiking_decon(D_Gain_Filter, max_lag, mu, dt);
[D_Gain_Filter_Decon_Gain] = AGCgain(D_Gain_Filter_Decon,dt,0.5,1);
%WriteSegy('710_80_Total_48Ch_Gain_Filter_Decon_Gain.sgy', D_Gain_Filter_Decon_Gain, 'dt', dt, 'dsf', 1, 'revision', 1);

%% CMP sort
[D_Gain_Filter_Decon_Gain_Sort, H_Sort]=ssort(D_Gain_Filter_Decon_Gain, H, 'offset');
[D_Gain_Filter_Decon_Gain_SortCDP, H_SortCDP]=ssort(D_Gain_Filter_Decon_Gain_Sort, H_Sort, 'cdp');
%WriteSegy('710_80_Total_48Ch_Gain_Filter_Decon_Gain_SortCDP.sgy', D_Gain_Filter_Decon_Gain_SortCDP, 'dt', dt, 'dsf', 1, 'revision', 1);

%% Análisis de Velocidad

cmp_step= 50;
cmp_start= 51;
cmp_end= 801;
vmin=5000;
dv=200;
nv=51;
n_pts=8;
%[v_stack, t_stack]=vel_picking(D_Gain_Filter_Decon_Gain_SortCDP, H_SortCDP, vmin, dv, nv, cmp_start, cmp_end, cmp_step, n_pts);
%dlmwrite('v_stack.csv',v_stack, ';');
%dlmwrite('t_stack.csv',t_stack, ';')
%disp('ok');
%}
%% Para no volver a picar 

%En el informe escribir acerca de la calidad de los CDP
filename = 'C:\Users\DanielFelipe\Google Drive\Uniandes\GeocienciasUniandes\Geociencias_201610\Sismica_Sismologia\Laboratorio_Sismica\Taller3\v_stack.csv';
delimiter = ';';

formatSpec = '%f%f%f%f%f%f%f%f%[^\n\r]';


fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);


fclose(fileID);


v_stack = [dataArray{1:end-1}];

clearvars filename delimiter formatSpec fileID dataArray ans;

filename = 'C:\Users\DanielFelipe\Google Drive\Uniandes\GeocienciasUniandes\Geociencias_201610\Sismica_Sismologia\Laboratorio_Sismica\Taller3\t_stack.csv';
delimiter = ';';

formatSpec = '%f%f%f%f%f%f%f%f%[^\n\r]';


fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);


fclose(fileID);


t_stack = [dataArray{1:end-1}];

clearvars filename delimiter formatSpec fileID dataArray ans;

%% Se debe insertar una fila arriba de ambos arreglos y copiar la primera fila a esta nueva.
t_stack=[t_stack(1, :); t_stack];
v_stack=[v_stack(1, :); v_stack];

%% NMO
cmp_start=1;
cmp_step=300;
[D_Gain_Filter_Decon_Gain_SortCDP_NMO, H_SortCDP_NMO]=nmo_correction(D_Gain_Filter_Decon_Gain_SortCDP, H_SortCDP, v_stack, t_stack,cmp_start,cmp_end,cmp_step);
disp('funciona');
%WriteSegy('710_80_Total_48Ch_Gain_Filter_Decon_Gain_SortCDP_NMO.sgy', D_Gain_Filter_Decon_Gain_SortCDP_NMO, 'dt', dt, 'dsf', 1, 'revision', 1);

%% Apilado

[D_Gain_Filter_Decon_Gain_SortCDP_NMO_Stack, t, cmp_num]=sstack(D_Gain_Filter_Decon_Gain_SortCDP_NMO, H_SortCDP_NMO);
%WriteSegy('710_80_Total_48Ch_Gain_Filter_Decon_Gain_SortCDP_NMO_Stack.sgy', D_Gain_Filter_Decon_Gain_SortCDP_NMO_Stack, 'dt', dt, 'dsf', 1, 'revision', 1);
