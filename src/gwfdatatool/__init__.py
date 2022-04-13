# -*- coding: utf-8 -*-

'''
This is package providing a complete set of tools for
spatial/temporal subsetting on Compute Canada (CC) 
infrastructure

GWF Data Toolbox - A toolbox for forcing data processing 

Copyright (C) 2022 Global Water Futures (GWF);  University of Saskatchewan

This file is part of gwfdatatool

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

'''

from pkg_resources import get_distribution, DistributionNotFound

try:
    # Change here if project is renamed and does not equal the package name
    dist_name = 'gwfdatatool'
    __version__ = get_distribution(dist_name).version
except DistributionNotFound:
    __version__ = 'unknown'
finally:
    del get_distribution, DistributionNotFound

# importing core classes of the package
from gwfdata.tool import (
    GWFDataTool,
)
