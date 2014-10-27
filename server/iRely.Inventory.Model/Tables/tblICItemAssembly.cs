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
        public int? intUnitMeasureId { get; set; }
        public decimal? dblUnit { get; set; }
        public decimal? dblCost { get; set; }
        public int intSort { get; set; }

        private string _item;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_item))
                    if (AssemblyItem != null)
                        return AssemblyItem.strItemNo;
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
                    if (tblICUnitMeasure != null)
                        return tblICUnitMeasure.strUnitMeasure;
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

        public tblICItem tblICItem { get; set; }
        public tblICItem AssemblyItem { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
    }
}
