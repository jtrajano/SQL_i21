﻿using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IInventoryShipmentBl : IBusinessLayer<tblICInventoryShipment>
    {
        SaveResult PostTransaction(Common.Posting_RequestModel shipment, bool isRecap);
        SaveResult ProcessInvoice(int shipmentId, out int? newInvoice);
        Task<SearchResult> SearchShipmentItems(GetParameter param);
        Task<SearchResult> SearchShipmentItemLots(GetParameter param);
    }
}
