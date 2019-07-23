#include <math.h>
     main()
     {
       double x;
       for (x = -10.0; x < 10.0; x += .03)
         printf("%f %f\n", x, sin(x));
     }
