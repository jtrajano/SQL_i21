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
        Task <int?> ProcessShipmentToInvoice(int shipmentId);
        SaveResult CalculateCharges(int shipmentId);
        void SetUser(int UserId);
        Task<SearchResult> SearchShipmentItems(GetParameter param);
        Task<SearchResult> SearchShipmentItemLots(GetParameter param);
        Task<SearchResult> GetAddOrders(GetParameter param, int CustomerId, string OrderType, string SourceType);
        Task<SearchResult> SearchShipmentInvoice(GetParameter param);
        Task<SearchResult> SearchCustomerCurrency(GetParameter param, int? entityId);
        SaveResult UpdateShipmentInvoice();
    }
}
