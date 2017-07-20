using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptItemView
    {
        public int intInventoryReceiptId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public int intItemId { get; set; }
        public int intSourceId { get; set; }
        public decimal? dblReceived { get; set; }
        public decimal? dblBillQty { get; set; }
        public string strSourceType { get; set; }
        public string strOrderNumber { get; set; }
        public string strSourceNumber { get; set; }
        public int intRecordNo { get; set; }
    }
}
