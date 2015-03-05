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
        public int intItemLocationId { get; set; }
        public string strLotNumber { get; set; }

        private int? _itemId;
        [NotMapped]
        public int? intItemId
        {
            get
            {
                if (tblICItemLocation != null)
                    return tblICItemLocation.intItemId;
                else
                    return null;
            }
            set
            {
                _itemId = value;
            }
        }

        public tblICInventoryReceiptItemLot tblICInventoryReceiptItemLot { get; set; }
        public tblICItemLocation tblICItemLocation { get; set; }
    }
}
