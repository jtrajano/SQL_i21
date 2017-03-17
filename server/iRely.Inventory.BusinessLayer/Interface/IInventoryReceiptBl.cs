using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer; 

namespace iRely.Inventory.BusinessLayer
{
    public interface IInventoryReceiptBl : IBusinessLayer<tblICInventoryReceipt>
    {
        SaveResult ProcessBill(int receiptId, out int? newBill, out string newBills);
        SaveResult CalculateCharges(int receiptId);
        //SaveResult PostReceive(Common.Posting_RequestModel receipt, bool isRecap);
        //SaveResult PostReturn(Common.Posting_RequestModel receipt, bool isRecap);
        Common.GLPostResult PostReceive(Common.Posting_RequestModel receipt, bool isRecap);
        Common.GLPostResult PostReturn(Common.Posting_RequestModel receipt, bool isRecap);
        void SetUser(int UserId);
        Task<SearchResult> SearchReceiptItems(GetParameter param);
        Task<SearchResult> SearchReceiptItemView(GetParameter param);
        Task<SearchResult> SearchReceiptItemLots(GetParameter param);
        Task<SearchResult> GetAddOrders(GetParameter param, int VendorId, string ReceiptType, int SourceType, int CurrencyId);
        Task<SearchResult> GetReceiptVouchers(GetParameter param);
        SaveResult UpdateReceiptInspection(int receiptId);
        SaveResult GetTaxGroupId(int receiptId, out int? taxGroup, out string taxGroupName);
        Task<SearchResult> GetChargeTaxDetails(GetParameter param, int ChargeId, int ReceiptId);
        SaveResult GetStatusUnitCost(int receiptId, out int? newStatus);
        SaveResult ReturnReceipt(int receiptId, out int? inventoryReturnId);
        Task<SearchResult> SearchReceiptCharges(GetParameter param);
        SaveResult UpdateReceiptVoucher();
        SaveResult CheckReceiptForValidReturn(int? receiptId);
        SaveResult GetDefaultReceiptTaxGroupId(int? freightTermId, int? locationId, int? entityVendorId, int? entityLocationId, out int? taxGroup, out string taxGroupName);
    }
}
