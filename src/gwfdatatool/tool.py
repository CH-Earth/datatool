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

import warnings

import xarray as xr

from tqdm.auto import tqdm, trange

from typing import (
    Tuple,
    Dict,
    Optional,
)

<<<<<<< HEAD
=======
from collection.abc import (

)

>>>>>>> 1be4474b0cb74c28c6de48f2f48ed99a1d18f813
from __future__ import (
    annotations,
)

class GWFDataTool(object):
    """
<<<<<<< HEAD
    Main class to process and subset pre-defined
=======
    Main class to process and subset defined
>>>>>>> 1be4474b0cb74c28c6de48f2f48ed99a1d18f813
    meteorological datasets.

    ...

    Attributes
    ----------

    Methods
    -------

    """
    def __init__(
        dataset: str,
        variables: Tuple[str, ...],
        time_lims: Dict[str, str],
<<<<<<< HEAD
        return_method: str,
        space_lims: Optional[Tuple[float, ...]] = None,
=======
        space_lims: Optional[Tuple[float, ...]] = None,
        return_method: str,
>>>>>>> 1be4474b0cb74c28c6de48f2f48ed99a1d18f813
        esri_shapefile: Optional[str] = None,
        slurm_job: bool = False,
    ):

    @classmethod
    def from_json(
        cls,
        json_string: str,
    ) -> GWFDataTool:
<<<<<<< HEAD
        toolset = cls(
            ...,
            return_method='globus',
            ...,
        )
=======
        toolset = cls(...)
>>>>>>> 1be4474b0cb74c28c6de48f2f48ed99a1d18f813
        
        return toolset

    @classmethod
    def from_dict(
        cls,
        dict_object: str,
    ) -> GWFDataTool:

        toolset = cls(...)

        return toolset

    @classmethod
    def from_yaml(
        cls,
        yaml_string: str,
    ) -> GWFDataTool:

        toolset = cls(...)

        return toolset


