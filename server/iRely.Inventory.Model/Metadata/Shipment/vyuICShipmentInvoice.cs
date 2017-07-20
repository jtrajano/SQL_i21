using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICShipmentInvoice
    {
        public int intInventoryShipmentId { get; set; }
        public int? intInventoryShipmentItemId { get; set; }
        public int? intInventoryShipmentChargeId { get; set; }
        public string strShipmentNumber { get; set; }
        public DateTime? dtmShipDate { get; set; }
        public string strCustomer { get; set; }
        public string strLocationName { get; set; }
        public string strDestination { get; set; }
        public string strBOLNumber { get; set; }
        public string strOrderType { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public decimal? dblUnitCost { get; set; }
        public decimal? dblShipmentQty { get; set; }
        public decimal? dblInTransitQty { get; set; }
        public decimal? dblInvoiceQty { get; set; }
        public decimal? dblShipmentLineTotal { get; set; }
        public decimal? dblInTransitTotal { get; set; }
        public decimal? dblInvoiceLineTotal { get; set; }
        public decimal? dblShipmentTax { get; set; }
        public decimal? dblInvoiceTax { get; set; }
        public decimal? dblOpenQty { get; set; }
        public decimal? dblItemsReceivable { get; set; }
        public decimal? dblTaxesReceivable { get; set; }
        public DateTime? dtmLastInvoiceDate { get; set; }
        public string strAllVouchers { get; set; }
        public string strFilterString { get; set; }
        public DateTime? dtmCreated { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
        public string strItemUOM { get; set; }
        public int? intItemUOMId { get; set; }
    }
}
