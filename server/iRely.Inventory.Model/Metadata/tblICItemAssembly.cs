using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemAssembly : BaseEntity
    {
        public int intItemAssemblyId { get; set; }
        public int intItemId { get; set; }
        public int? intAssemblyItemId { get; set; }
        public string strDescription { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public decimal? dblUnit { get; set; }
        public decimal? dblCost { get; set; }
        public int? intSort { get; set; }

        private string _item;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_item))
                    if (vyuICGetAssemblyItem != null)
                        return vyuICGetAssemblyItem.strComponentItem;
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
        private string _itemDesc;
        [NotMapped]
        public string strItemDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_itemDesc))
                    if (vyuICGetAssemblyItem != null)
                        return vyuICGetAssemblyItem.strComponentDescription;
                    else
                        return null;
                else
                    return _itemDesc;
            }
            set
            {
                _itemDesc = value;
            }
        }
        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (vyuICGetAssemblyItem != null)
                        return vyuICGetAssemblyItem.strComponentUOM;
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
        private decimal _uomCF;
        [NotMapped]
        public decimal dblComponentUOMCF
        {
            get
            {
                    if (vyuICGetAssemblyItem != null)
                        return vyuICGetAssemblyItem.dblComponentUOMCF ?? 0;
                    else
                        return _uomCF;
            }
            set
            {
                _uomCF = value;
            }
        }
        private decimal _unitLastCost;
        [NotMapped]
        public decimal dblUnitLastCost
        {
            get
            {
                if (vyuICGetAssemblyItem != null)
                    return vyuICGetAssemblyItem.dblUnitLastCost ?? 0;
                else
                    return _unitLastCost;
            }
            set
            {
                _unitLastCost = value;
            }
        }private decimal _lastCost;
        [NotMapped]
        public decimal dblLastCost
        {
            get
            {
                if (vyuICGetAssemblyItem != null)
                    return vyuICGetAssemblyItem.dblLastCost ?? 0;
                else
                    return _lastCost;
            }
            set
            {
                _lastCost = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public vyuICGetAssemblyItem vyuICGetAssemblyItem { get; set; }
    }

    public class vyuICGetAssemblyItem
    {
        public int intItemAssemblyId { get; set; }
        public int intItemId { get; set; }
        public int intAssemblyItemId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intLocationId { get; set; }
        public string strComponentItem { get; set; }
        public string strComponentDescription { get; set; }
        public string strComponentType { get; set; }
        public string strComponentLotTracking { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public string strComponentUOM { get; set; }
        public decimal? dblComponentUOMCF { get; set; }
        public decimal? dblUnit { get; set; }
        public decimal? dblCost { get; set; }
        public decimal? dblUnitLastCost { get; set; }
        public decimal? dblLastCost { get; set; }

        public tblICItemAssembly tblICItemAssembly { get; set; }
    }
}
