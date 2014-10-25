using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
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
        public int? intLocationId { get; set; }
        public string strPriceLevel { get; set; }
        public int? intUnitMeasureId { get; set; }
        public double dblUnit { get; set; }
        public double dblMin { get; set; }
        public double dblMax { get; set; }
        public string strPricingMethod { get; set; }
        public string strCommissionOn { get; set; }
        public double dblCommissionRate { get; set; }
        public double dblUnitPrice { get; set; }
        public bool ysnActive { get; set; }
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
