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


    public class vyuICGetBundleItemStock : vyuICGetItemStock
    {
        public int intKitItemId { get; set; }
        public string strKitItemNo { get; set; }
        public string strKitItemDesc { get; set; }
        public decimal? dblComponentQuantity { get; set; }
        public decimal? dblMarkUpOrDown { get; set; }
        public DateTime? dtmBeginDate { get; set; }
        public DateTime? dtmEndDate { get; set; }
    }
}
