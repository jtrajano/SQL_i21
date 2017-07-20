using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICInventoryReceiptLookUp
    {
        public int intInventoryReceiptId { get; set; }
        public string strVendorName { get; set; }
        public int? intEntityId { get; set; }
        public string strFobPoint { get; set; }
        public string strLocationName { get; set; }
        public string strCurrency { get; set; }
        public string strFromLocation { get; set; }
        public string strUserName { get; set; }
        public string strShipFrom { get; set; }
        public string strShipVia { get; set; }
        public string strFreightTerm { get; set; }
        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
    }
}
