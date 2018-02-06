using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemAddOn : BaseEntity
    {
        public int intItemAddOnId { get; set; }
        public int intItemId { get; set; }
        public int? intAddOnItemId { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intItemUOMId { get; set; }

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

        private string _strAddOnItemNo;
        [NotMapped]
        public string strAddOnItemNo {
            get
            {
                if (string.IsNullOrEmpty(_strAddOnItemNo))
                    if (AddOnItem != null)
                        return AddOnItem.strItemNo;
                    else
                        return null;
                else
                    return _strAddOnItemNo;
            }
            set
            {
                _strAddOnItemNo = value;
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

        public tblICItem tblICItem { get; set; }
        public tblICItem AddOnItem { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }

    }

    public class vyuICGetAddOnItem
    {
        public int intItemAddOnId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public int intAddOnItemId { get; set; }
        public string strAddOnItemNo { get; set; }
        public string strDescription { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
    }

    public class vyuICGetAddOnComponentStock : vyuICGetItemStock
    {
        public int intParentKey { get; set; }
        public int intAddOnItemId { get; set; }

        public int intParentItemAddOnId { get; set; }

        public string strParentItemAddOn { get; set; }

        public string strParentItemAddOnDesc { get; set; }

        public int? intAddOnItemUOMId { get; set; }

        public decimal? dblAddOnItemUOMId { get; set; }

        public string strAddOnItemUOM { get; set; }

        public int? intAddOnComponent { get; set; }

        public decimal? dblAddOnComponentQty { get; set; }
    }

}
