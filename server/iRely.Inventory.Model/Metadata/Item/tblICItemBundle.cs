﻿using System;
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
        public int? intSort { get; set; }

        private string _item;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_item))
                    if (BundleItem != null)
                        return BundleItem.strItemNo;
                    else
                        return null;
                else
                    return _item;
            }
            set
            {
                _item = value;
            }
        }
        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (tblICItemUOM != null)
                        return tblICItemUOM.strUnitMeasure;
                    else
                        return null;
                else
                    return _uom;
            }
            set
            {
                _uom = value;
            }
        }
        private decimal _unitQty;
        [NotMapped]
        public decimal dblUnit
        {
            get
            {
                if (tblICItemUOM != null)
                    return tblICItemUOM.dblUnitQty ?? 0;
                else
                    return 0;
            }
            set
            {
                _unitQty = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public tblICItem BundleItem { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }
    }

    public class vyuICGetBundleItem
    {
        public int intItemBundleId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intBundleItemId { get; set; }
        public string strComponent { get; set; }
        public string strComponentDescription { get; set; }
        public string strDescription { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public decimal? dblConversionFactor { get; set; }
        public string strUnitMeasure { get; set; }
        public decimal? dblUnitQty { get; set; }
        public int? intSort { get; set; }
    }

}
