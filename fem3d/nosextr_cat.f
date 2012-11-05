c
c $Id: nosextr_cat.f,v 1.1 2008-07-16 15:41:39 georg Exp $
c
c concatenates NOS files
c
c revision log :
c
c 18.11.1998    ggu     check dimensions with dimnos
c 03.06.2011    ggu     routine adjourned
c 08.06.2011    ggu     routine rewritten
c 31.01.2012    ggu     choice of concatenation mode (mode, itc)
c 05.08.2012    ggu     bug fix - first read, then open for write
c
c**********************************************************

	program nosextr_cat

c concatenates two nos files into one

        implicit none

	include 'param.h'

	character*80 name,file

	character*80 title
	real cv(nkndim)
	real cv3(nlvdim,nkndim)

        double precision accum(nlvdim,nkndim)
	real amin(nlvdim,nkndim)
	real amax(nlvdim,nkndim)

	integer ilhkv(nkndim)
	real hlv(nlvdim)
	real hev(neldim)

	logical ball,bwrite
        integer nread,ivarold,nextr
	integer nread1,nread2
        integer l,k,nin,nb
        integer nkn,nel,nlv,nvar
        integer it,ivar
	integer itfirst,itsecond
        integer ierr
        integer nvers
	integer mode,itc
	integer date,time
        real r,rnull
	real conz,high
	character*80 file1,file2

        integer iapini,ideffi,ifileo

c-------------------------------------------------------------------
c initialize params
c-------------------------------------------------------------------

	itfirst = -1
	itsecond = -1
	nread=0
	nread1=0
	nread2=0
	nextr=0
	rnull=0.
        ivarold = 0
	high = 1.e+30

c-------------------------------------------------------------------
c get mode of operation
c-------------------------------------------------------------------

	mode = 0
	itc = 0
	write(6,*) 'operation mode:'
	write(6,*) ' -1   all of first file, then all of second file'
	write(6,*) '  0   all of first file, rest of second file'
	write(6,*) '  1   first file until start of second file'
	write(6,*) '  2   first file up to itc (inclusive), then second'
	write(6,*) '  in case of mode 2 itc value is also requested'
	write(6,*) '  mode -1 does not care about time, just joins'
	write(6,*) 'Enter mode:'
	read(5,'(i10)') mode
	if( mode .lt. -1 .or. mode .gt. 2 ) stop 'error stop: mode'
	if( mode .eq. 2 ) then
	  write(6,*) 'Enter time up to when to read first file:'
	  read(5,'(i10)') itc
	end if
	write(6,*) 'mode,itc: ',mode,itc

        write(6,*) 'Enter first file:'
        read(5,'(a)') file1
        write(6,*) file1

        write(6,*) 'Enter second file:'
        read(5,'(a)') file2
        write(6,*) file2

	if( mode .eq. 1 ) then
	  call nos_get_it_start(file2,itc)
	  if( itc .eq. -1 ) then
	    write(6,*) 'cannot read starting time of second file'
	    stop 'error stop: starting time'
	  end if
	  itc = itc - 1		!last time for first file
	end if

c-------------------------------------------------------------------
c open first NOS file and read header
c-------------------------------------------------------------------

	call open_nos_file(file1,'old',nin)

        nvers=3
	call nos_init(nin,nvers)
	call nos_read_header(nin,nkn,nel,nlv,nvar,ierr)
	call nos_get_date(nin,date,time)
	call nos_get_title(nin,title)

	!call rfnos(nin,nvers,nkn,nel,nlv,nvar,title,ierr)
        if(ierr.ne.0) goto 100

        write(6,*) 'nvers    : ',nvers
        write(6,*) 'nkn,nel  : ',nkn,nel
        write(6,*) 'nlv,nvar : ',nlv,nvar
        write(6,*) 'date,time: ',date,time
        write(6,*) 'title    : ',title

        call dimnos(nin,nkndim,neldim,nlvdim)

	call rsnos(nin,ilhkv,hlv,hev,ierr)
        if(ierr.ne.0) goto 100

	write(6,*) 'Available levels: ',nlv
	write(6,*) (hlv(l),l=1,nlv)

