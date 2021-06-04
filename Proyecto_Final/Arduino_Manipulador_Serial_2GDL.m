%% Inicialización
a = arduino(); %Conecto con el arduino
s1 = servo(a, 'D2', 'MinPulseDuration', 0.5*10^-3, 'MaxPulseDuration', 2.5*10^-3); %Conecto al servo 1
s2 = servo(a, 'D4', 'MinPulseDuration', 0.5*10^-3, 'MaxPulseDuration', 2.5*10^-3); %Conecto al servo 2

%% Generación del área de trabajo -90 - 90
X = zeros(36,1); %Vector para colocar los puntos en X del área de trabajo
Y = zeros(36,1); %Vector para colocar los puntos en Y del área de trabajo
i = 0; %Contador para meter los datos generados en los vectoes
a = 9; %Eslabón 1
b = 11; %Eslabón 2

hold on %Para que pueda graficar todos los puntos en una misma gráfica
for angle1 = 0:0.2:1 %Barrido de números de 0 a 1 porque son los inputs que aceptan los servos
    for angle2 = 0:0.2:1
        i = i + 1; %Aumento contador
        q1 = angle1*180; %Transformo los inputs de servo a ángulos
        q2 = (angle2-0.5)*180; %Tiene un desfase de 0.5 porque mis ángulos van de -90 a 90
        %Cinemática Directa
        x = 11*cosd(q1+q2) + 9*cosd(q1);
        y = 11*sind(q1+q2) + 9*sind(q1);
        plot(x,y,'.-') %Grafico los puntos
        X(i,1) = x; %Coloco los datos en los vectores
        Y(i,1) = y;
    end
end
coordenadas = [X Y]; %Coloco los vectores como una matriz con coordenadas

%Grafico el contorno del área de trabajo
ang=0:0.0001:pi;
ang2=0.5*pi:0.0001:pi;
xs2=b*cos(ang);
ys2=b*sin(ang);
xp=sqrt(a^2 + b^2)*cos(ang);
yp=sqrt(a^2 + b^2)*sin(ang);
xg=(a + b)*cos(ang);
yg=(a + b)*sin(ang);
plot(xp,yp);
plot(xg,yg);
hold off

%% Solución de cinemática inversa y atand2
a = 9; %Eslabón 1
b = 11; %Eslabón 2
sol = 0; %Bandera para saber si ya encontró una solución

