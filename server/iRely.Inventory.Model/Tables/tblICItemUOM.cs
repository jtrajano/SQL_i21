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
        public int? intUnitMeasureId { get; set; }
        public decimal? dblUnitQty { get; set; }
        public decimal? dblWeight { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strUpcCode { get; set; }
        public bool ysnStockUnit { get; set; }
        public bool ysnAllowPurchase { get; set; }
        public bool ysnAllowSale { get; set; }
        public decimal? dblLength { get; set; }
        public decimal? dblWidth { get; set; }
        public decimal? dblHeight { get; set; }
        public int? intDimensionUOMId { get; set; }
        public decimal? dblVolume { get; set; }
        public int? intVolumeUOMId { get; set; }
        public decimal? dblMaxQty { get; set; }
        public int? intSort { get; set; }

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
        private string _unitType;
        [NotMapped]
        public string strUnitType
        {
            get
            {
                if (string.IsNullOrEmpty(_unitType))
                    if (tblICUnitMeasure != null)
                        return tblICUnitMeasure.strUnitType;
                    else
                        return null;
                else
                    return _unitType;
            }
            set
            {
                _unitType = value;
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
        private string _weightUOM;
        [NotMapped]
        public string strWeightUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_weightUOM))
                    if (WeightUOM != null)
                        return WeightUOM.strUnitMeasure;
                    else
                        return null;
                else
                    return _weightUOM;
            }
            set
            {
                _weightUOM = value;
            }
        }
        private string _dimensionUOM;
        [NotMapped]
        public string strDimensionUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_dimensionUOM))
                    if (DimensionUOM != null)
                        return DimensionUOM.strUnitMeasure;
                    else
                        return null;
                else
                    return _dimensionUOM;
            }
            set
            {
                _dimensionUOM = value;
            }
        }
        private string _volumeUOM;
        [NotMapped]
        public string strVolumeUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_volumeUOM))
                    if (VolumeUOM != null)
                        return VolumeUOM.strUnitMeasure;
                    else
                        return null;
                else
                    return _volumeUOM;
            }
            set
            {
                _volumeUOM = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public tblICUnitMeasure WeightUOM { get; set; }
        public tblICUnitMeasure DimensionUOM { get; set; }
        public tblICUnitMeasure VolumeUOM { get; set; }

        public ICollection<tblICItemVendorXref> tblICItemVendorXrefs { get; set; }
        public ICollection<tblICItemPricingLevel> tblICItemPricingLevels { get; set; }
        public ICollection<tblICItemSpecialPricing> tblICItemSpecialPricings { get; set; }
        public ICollection<tblICItemKitDetail> tblICItemKitDetails { get; set; }
        public ICollection<tblICItemAssembly> tblICItemAssemblies { get; set; }
        public ICollection<tblICItemBundle> tblICItemBundles { get; set; }
        public ICollection<tblICItemUPC> tblICItemUPCs { get; set; }
    }

}