c-------------------------------------------------------------------
c open NOS output file
c-------------------------------------------------------------------

        call mkname(' ','nos_cat','.nos',file)
        write(6,*) 'writing file ',file(1:50)
        nb = ifileo(55,file,'unform','new')
        if( nb .le. 0 ) goto 98
	date = 20120101
	time = 0
	call nos_init(nb,nvers)
	call nos_set_title(nb,title)
	call nos_set_date(nb,date,time)
	call nos_write_header(nb,nkn,nel,nlv,nvar,ierr)
        !call wfnos(nb,3,nkn,nel,nlv,1,title,ierr)
        if( ierr .ne. 0 ) goto 99
        call wsnos(nb,ilhkv,hlv,hev,ierr)
        if( ierr .ne. 0 ) goto 99

c-------------------------------------------------------------------
c loop on input records
c-------------------------------------------------------------------

  300   continue

	call rdnos(nin,it,ivar,nlvdim,ilhkv,cv3,ierr)

        if(ierr.gt.0) write(6,*) 'error in reading file : ',ierr
        if(ierr.ne.0) goto 100

	if( mode .gt. 0 .and. it .gt. itc ) goto 100
	itfirst = it
	nread=nread+1
	nread1=nread1+1
	write(6,*) 'time : ',nread,it,ivar

	call wrnos(nb,it,ivar,nlvdim,ilhkv,cv3,ierr)
	if( ierr .ne. 0 ) goto 99

	goto 300
  100	continue

	close(nin)
	call delnos(nin)

c-------------------------------------------------------------------
c open second NOS file and read header
c-------------------------------------------------------------------

	call open_nos_file(file2,'old',nin)

        nvers=3
	call nos_init(nin,nvers)
	call nos_read_header(nin,nkn,nel,nlv,nvar,ierr)
	call nos_get_title(nin,title)
	call nos_get_date(nin,date,time)
	!call rfnos(nin,nvers,nkn,nel,nlv,nvar,title,ierr)
        if(ierr.ne.0) goto 100

        write(6,*) 'nvers    : ',nvers
        write(6,*) 'nkn,nel  : ',nkn,nel
        write(6,*) 'nlv,nvar : ',nlv,nvar
        write(6,*) 'date,time: ',date,time
        write(6,*) 'title    : ',title

        call dimnos(nin,nkndim,neldim,nlvdim)

	call rsnos(nin,ilhkv,hlv,hev,ierr)
        if(ierr.ne.0) goto 100

	write(6,*) 'Available levels: ',nlv
	write(6,*) (hlv(l),l=1,nlv)

c-------------------------------------------------------------------
c loop on input records
c-------------------------------------------------------------------

  301   continue

	call rdnos(nin,it,ivar,nlvdim,ilhkv,cv3,ierr)

        if(ierr.gt.0) write(6,*) 'error in reading file : ',ierr
        if(ierr.ne.0) goto 101
	if( mode .ge. 0 .and. it .le. itfirst ) goto 301 !make records unique

	if( itsecond .eq. -1 ) itsecond = it
	nread=nread+1
	nread2=nread2+1
	write(6,*) 'time : ',nread,it,ivar

	call wrnos(nb,it,ivar,nlvdim,ilhkv,cv3,ierr)
	if( ierr .ne. 0 ) goto 99

	goto 301
  101	continue

	close(nin)

c-------------------------------------------------------------------
c end of loop
c-------------------------------------------------------------------

	write(6,*)
	write(6,*) nread,' records read'
	write(6,*)
	write(6,*) 'nread1/2: ',nread1,nread2
	write(6,*) 'it: ',itfirst,itsecond
	write(6,*)

c-------------------------------------------------------------------
c end of routine
c-------------------------------------------------------------------

	stop
   91	continue
	write(6,*) 'file may have only one type of variable'
	write(6,*) 'error ivar : ',ivar,ivarold
	write(6,*) 'You should use nossplit to extract scalars first'
	stop 'error stop nosextr_records: ivar'
   98	continue
	write(6,*) 'error opening outout file'
	stop 'error stop nosextr_records'
   99	continue
	write(6,*) 'error writing file'
	stop 'error stop nosextr_records'
	end

c***************************************************************