%Ciclo for para que recorra todas las coordenadas generadas
for n = 1:length(coordenadas)    
    xf = coordenadas(n,1);
    yf = coordenadas(n,2);
    %Primera condicional: Debe de cumplir con las restricciones geométricas
    %Se usó una lógica polar para dar estas restricciones
    %Es importante dar una incertidumbre (el +-0.5) a las medidas por como
    %funciona Matlab y los tipos de datos
    if (xf^2+yf^2 >= (a^2 + b^2 - 0.5)) && (xf^2+yf^2 <= (a+b)^2 + 0.5)
        %Cinemática Inversa
        %Ángulo Q2 (del eslabón 2)
        %Todas las soluciones
        q2_1 = acosd((xf^2 + yf^2 - a^2 - b^2)/(2*a*b));
        q2_2 = -acosd((xf^2 + yf^2 - a^2 - b^2)/(2*a*b));
        %Ángulo Q1 (del eslabón 1)
        %Todas las soluciones
        q1_1 = atan2d(yf,xf) - atan2d((b*sind(q2_1)),(a+b*cosd(q2_1)));
        q1_2 = atan2d(yf,xf) + atan2d((b*sind(q2_2)),(a+b*cosd(q2_2)));
        q1_3 = atan2d(yf,xf) - atan2d((b*sind(q2_2)),(a+b*cosd(q2_2)));
        q1_4 = atan2d(yf,xf) + atan2d((b*sind(q2_1)),(a+b*cosd(q2_1)));
        
        %Comprobación de la cinemática directa con cada una de las
        %soluciones propuestas
        xtemp_1 = 11*cosd(q2_1 + q1_1) + 9*cosd(q1_1);
        ytemp_1 = 11*sind(q2_1 + q1_1) + 9*sind(q1_1);
        
        xtemp_2 = 11*cosd(q2_2 + q1_2) + 9*cosd(q1_2);
        ytemp_2 = 11*sind(q2_2 + q1_2) + 9*sind(q1_2);
        
        xtemp_3 = 11*cosd(q2_2 + q1_3) + 9*cosd(q1_3);
        ytemp_3 = 11*sind(q2_2 + q1_3) + 9*sind(q1_3);
        
        xtemp_4 = 11*cosd(q2_1 + q1_4) + 9*cosd(q1_4);
        ytemp_4 = 11*sind(q2_1 + q1_4) + 9*sind(q1_4);
        
        %Revisa que la soluciones cumpla con la cinemática directa y que,
        %si el ángulo es negativo le sume 360 para que el servo pueda
        %hacerlo. Si el ángulo es negativo y al sumarle 360 está fuera de
        %las capacidades del servo, significa que debe de seguir buscando
        %soluciones. Si todas las restricciones cumplen, el programa
        %reconoce a esta solución y le da un valor distinto de 0 a la
        %bandera sol, indicando que ya no tiene que seguir buscando una
        %solución.
        if (q1_1 < 0.5) && (abs(xtemp_1-xf)<0.5) && (abs(ytemp_1-yf)<0.5)
            q1_1 = q1_1 + 360;
            if (q1_1 < 180)
                q1 = q1_1;
                q2 = q2_1;
                sol = 1;
            end
        elseif (abs(xtemp_1-xf)<0.5) && (abs(ytemp_1-yf)<0.5)
            q1 = q1_1;
            q2 = q2_1;
            sol = 1;
        end
        %La misma lógica aplica para todas las demás soluciones, pero
        %tomando en cuenta que ahora tiene que revisar si ya encontró una
        %solución o no.
        if (q1_2 < 0) && (abs(xtemp_2-xf)<0.5) && (abs(ytemp_2-yf)<0.5) && (sol == 0)
            q1_2 = q1_2 + 360;
            if (q1_2 < 180)
                q1 = q1_2;
                q2 = q2_2;
                sol = 2;
            end
        elseif (abs(xtemp_2-xf)<0.5) && (abs(ytemp_2-yf)<0.5) && (sol == 0)
            q1 = q1_2;
            q2 = q2_2;
            sol = 2;
        end
        
        if (q1_3 < 0) && (abs(xtemp_3-xf)<0.5) && (abs(ytemp_3-yf)<0.5) && (sol == 0)
            q1_3 = q1_3 + 360;
            if (q1_3 < 180)
                q1 = q1_3;
                q2 = q2_2;
                sol = 3;
            end
        elseif (abs(xtemp_3-xf)<0.5) && (abs(ytemp_3-yf)<0.5) && (sol == 0)
            q1 = q1_3;
            q2 = q2_2;
            sol = 3;
        end
        
        if (q1_4 < 0) && (abs(xtemp_4-xf)<0.5) && (abs(ytemp_4-yf)<0.5) && (sol == 0)
            q1_4 = q1_4 + 360;
            if (q1_4 < 180)
                q1 = q1_4;
                q2 = q2_1;
                sol = 4;
            end
        elseif (abs(xtemp_4-xf)<0.5) && (abs(ytemp_4-yf)<0.5) && (sol == 0)
            q1 = q1_4;
            q2 = q2_1;
            sol = 4;
        end
        %Reinicia la bandera de solución para que pueda repetirse en la
        %siguiente corrida del ciclo for.
        sol = 0;
        %Mapeo de los ángulos a inputs para los servos
        %El servo 2 tiene un +0.5 porque se utilizan ángulos de -90 a 90
        input1 = round(q1)/180;
        input2 = round(q2)/180+0.5;
        writePosition(s1, input1);
        writePosition(s2, input2);
    %Si la coordenada ingresada no está en el área de trabajo, se despliega 
    %este mensaje e imprime las coordenadas que no están en el área.  
    else
        fprintf("Fuera del area de trabajo\n")
        xf
        yf
    end
    %Grafico la pose que tiene el manipulador serial
    hold on
    x1=(9*cosd(q1));
    y1=(9*sind(q1));
    plot([0 x1],[0 y1])
    xtemp = 11*cosd(q2 + q1) + 9*cosd(q1);
    ytemp = 11*sind(q2 + q1) + 9*sind(q1);
    plot([x1 xtemp],[y1 ytemp])
    hold off
    pause(1);
end

%% Fin
clear
clc