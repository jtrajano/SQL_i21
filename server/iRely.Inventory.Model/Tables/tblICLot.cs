using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICLot : BaseEntity
    {
        public int intLotId { get; set; }
        public string strLotId { get; set; }

        public tblICInventoryReceiptItemLot tblICInventoryReceiptItemLot { get; set; }
    }
}
