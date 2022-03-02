tic
mark = exist('lens');

if mark == 0
    
    lens = Optotune('COM4');%Set up lens
    lens = lens.Open();
    lens = currentMode(lens);

    vid = videoinput('gentl', 1, 'BayerRG12');%Set up camera
    src = getselectedsource(vid);
    vid.FramesPerTrigger = 1;
    src.ExposureTime = 69980;
    set(vid,'TriggerRepeat',inf);
    triggerconfig(vid, 'manual');
    preview(vid);
    start(vid);

end

% I = imread('C:\Users\chens\Desktop\1.png');
N1 = 25; %Times of the every round of auto-focus
N2 = 2; %Times of overall auto-focus
A = zeros(1,N1); %Sharpness of images
B = zeros(1,N1); %Sharpness of images (first round)
Ini = 0; %Initial value of every round
J = 10; %Step of auto-focus

%Auto-focus process

for K=1: N2

    for L=1: N1
        
          pause(0.01);
          trigger(vid);
          I = getdata(vid);%Image acquisition

          lens.setCurrent(Ini+L*J);%Set up the current of lens

          % image input and preprocessing  

          % I=imread([int2str(L),'.jpg']); 
          % I=double(I); 
          % [M N]=size(I);
          I = rgb2gray(I);
          I = medfilt2(I,[3,3]);
          I = im2double(I);
          [m,n] = size(I);
          Fa = 1.25;
          Fb = 0;
          I = Fa.*I + Fb/255;
          a = (3/8)*m;
          b = (3/8)*n;
          c = (5/8)*m;
          d = (5/8)*n;
          rect = [a,b,c,d];
          I= imcrop(I,rect);

          % sharpness calculation
          
          FI = 0; 
          [M,N] = size(I);      
                for x=1:M-2      
                   for y=1:N 
                     FI=FI+I(x,y)*abs(I(x+1,y)-I(x+2,y)); 
                   end 
                end
          A(1,L) = FI; %Sharpness
    end
           % time=toc

         %Find the position of the sharpest image
        
         [Max,order] = max(A);
         lens.setCurrent(Ini+(order-1)*J);
         current = Ini+(order-1)*J;
         %pause(0.01);

         Ini = (order-3)*J;
         J = (4*J)/N1;
 
         if K == 1
             B = A;
             testpoint1 = Ini;
             testpoint2 = order;
         end

end
toc
time = toc;
 
%lens.Close()
