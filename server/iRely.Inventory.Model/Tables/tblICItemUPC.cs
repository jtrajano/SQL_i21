using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemUPC : BaseEntity
    {
        public int intItemUPCId { get; set; }
        public int intItemId { get; set; }
        public int intUnitMeasureId { get; set; }
        public double dblUnitQty { get; set; }
        public string strUPCCode { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }
    }
}
