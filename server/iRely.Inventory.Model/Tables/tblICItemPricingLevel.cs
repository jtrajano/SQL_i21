using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemPricingLevel : BaseEntity
    {
        public int intItemPricingLevelId { get; set; }
        public int intItemId { get; set; }
        public int intLocationId { get; set; }
        public string strPriceLevel { get; set; }
        public int intUnitMeasureId { get; set; }
        public double dblUnit { get; set; }
        public double dblMin { get; set; }
        public double dblMax { get; set; }
        public string strPricingMethod { get; set; }
        public string strCommissionOn { get; set; }
        public double dblCommissionRate { get; set; }
        public double dblUnitPrice { get; set; }
        public bool ysnActive { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }
    }
}
