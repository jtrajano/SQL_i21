using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemPricing : BaseEntity
    {
        public int intItemPricingId { get; set; }
        public int intItemId { get; set; }
        public int intLocationId { get; set; }
        public double dblRetailPrice { get; set; }
        public double dblWholesalePrice { get; set; }
        public double dblLargeVolumePrice { get; set; }
        public double dblSalePrice { get; set; }
        public double dblMSRPPrice { get; set; }
        public string strPricingMethod { get; set; }
        public double dblLastCost { get; set; }
        public double dblStandardCost { get; set; }
        public double dblMovingAverageCost { get; set; }
        public double dblEndMonthCost { get; set; }
        public bool ysnActive { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }
    }
}
