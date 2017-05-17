using iRely.Common;
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
        Common.GLPostResult PostTransaction(Common.Posting_RequestModel shipment, bool isRecap);
        SaveResult ProcessInvoice(int shipmentId, out int? newInvoice);
        SaveResult CalculateCharges(int shipmentId);
        void SetUser(int UserId);
        Task<SearchResult> SearchShipmentItems(GetParameter param);
        Task<SearchResult> SearchShipmentItemLots(GetParameter param);
        Task<SearchResult> GetAddOrders(GetParameter param, int CustomerId, string OrderType, string SourceType);
        Task<SearchResult> ShipmentInvoice(GetParameter param);
        SaveResult UpdateShipmentInvoice();
    }
}
