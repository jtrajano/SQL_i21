using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemSpecialPricing : BaseEntity
    {
        public int intItemSpecialPricingId { get; set; }
        public int intItemId { get; set; }
        public int intLocationId { get; set; }
        public string strPromotionType { get; set; }
        public DateTime dtmBeginDate { get; set; }
        public DateTime dtmEndDate { get; set; }
        public int intUnitMeasureId { get; set; }
        public double dblUnit { get; set; }
        public string strDiscountBy { get; set; }
        public double dblDiscount { get; set; }
        public double dblUnitAfterDiscount { get; set; }
        public double dblAccumulatedQty { get; set; }
        public double dblAccumulatedAmount { get; set; }
        public int intSort { get; set; }

        public tblICItem tblICItem { get; set; }
    }
}
