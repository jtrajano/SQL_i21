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
        public int? intItemLocationId { get; set; }
        public string strPromotionType { get; set; }
        public DateTime? dtmBeginDate { get; set; }
        public DateTime? dtmEndDate { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public decimal? dblUnit { get; set; }
        public string strDiscountBy { get; set; }
        public decimal? dblDiscount { get; set; }
        public decimal? dblUnitAfterDiscount { get; set; }
        public decimal? dblDiscountThruQty { get; set; }
        public decimal? dblDiscountThruAmount { get; set; }
        public decimal? dblAccumulatedQty { get; set; }
        public decimal? dblAccumulatedAmount { get; set; }
        public int? intCurrencyId { get; set; }
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
        [NotMapped]
        public decimal? dblDiscountedPrice
        {
            get
            {
                if (strDiscountBy == "Percent")
                {
                    var discount = dblUnitAfterDiscount * dblDiscount / 100;
                    var discPrice = dblUnitAfterDiscount - discount;
                    return discPrice;
                }
                else if (strDiscountBy == "Amount")
                {
                    var discount = dblDiscount;
                    var discPrice = dblUnitAfterDiscount - discount;
                    return discPrice;
                }
                else
                    return 0;
            }
        }

        private string _currency;
        [NotMapped]
        public string strCurrency
        {
            get
            {
                if (string.IsNullOrEmpty(_currency))
                    if (tblSMCurrency != null)
                        return tblSMCurrency.strCurrency;
                    else
                        return null;
                else
                    return _currency;
            }
            set
            {
                _currency = value;
            }
        }
        public tblICItem tblICItem { get; set; }
        public tblICItemLocation tblICItemLocation { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }
        public tblSMCurrency tblSMCurrency { get; set; }
    }

    public class ItemSpecialPricingVM
    {
        public int intItemSpecialPricingId { get; set; }
        public int intItemId { get; set; }
        public int? intItemLocationId { get; set; }
        public string strPromotionType { get; set; }
        public DateTime? dtmBeginDate { get; set; }
        public DateTime? dtmEndDate { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public decimal? dblUnit { get; set; }
        public string strDiscountBy { get; set; }
        public decimal? dblDiscount { get; set; }
        public decimal? dblUnitAfterDiscount { get; set; }
        public decimal? dblDiscountThruQty { get; set; }
        public decimal? dblDiscountThruAmount { get; set; }
        public decimal? dblAccumulatedQty { get; set; }
        public decimal? dblAccumulatedAmount { get; set; }
        public int? intCurrencyId { get; set; }
        public int? intSort { get; set; }
        public string strLocationName { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUPC { get; set; }
        public decimal? dblDiscountedPrice { get; set; }
        public string strCurrency { get; set; }
        public int? intConcurrencyId { get; set; }
    }
}
