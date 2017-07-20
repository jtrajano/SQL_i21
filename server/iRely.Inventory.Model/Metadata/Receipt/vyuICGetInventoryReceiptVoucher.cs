using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptVoucher
    {
        public int intInventoryReceiptId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public string strVendor { get; set; }
        public string strLocationName { get; set; }
        public string strReceiptNumber { get; set; }
        public string strBillOfLading { get; set; }
        public string strReceiptType { get; set; }
        public string strOrderNumber { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public decimal? dblUnitCost { get; set; }
        public decimal? dblReceiptQty { get; set; }
        public decimal? dblVoucherQty { get; set; }
        public decimal? dblReceiptLineTotal { get; set; }
        public decimal? dblVoucherLineTotal { get; set; }
        public decimal? dblReceiptTax { get; set; }
        public decimal? dblVoucherTax { get; set; }
        public decimal? dblOpenQty { get; set; }
        public decimal? dblItemsPayable { get; set; }
        public decimal? dblTaxesPayable { get; set; }
        public DateTime? dtmLastVoucherDate { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
        public string strAllVouchers { get; set; }
        public string strFilterString { get; set; }
        public string strContainerNumber { get; set; }
        public int? intLoadContainerId { get; set; }
        public string strItemUOM { get; set; }
        public int? intItemUOMId { get; set; }
        public string strCostUOM { get; set; }
        public int? intCostUOMId { get; set; }
        public bool? ysnBundleItem { get; set; }
        public int? intBundledItemId { get; set; }
        public string strBundledItemNo { get; set; }

    }
}
