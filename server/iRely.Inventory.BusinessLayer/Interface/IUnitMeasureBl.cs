﻿using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IUnitMeasureBl : IBusinessLayer<tblICUnitMeasure>
    {
        Task<SearchResult> GetPackedUOMs(GetParameter param);
        Task<SearchResult> GetAreaLengthUOM(GetParameter param);
        Task<SearchResult> GetQuantityVolumeWeightPackedUOM(GetParameter param);
        Task<SearchResult> GetTimeUOM(GetParameter param);
    }
}
