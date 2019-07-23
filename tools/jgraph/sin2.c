#include <math.h>
     main()
     {
       double x;
       for (x = 0.1; x < 100.0; x += .03)
         printf("%f %f\n", x, sin(x));
     }
