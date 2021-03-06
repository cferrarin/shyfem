
!******************************************************************

	subroutine read_maps(file,nmaps,ncdim,cdata)

	implicit none

	character*(*) file
	integer nmaps,ncdim
	real cdata(3,ncdim,nmaps)

	end

!******************************************************************

	subroutine read_colormap(file,cname,ncdim,cdata,berr)

	implicit none

	character*(*) file
	character*(*) cname	!check if empty, read if set
	integer ncdim
	real cdata(3,ncdim)
	logical berr

	logical bend,bread,bfound
	logical bincolormap
	integer iend,nc,nmap,ios
	real col(3)
	character*80 line,name

	nmap = 0
	nc = 0
	bincolormap = .false.		!inside colormap
	bread = .false.			!have to read data?
	bfound = .false.		!have found right colormap?
	berr = .true.			!have encountered error?
	iend = 0
	bend = .false.

	cdata = -1.

	open(1,file=file,status='old',form='formatted',iostat=ios)
	if( ios /= 0 ) then
	  write(6,*) 'cannot read colormap ',trim(file)
	  berr = .true.
	  return
	end if

	do 
	  read(1,'(a)',iostat=ios) line
	  if( ios /= 0 ) exit
	  if( line == ' ' ) cycle
	  line = adjustl(line)
	  if( line(1:1) == '#' ) cycle
	  if( line(1:1) == '_' ) then
	    bincolormap = .true.
	    nmap = nmap + 1
	    nc = 0
	    iend = scan(line(2:),'_')
	    name = line(2:iend)
	    if( name == cname ) then
	      bread = .true.
	      bfound = .true.
	    end if
	    iend = scan(line,'[') + 1
	    line = adjustl(line(iend:))
	    write(6,*) 'start of colormap: ',trim(name),'  ',trim(line)
	    if( bread ) write(6,*) '...inserting'
	  end if
	  if( bincolormap ) then
	    bend = .false.
	    iend = len_trim(line)
	    if( line(iend-1:iend) == ']]' ) then
	      bend = .true.
	    else if( line(iend-1:iend) == '],' ) then
	      !still in colormap
	    else
	      write(6,*) 'error reading colormap ',trim(line)
	    end if
	  end if
	  line = line(2:iend-2)
	  !write(6,*) 'scanning line: ',trim(line)
	  read(line,*) col
	  !write(6,*) 'scanned line: ',col
	  nc = nc + 1
	  if( bread ) then
	    if( nc > ncdim ) then
	      write(6,*) 'colortable too big: ',ncdim
	      berr = .true.
	      return
	    end if
	    cdata(:,nc) = col
	  end if

	  if( bend ) then
	    bincolormap = .false.
	    bread = .false.
	    write(6,*) 'end of colormap: ',trim(name),'  ',nc
	  end if
	end do

	if( bincolormap ) then
	  write(6,*) 'no end of colormap ',trim(file)
	  berr = .true.
	  return
	end if

	if( ios > 0 ) then
	  write(6,*) 'error reading colormap ',trim(file)
	  berr = .true.
	  return
	end if

	close(1)

	berr = .not. bfound

	end

!******************************************************************

	subroutine test_colormaps

	implicit none

	logical berr
	integer, parameter :: ncdim = 256
	real cdata(3,ncdim)
	character*80 file,cname

	file='colormap.dat'
	cname='inferno'
	cname=' '

	call read_colormap(file,cname,ncdim,cdata,berr)

	if( berr ) then
	  stop 'error stop: reading color table'
	end if

	end

!******************************************************************

	program test_colormaps_main
	call test_colormaps
	end

!******************************************************************

