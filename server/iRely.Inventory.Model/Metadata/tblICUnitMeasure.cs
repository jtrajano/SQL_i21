﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICUnitMeasure : BaseEntity
    {
        public int intUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strSymbol { get; set; }
        public string strUnitType { get; set; }

        public ICollection<tblICUnitMeasureConversion> tblICUnitMeasureConversions { get; set; }

        public ICollection<tblICCategory> tblICCategories { get; set; }
        public ICollection<tblICCommodityUnitMeasure> tblICCommodityUnitMeasures { get; set; }
        public ICollection<tblICItemUOM> tblICItemUOMs { get; set; }
        public ICollection<tblICStorageUnitType> CapacityUnitTypes { get; set; }
        public ICollection<tblICStorageUnitType> DimensionUnitTypes { get; set; }
        public ICollection<tblICRinFeedStockUOM> tblICRinFeedStockUOMs { get; set; }
        
        public ICollection<tblICUnitMeasureConversion> StockUnitMeasureConversions { get; set; }

        public ICollection<tblICCertificationCommodity> tblICCertificationCommodities { get; set; }
        
        public ICollection<tblICItemUOM> WeightItemUOMs { get; set; }
        public ICollection<tblICItemUOM> DimensionItemUOMs { get; set; }
        public ICollection<tblICItemUOM> VolumeItemUOMs { get; set; }

        public ICollection<tblICCategoryUOM> tblICCategoryUOMs { get; set; }
        
        public ICollection<vyuICGetUOMConversion> vyuICGetUOMConversions { get; set; }
        public ICollection<tblICCommodityOrigin> tblICCommodityOrigins { get; set; }
    }

    public class tblICUnitMeasureConversion : BaseEntity
    {
        public int? intUnitMeasureConversionId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public int? intStockUnitMeasureId { get; set; }
        public decimal? dblConversionToStock { get; set; }
        public int? intSort { get; set; }

        private string _unitmeasure;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_unitmeasure))
                    if (StockUnitMeasure != null)
                        return StockUnitMeasure.strUnitMeasure;
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

        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public tblICUnitMeasure StockUnitMeasure { get; set; }
    }

    public class vyuICGetPackedUOM
    {
        [Key]
        public int intUnitMeasureConversionId { get; set; }
        public int intUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public string strSymbol { get; set; }
        public int? intStockUnitMeasureId { get; set; }
        public string strConversionUOM { get; set; }
        public decimal? dblConversionToStock { get; set; }
    }

    public class vyuICGetUOMConversion
    {
        [Key]
        public int intUnitMeasureConversionId { get; set; }
        public int intUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
        public int? intStockUnitMeasureId { get; set; }
        public string strStockUOM { get; set; }
        public decimal? dblConversionToStock { get; set; }

        public tblICUnitMeasure tblICUnitMeasure { get; set; }
    }
}
