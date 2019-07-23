# This is an nawk script for plotting m-level n-ary trees in jgraph.
# For each line of input, it will produce a new jgraph.  The line must
# contain two numbers: m and n, separated by white-space.
#
# Two nice outputs of this are: 
#
# ( echo "4 3" | nawk -f tree.awk ; echo "xaxis size 5.4" ) | jgraph -P
#
# and
# ( echo "5 2" | nawk -f tree.awk ; echo "xaxis size 5" ) | jgraph -P
#

{ m = $1
  n = $2

  printf("newgraph xaxis nodraw yaxis nodraw\n")
  k = 0
  for (j = 0; j < m; j++) {
    if (j == 0) {
      numleaves = n ^ (m - 1)
      for (i = 0; i < numleaves; i++) newleafloc[i] = i
    } else {
      numleaves = numleaves / n
      for (i = 0; i < numleaves; i++) {
        newleafloc[i] =  (oldleafloc[i*n] + oldleafloc[i*n+n-1]) / 2.0
      }
    }
    for (i = 0; i < numleaves; i++) {
      printf("newcurve marktype box marksize 0.6 0.4 fill 1 pts %f %f\n",
              newleafloc[i], j)
      printf("newstring x %f y %f hjc vjc fontsize 6 : %d\n",
              newleafloc[i], j, ++k)
      if (j > 0) {
        for (l = 0; l < n; l++) {
          printf("newcurve marktype none linetype solid pts %f %f  %f %f\n",
              newleafloc[i], j-.2, oldleafloc[i*n+l], j-.8)
        }
      }
    }
    for (i = 0; i < numleaves; i++) {
      oldleafloc[i] = newleafloc[i]
    }
  }
}
