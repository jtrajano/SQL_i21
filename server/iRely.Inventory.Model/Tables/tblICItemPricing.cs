using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
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
        public int? intItemLocationId { get; set; }
        public decimal? dblAmountPercent { get; set; }
        public decimal? dblSalePrice { get; set; }
        public decimal? dblMSRPPrice { get; set; }
        public string strPricingMethod { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblStandardCost { get; set; }
        public decimal? dblAverageCost { get; set; }
        public decimal? dblEndMonthCost { get; set; }
        public int? intSort { get; set; }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblICItemLocation != null)
                        return tblICItemLocation.strLocationName;
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

        public tblICItem tblICItem { get; set; }
        public tblICItemLocation tblICItemLocation { get; set; }
    }
}
