getd();

// MAILLAGE //
[ noeuds , elements ] = MSHLoader('rectangle1.msh');
numElements = size(elements,2);
numNoeuds = size(noeuds,2);     



[segments] = findSegments(elements)
numSegments = size(segments,2);


// parametres physiques
k=1000;
m=1;
g=-9.81;

// parametres temps
dt = 0.01;
T =  1.0;

// image de sortie
S = [];
S(1) = 'BMP\anim';
t=50;
S(2) = string(t);
S(3) = '.bmp';
k_t=0;


l0 = zeros(numSegments,1);
l = zeros(numSegments,1);
F_t = zeros(numNoeuds,2);

//compute l0
for s=1:numSegments
    indice_a=segments(1,s);
    indice_b=segments(2,s);
    pos_a=noeuds(1:2, indice_a);
    pos_b=noeuds(1:2, indice_b);
    l0(s)=norm(pos_a - pos_b)
end

// vecteur des positions:
X_t = zeros(2*numNoeuds,1);

//integration
vitesse = zeros(numNoeuds,2);

for i=1:numNoeuds
     X_t([2*i-1 2*i]) = [noeuds(1,i) ; noeuds(2,i)];
end

for time=0:dt:T,
    
    F_t = zeros(numNoeuds,2);
    acceleration = zeros(numNoeuds,2);
    

    
    for s=1:numSegments
        indice_a=segments(1,s);
        indice_b=segments(2,s);
        pos_a=X_t(2*indice_a-1 : 2*indice_a);
        pos_b=X_t(2*indice_b-1 : 2*indice_b);
        l(s)=norm(pos_b - pos_a);
        f = k * (l(s) - l0(s));
        
        d = (pos_b - pos_a) / norm(pos_b - pos_a);
        
        F_t(indice_a,1) = F_t(indice_a,1) + d(1) * f;
        F_t(indice_a,2) = F_t(indice_a,2) + d(2) * f;
        
        F_t(indice_b,1) = F_t(indice_b,1) - d(1) * f;
        F_t(indice_b,2) = F_t(indice_b,2) - d(2) * f;
    end
    
    acceleration(:,1) = acceleration(:,1);
    acceleration(:,2) = acceleration(:,2) + g ;
    acceleration = acceleration + F_t / m;

    vitesse = vitesse + acceleration * dt;
    vitesse(1,:) = [0 0];
    vitesse(2,:) = [0 0];
    vitesse(5,:) = [0 0];
    
    // application des translations
    for i=1:numNoeuds
        //x
        X_t(2*i-1) = X_t(2*i-1) + vitesse(i,1) * dt;
        //y
        X_t(2*i) = X_t(2*i) + vitesse(i,2) * dt;
    end    
        
    // déplacement du maillage
    noeuds_deplaces = noeuds;
    for i=1:numNoeuds,
      // deplacement selon x
      noeuds_deplaces(1,i) = X_t(2*i-1);
      // deplacement selon y
      noeuds_deplaces(2,i) = X_t(2*i);  
      
    end      
    
    clf;
    scf(0);
    draw_mesh( noeuds_deplaces, elements)
    a=get("current_axes");//get the handle of the newly created axes
    a.data_bounds=[-1,-1;10,10];
        
        
    k_t=k_t+1;    
    S(2) = string(k_t+99);
    xs2bmp(0,strcat(S));

    
    xpause(100000);


end

  
  
  
  

  




