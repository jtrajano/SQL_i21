using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
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
        public int? intLocationId { get; set; }
        public string strPromotionType { get; set; }
        public DateTime dtmBeginDate { get; set; }
        public DateTime dtmEndDate { get; set; }
        public int? intUnitMeasureId { get; set; }
        public double dblUnit { get; set; }
        public string strDiscountBy { get; set; }
        public double dblDiscount { get; set; }
        public double dblUnitAfterDiscount { get; set; }
        public double dblAccumulatedQty { get; set; }
        public double dblAccumulatedAmount { get; set; }
        public int intSort { get; set; }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblSMCompanyLocation != null)
                        return tblSMCompanyLocation.strLocationName;
                    else
                        return null;
                else
                    return _location;
            }
            set
            {
                _location = value;
            }
        }
        private string _unitmeasure;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_unitmeasure))
                    if (tblICUnitMeasure != null)
                        return tblICUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _unitmeasure;
            }
            set
            {
                _unitmeasure = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
    }
}
