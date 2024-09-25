; Meteorological Data Processing Workflow
; Copyright (C) 2022, University of Saskatchewan
; Copyright (C) 2023, University of Calgary
;
; This file is part of Meteorological Data Processing Workflow
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; usage:
;        ncl 'coord_file="./path/to/wrf/coordinate/file.nc"' \
;            'minlat=float' \
;            'maxlat=float' \
;            'minlon=float' \
;            'maxlon=float' \
;            coord_wrf_idx.ncl;

;---suppress errors including fatal ones
 err = NhlGetErrorObjectId()

  setvalues err
    "errPrint" : "False"
  end setvalues

;---coordinate variable path and and name must be entered as input arguments
  a    = addfile(coord_file,"r")
  glat2d = a->lat
  glon2d = a->lon

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

;---building arrays for getind_latlon2d () function
  lat = (/ minlat, maxlat /)
  lon = (/ minlon, maxlon /)

;---Get xy indexes, and then use these to get lat/lon values back again.
  opt    = True
  loc    = getind_latlon2d (glat2d, glon2d, lat, lon)

;---print the following array: [minlonidx, maxlonidx, minlatidx, maxlatidx]
  minlonidx = min(loc(:, 1)) 
  maxlonidx = max(loc(:, 1))
  minlatidx = min(loc(:, 0))
  maxlatidx = max(loc(:, 0))
  print(minlonidx+","+maxlonidx)
  print(minlatidx+","+maxlatidx)
;---END
