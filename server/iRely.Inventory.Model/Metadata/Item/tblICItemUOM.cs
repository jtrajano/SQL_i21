﻿using System;
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
        public string strLongUPCCode { get; set; }
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
        public bool? ysnStockUOM { get; set; }

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
        public ICollection<tblICItemBundle> tblICItemBundles { get; set; }
        public ICollection<tblICItemUPC> tblICItemUPCs { get; set; }

        public ICollection<tblICBuildAssemblyDetail> tblICBuildAssemblyDetails { get; set; }
        public ICollection<tblICBuildAssembly> tblICBuildAssemblies { get; set; }
        public ICollection<tblICItemAddOn> tblICItemAddOns { get; set; }

        public ICollection<tblICItemSubstitute> tblICItemSubstitutes { get; set; }

    }

    public class ItemUOMVM
    {
        public int intItemUOMId { get; set; }
        public int intItemId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public decimal? dblUnitQty { get; set; }
        public decimal? dblWeight { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strUpcCode { get; set; }
        public string strLongUPCCode { get; set; }
        public bool ysnStockUnit { get; set; }
        public bool ysnAllowPurchase { get; set; }
        public bool ysnAllowSale { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public string strWeightUOM { get; set; }
    }

    public class WeightUOMVm
    {
        public int intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public int intItemId { get; set; }
        public decimal dblUnitQty { get; set; }
        public bool ysnStockUnit { get; set; }
        public bool ysnAllowPurchase { get; set; }
        public bool ysnAllowSale { get; set; }
    }

    public class vyuICItemUOM
    {
        public int intItemUOMId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strType { get; set; }
        public int intItemId { get; set; }
        public string strCategoryCode { get; set; }
        public string strCategory { get; set; }
        public int? intCategoryId { get; set; }
        public string strCommodity { get; set; }
        public string strCommodityCode { get; set; }
        public int? intCommodityId { get; set; }
        public string strStockUOM { get; set; }
        public string strUnitMeasure { get; set; }
        public bool ysnStockUnit { get; set; }
        public bool ysnAllowPurchase { get; set; }
        public bool ysnAllowSale { get; set; }
        public decimal? dblMaxQty { get; set; }
        public decimal? dblUnitQty { get; set; }
        public decimal? dblHeight { get; set; }
        public decimal? dblLength { get; set; }
        public decimal? dblWeight { get; set; }
        public decimal? dblVolume { get; set; }
    }
}
