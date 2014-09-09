using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICRinFeedStockUOM : BaseEntity
    {
        public int intRinFeedStockUOMId { get; set; }
        public int strRinFeedStockUOM { get; set; }
        public int strRinFeedStockUOMCode { get; set; }
        public int intSort { get; set; }
    }
}
