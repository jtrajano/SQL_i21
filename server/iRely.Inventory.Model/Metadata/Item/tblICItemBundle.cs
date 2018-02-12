using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemBundle : BaseEntity
    {
        public int intItemBundleId { get; set; }
        public int intItemId { get; set; }
        public int? intBundleItemId { get; set; }
        public string strDescription { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public bool ysnAddOn { get; set; }
        public decimal? dblMarkUpOrDown { get; set; }
        public DateTime? dtmBeginDate { get; set; }
        public DateTime? dtmEndDate { get; set; }

        private string _strItemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_strItemNo))
                    if (tblICItem != null)
                        return tblICItem.strItemNo;
                    else
                        return null;
                else
                    return _strItemNo;
            }
            set
            {
                _strItemNo = value;
            }
        }

        private string _strComponentItemNo;
        [NotMapped]
        public string strComponentItemNo {
            get
            {
                if (string.IsNullOrEmpty(_strComponentItemNo))
                    if (BundleItem != null)
                        return BundleItem.strItemNo;
                    else
                        return null;
                else
                    return _strComponentItemNo;
            }
            set
            {
                _strComponentItemNo = value;
            }
        }

        private string _strUnitMeasure;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_strUnitMeasure))
                    if (tblICItemUOM != null)
                        return tblICItemUOM.tblICUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _strUnitMeasure;
            }
            set
            {
                _strUnitMeasure = value;
            }
        }

        //public vyuICGetBundleItem vyuICGetBundleItem { get; set; }

        public tblICItem tblICItem { get; set; }
        public tblICItem BundleItem { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }

    }

    public class vyuICGetBundleItem
    {
        public int intItemBundleId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public int intBundleItemId { get; set; }
        public string strComponentItemNo { get; set; }
        public string strDescription { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
        public decimal? dblMarkUpOrDown { get; set; }
        public DateTime? dtmBeginDate { get; set; }
        public DateTime? dtmEndDate { get; set; }
    }


    public class vyuICGetBundleItemStock
    {
        public int intKey { get; set; }
        public int? intBundleItemId { get; set; }
        public string strBundleItemNo { get; set; }
        public string strBundleItemDesc { get; set; }
        public string strBundleType { get; set; }

        public int? intComponentItemId { get; set; }
        public string strComponentItemNo { get; set; }
        public string strComponentType { get; set; }
        public string strComponentDescription { get; set; }
        public decimal? dblComponentQuantity { get; set; }
        public int? intComponentUOMId { get; set; }
        public string strComponentUOM { get; set; }
        public string strComponentUOMType { get; set; }
        public decimal? dblComponentConvFactor { get; set; }
        public decimal? dblMarkUpOrDown { get; set; }
        public DateTime? dtmBeginDate { get; set; }
        public DateTime? dtmEndDate { get; set; }


        public string strLotTracking { get; set; }
        public string strInventoryTracking { get; set; }
        public string strStatus { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategoryCode { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodityCode { get; set; }
        public string strStorageLocationName { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intStockUOMId { get; set; }
        public string strStockUOM { get; set; }
        public string strStockUOMType { get; set; }
        public decimal? dblStockUnitQty { get; set; }
        public string strAllowNegativeInventory { get; set; }
        public int? intCostingMethod { get; set; }
        public string strCostingMethod { get; set; }
        public decimal? dblAmountPercent { get; set; }
        public decimal? dblSalePrice { get; set; }
        public decimal? dblMSRPPrice { get; set; }
        public string strPricingMethod { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblStandardCost { get; set; }
        public decimal? dblAverageCost { get; set; }
        public decimal? dblEndMonthCost { get; set; }

        public int? intGrossUOMId { get; set; }
        public decimal? dblGrossUOMConvFactor { get; set; }
        public string strGrossUOMType { get; set; }
        public string strGrossUOM { get; set; }
        public string strGrossUPC { get; set; }
        public string strGrossLongUPC { get; set; }

        public decimal? dblDefaultFull { get; set; }
        public bool? ysnAvailableTM { get; set; }
        public decimal? dblMaintenanceRate { get; set; }
        public string strMaintenanceCalculationMethod { get; set; }
        public decimal? dblOverReceiveTolerance { get; set; }
        public decimal? dblWeightTolerance { get; set; }
        public int? intGradeId { get; set; }
        public string strGrade { get; set; }
        public int? intLifeTime { get; set; }
        public string strLifeTimeType { get; set; }
        public bool? ysnListBundleSeparately { get; set; }
        public string strRequired { get; set; }
        public int? intTonnageTaxUOMId { get; set; }
        public int? intModuleId { get; set; }
        public bool? ysnUseWeighScales { get; set; }
        public bool? ysnLotWeightsRequired { get; set; }
    }
}
