! 
! Copyright (c) 2012-2018, NVIDIA CORPORATION.  All rights reserved.
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!     http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.
! 

  !
  ! Global variables
  !
  integer*8 :: mra, ncb, kab, lda, ldb, ldc
  complex*16, dimension( lda, * )::a
  complex*16, dimension( ldb, * )::b
  complex*16, dimension( ldc, * )::c
  complex*16 :: alpha, beta, one = 1.0
    character*1 :: ca, cb
    !
    ! local variables
  !
  integer*8  :: colsa, rowsa, rowsb, colsb
  integer*8  :: i, j, jb, k, ak, bk, jend
  integer*8  :: ar, ar_sav,  ac, ac_sav, br, bc
  integer*8  :: ndxa, ndxasav 
  integer*8  :: ndxb, ndxbsav, ndxb0, ndxb1, ndxb2, ndxb3
  integer*8  :: colachunk, colachunks, colbchunk, colbchunks
  integer*8  :: rowchunk, rowchunks
  integer*8  :: colsb_chunk, colsb_chunks, colsb_strt, colsb_end
  integer*8  :: colsa_chunk, colsa_chunks, colsa_strt, colsa_end
  integer*8  :: bufr, bufr_sav, bufca, bufca_sav, bufcb, bufcb_sav
  integer  :: ta, tb
  complex*16   :: temp, temp0, temp1, temp2, temp3 
    real*8   :: temprr0, temprr1, temprr2, temprr3
    real*8   :: tempii0, tempii1, tempii2, tempii3
    real*8   :: tempri0, tempri1, tempri2, tempri3
    real*8   :: tempir0, tempir1, tempir2, tempir3
    complex*16   :: bufatemp, bufbtemp
    real*8    :: bufatempr, bufatempi, bufbtempr, bufbtempi
  real*8   :: time_start, time_end, ttime, all_time

  integer, parameter :: bufrows = 512, bufcols = 8192
!  integer, parameter :: bufrows = 2, bufcols = 3
!  complex*16, dimension( bufrows * bufcols ) :: buffera, bufferb
    complex*16, allocatable, dimension(:) :: buffera, bufferb
  
!Minimun number of multiplications needed to activate the blocked optimization.
  integer, parameter :: min_blocked_mult = 15000 

#undef DCMPLX
#define DCMPLX(r,i) cmplx(r,i,kind=8)
