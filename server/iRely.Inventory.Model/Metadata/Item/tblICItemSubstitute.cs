using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemSubstitute : BaseEntity
    {
        public int intItemSubstituteId { get; set; }
        public int intItemId { get; set; }
        public int? intSubstituteItemId { get; set; }
        public decimal? dblQuantity { get; set; }
        public decimal? dblMarkUpOrDown { get; set; }
        public int? intItemUOMId { get; set; }

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

        private string _strSubstituteItemNo;
        [NotMapped]
        public string strSubstituteItemNo {
            get
            {
                if (string.IsNullOrEmpty(_strSubstituteItemNo))
                    if (SubstituteItem != null)
                        return SubstituteItem.strItemNo;
                    else
                        return null;
                else
                    return _strSubstituteItemNo;
            }
            set
            {
                _strSubstituteItemNo = value;
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
        public tblICItem SubstituteItem { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }

    }

    public class vyuICGetSubstituteItem
    {
        public int intItemSubstituteId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public int intSubstituteItemId { get; set; }
        public string strSubstituteItemNo { get; set; }
        public string strDescription { get; set; }
        public decimal? dblQuantity { get; set; }
        public decimal? dblMarkUpOrDown { get; set; }
        public DateTime? dtmBeginDate { get; set; }
        public DateTime? dtmEndDate { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
    }

    public class vyuICGetSubstituteComponentStock : vyuICGetItemStock
    {
        public int intParentKey { get; set; }
        public int intItemSubstituteId { get; set; }
        public int intParentItemSubstituteId { get; set; }
        public string strParentItemSubstitute { get; set; }
        public string strParentItemSubstituteDesc { get; set; }
        public int? intSubstituteItemUOMId { get; set; }
        public decimal? dblSubstituteItemUOMId { get; set; }
        public string strSubstituteItemUOM { get; set; }
        public int? intSubstituteComponent { get; set; }
        public decimal? dblSubstituteComponentQty { get; set; }
        public decimal? dblSubstituteMarkUpOrDown { get; set; }
        public DateTime? dtmSubstituteBeginDate { get; set; }
        public DateTime? dtmSubstituteEndDate { get; set; }
    }

}
