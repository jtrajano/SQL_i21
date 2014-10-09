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
        public int? intUnitMeasureId { get; set; }
        public string strRinFeedStockUOMCode { get; set; }
        public int intSort { get; set; }

        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public ICollection<tblICFuelType> RinFeedStockUOMs { get; set; }
    }
}
