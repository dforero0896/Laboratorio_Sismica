%{
Daniel Felipe Forero Sánchez
Código: 201415069
Departemento de Geociencias
Departamento de Física
Universidad de Los Andes
Laboratorio de Sísmica y Sismología
Semestre: 201610
Taller 1

El presente código muestra el proceso realizado para solucionar los
ejercicios planteados en el enunciado del Taller.
%}

clear all

%Se crea la ondícula
ondicula=gauswavf(-2.5, 2.5, 20, 2); %de -2.5 a 2.5 , 1ms de muestreo, es decir, 20 puntos

%Se crea el arreglo de tiempos asignando a cada tiempo un coeficiente de
%reflectividad. Estos fueron calculados en MS Excel y se encuentran
%adjuntos en el archivo Calculos_Taller1.xlsx.
RC([873,280,480,640,740,1000])=[.3,.23,.19,.11,-.26,0.];

%Se obtiene la traza.
Traza= convz(RC, ondicula);

%Para exportar se necesita columna entonces se transpone.
Traza=Traza';

% Se crea una matriz que contiene 100 trazas de forma que se simulan 100
% experimentos en línea.
for i=1:length(Traza)
    for k=1:100
        Traza100(i, k)=Traza(i, 1);
    end
end

%Exportar archivo SEGY en formato 1.
WriteSegy('trazaTaller1_0.segy',Traza100,'dt',.001, 'revision', 1, 'dsf', 1);
WriteSegy('trazaTaller1_250.segy',Traza100,'dt',.001, 'revision', 1, 'dsf', 1);
WriteSegy('trazaTaller1_500.segy',Traza100,'dt',.001, 'revision', 1, 'dsf', 1);
WriteSegy('trazaTaller1_750.segy',Traza100,'dt',.001, 'revision', 1, 'dsf', 1);
WriteSegy('trazaTaller1_1000.segy',Traza100,'dt',.001, 'revision', 1, 'dsf', 1);



%Segundo punto.
%Se definen algunas constantes
espesorLime=350.; %km
espesorSand=700.-350.; %km
velocidadS=[1500., 2500.]; %m/s
velocidadP=[2500., 3500.]; %m/s
rho=[2.3, 2.6]; %g/cm^3

%Se crea el vector de ánguos de 0 a 45 cada 5 grados
theta_i=linspace(0, 45, 10); %deg

%Se convierten en radianes
theta_i=deg2rad(theta_i); %rad
%Se crea el vector que contendrá los tiempos de llegada para cada ángulo.


%Se calcula cada tiempo de llegada.
times_SandTop=10^3*(2*espesorLime)./(velocidadP(1)*cos(theta_i)); %ms

%Se crea y calcula el coseno del ángulo theta_2 usando ley de Snell
co_theta_r=(1-(velocidadP(2)^2/velocidadP(1)^2).*(sin(theta_i)).^2).^(1/2);


%Se crea y calcula el vector con los coeficientes de reflexión para cada
%ángulo usando la aproximación.
Rpp=(1/2)*log((velocidadP(2)*rho(2).*cos(theta_i))./(velocidadP(1)*rho(1).*co_theta_r))+(sin(theta_i)./velocidadP(1)).^2*(velocidadS(1)^2-velocidadS(2)^2)*(2+(log(rho(2)/rho(1))/log(velocidadS(2)/velocidadS(1))));


%Se crea la matriz cuyos veectores columna son los vectores de coeficientes
%de reflexión desplazados en el tiempo. Una columna para cada ángulo.
RCs=zeros(400,10);
for i=1:10
RCs(round(times_SandTop(i)),i)=Rpp(i);
end

%Se convuelve cada vector columna con la ondícula generando las trazas.
%Es una matriz cuyos vectores columna son las trazas.
TrazasAngulos=zeros(400, 10);
for i=1:10
TrazasAngulos(:,i)=convz(RCs(:,i), ondicula);
end

%Se exporta la matriz de trazas a formato segy
WriteSegy('trazasPunto2Taller1.segy',TrazasAngulos,'dt',.001);



% Código extra que grafica ciertas funciones, gráficos se encuentran en el
% informe en formato PDF.
%for i=1:10
%str = '$\theta_1=';
%str = strcat(str, num2str(rad2deg(theta_i(i))));
%str = strcat(str, '^{\circ}$');
%subplot(5,2,i)
%plot(RCs(:,i))
%xlim([0, 500])
%ylim([-0.4, 0.4])

%title(str, 'Interpreter', 'latex')
%view([90 90])
%end
%print('rpps', '-dpng');


%for i=1:10
%str = '$\theta_1=';
%str = strcat(str, num2str(rad2deg(theta_i(i))));
%str = strcat(str, '^{\circ}$');
%subplot(5,2,i)
%plot(TrazasAngulos(:,i))
%xlim([0, 500])
%ylim([-0.4, 0.4])
%title(str, 'Interpreter', 'latex')
%view([90 90])
%end
%print('trazas2', '-dpng');
