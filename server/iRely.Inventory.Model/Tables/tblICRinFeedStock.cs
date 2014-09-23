using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICRinFeedStock : BaseEntity
    {
        public int intRinFeedStockId { get; set; }
        public string strRinFeedStockCode { get; set; }
        public string strDescription { get; set; }
        public int intSort { get; set; }

        public ICollection<tblICFuelType> RinFeedStocks { get; set; }
    }
}
