using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemUOM : BaseEntity
    {
        public int intItemUOMId { get; set; }
        public int intItemId { get; set; }
        public int intUnitMeasureId { get; set; }
        public decimal? dblUnitQty { get; set; }
        public decimal? dblSellQty { get; set; }
        public decimal? dblWeight { get; set; }
        public string strDescription { get; set; }
        public string strUpcCode { get; set; }
        public bool ysnStockUnit { get; set; }
        public bool ysnAllowPurchase { get; set; }
        public bool ysnAllowSale { get; set; }
        public decimal? dblConvertToStock { get; set; }
        public decimal? dblConvertFromStock { get; set; }
        public decimal? dblLength { get; set; }
        public decimal? dblWidth { get; set; }
        public decimal? dblHeight { get; set; }
        public decimal? dblVolume { get; set; }
        public decimal? dblMaxQty { get; set; }

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
        private int _calculation;
        [NotMapped]
        public int intDecimalCalculation
        {
            get
            {
                if (tblICUnitMeasure != null)
                    return tblICUnitMeasure.intDecimalCalculation;
                else
                    return 2;
            }
            set
            {
                _calculation = value;
            }
        }
        private int _display;
        [NotMapped]
        public int intDecimalDisplay
        {
            get
            {
                if (tblICUnitMeasure != null)
                    return tblICUnitMeasure.intDecimalDisplay;
                else
                    return 2;
            }
            set
            {
                _display = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public ICollection<tblICItemPricing> tblICItemPricings { get; set; }
        public ICollection<tblICItemPricingLevel> tblICItemPricingLevels { get; set; }
        public ICollection<tblICItemSpecialPricing> tblICItemSpecialPricings { get; set; }
    }
}
