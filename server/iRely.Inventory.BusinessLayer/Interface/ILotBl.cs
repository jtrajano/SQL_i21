﻿using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;


namespace iRely.Inventory.BusinessLayer
{
    public interface ILotBl : IBusinessLayer<tblICLot>
    {
        Task<SearchResult> GetHistory(GetParameter param);
        Task<SearchResult> GetLots(GetParameter param);
    }
}
