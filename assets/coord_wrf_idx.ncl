; usage:
;        ncl 'coord_file="./path/to/wrf/coordinate/file.nc"' \
;            'minlat=float' \
;            'maxlat=float' \
;            'minlon=float' \
;            'maxlon=float' \
;            coord_wrf_idx.ncl;

;---coordinate variable path and and name must be entered as input arguments
  a    = addfile(coord_file,"r")
  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

;---variable names below should be defined as input arguments
;  minlat
;  maxlat
;  minlon
;  maxlon
;  print("coord_file: "+coord_file)
;  print("minlat: "+minlat)
;  print("maxlat: "+maxlat)
;  print("minlon: "+minlon)
;  print("maxlon: "+maxlon)

;---Get xy indexes, and then use these to get lat/lon values back again.
  opt    = True
  loc    = wrf_user_ll_to_xy(a,(/minlon,maxlon/),(/minlat,maxlat/),opt)

;---print the following box of data: [minlonidx, maxlonidx, minlatidx, maxlatidx]
  minlonidx = loc(0,0)
  maxlonidx = loc(0,1)
  minlatidx = loc(1,0)
  maxlatidx = loc(1,1)
  print(minlonidx+","+maxlonidx)
  print(minlatidx+","+maxlatidx)
;---END
