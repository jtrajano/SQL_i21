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
        public int? intItemLocationId { get; set; }
        public string strPriceLevel { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public decimal? dblUnit { get; set; }
        public decimal? dblMin { get; set; }
        public decimal? dblMax { get; set; }
        public string strPricingMethod { get; set; }
        public decimal? dblAmountRate { get; set; }
        public decimal? dblUnitPrice { get; set; }
        public string strCommissionOn { get; set; }
        public decimal? dblCommissionRate { get; set; }
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
        private string _unitmeasure;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_unitmeasure))
                    if (tblICItemUOM != null)
                        return tblICItemUOM.strUnitMeasure;
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
        private string _upc;
        [NotMapped]
        public string strUPC
        {
            get
            {
                if (string.IsNullOrEmpty(_upc))
                    if (tblICItemUOM != null)
                        return tblICItemUOM.strUpcCode;
                    else
                        return null;
                else
                    return _upc;
            }
            set
            {
                _upc = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public tblICItemLocation tblICItemLocation { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }
    }
}
