using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICLot : BaseEntity
    {
        public int intLotId { get; set; }
        public int intItemId { get; set; }
        public int intItemLocationId { get; set; }
        public int? intItemUOMId { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strLotNumber { get; set; }
        public decimal? dblQty { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblWeightPerQty { get; set; }

        private string _itemUOM;
        [NotMapped]
        public string strItemUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_itemUOM))
                    if (tblICItemUOM != null)
                        return tblICItemUOM.strUnitMeasure;
                    else
                        return null;
                else
                    return _itemUOM;
            }
            set
            {
                _itemUOM = value;
            }
        }
        private string _itemWeightUOM;
        [NotMapped]
        public string strItemWeightUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_itemWeightUOM))
                    if (tblICItemUOM != null)
                        return WeightUOM.strUnitMeasure;
                    else
                        return null;
                else
                    return _itemWeightUOM;
            }
            set
            {
                _itemWeightUOM = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public tblICInventoryReceiptItemLot tblICInventoryReceiptItemLot { get; set; }
        public tblICItemLocation tblICItemLocation { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }
        public tblICItemUOM WeightUOM { get; set; }

        public ICollection<tblICInventoryAdjustmentDetail> tblICInventoryAdjustmentDetails { get; set; }
        public ICollection<tblICInventoryAdjustmentDetail> NewAdjustmentDetails { get; set; }

    }
}
