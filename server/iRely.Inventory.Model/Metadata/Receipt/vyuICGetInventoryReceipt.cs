using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceipt
    {
        public int intInventoryReceiptId { get; set; }
        public string strReceiptType { get; set; }
        public int? intSourceType { get; set; }
        public string strSourceType { get; set; }
        public int? intEntityVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public int? intTransferorId { get; set; }
        public string strTransferor { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strReceiptNumber { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
        public int? intSubCurrencyCents { get; set; }
        public int? intBlanketRelease { get; set; }
        public string strVendorRefNo { get; set; }
        public string strBillOfLading { get; set; }
        public int? intShipViaId { get; set; }
        public string strShipVia { get; set; }
        public int? intShipFromId { get; set; }
        public string strShipFrom { get; set; }
        public int? intReceiverId { get; set; }
        public string strReceiver { get; set; }
        public string strVessel { get; set; }
        public int? intFreightTermId { get; set; }
        public string strFreightTerm { get; set; }
        public string strFobPoint { get; set; }
        public int? intShiftNumber { get; set; }
        public decimal? dblInvoiceAmount { get; set; }
        public bool? ysnPrepaid { get; set; }
        public bool? ysnInvoicePaid { get; set; }
        public int? intCheckNo { get; set; }
        public DateTime? dtmCheckDate { get; set; }
        public int? intTrailerTypeId { get; set; }
        public DateTime? dtmTrailerArrivalDate { get; set; }
        public DateTime? dtmTrailerArrivalTime { get; set; }
        public string strSealNo { get; set; }
        public string strSealStatus { get; set; }
        public DateTime? dtmReceiveTime { get; set; }
        public decimal? dblActualTempReading { get; set; }
        public int? intShipmentId { get; set; }
        public int? intTaxGroupId { get; set; }
        public string strTaxGroup { get; set; }
        public bool? ysnPosted { get; set; }
        public int? intEntityId { get; set; }
        public string strEntityName { get; set; }
        public string strActualCostId { get; set; }
        public string strWarehouseRefNo { get; set; }
        public decimal? dblSubTotal { get; set; }
        public decimal? dblTotalTax { get; set; }
        public decimal? dblTotalCharges { get; set; }
        public decimal? dblTotalGross { get; set; }
        public decimal? dblTotalNet { get; set; }
        public decimal? dblGrandTotal { get; set; }

        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
    }
}
