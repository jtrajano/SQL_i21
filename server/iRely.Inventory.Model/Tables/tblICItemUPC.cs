using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemUPC : BaseEntity
    {
        public int intItemUPCId { get; set; }
        public int intItemId { get; set; }
        public int intUnitMeasureId { get; set; }
        public double dblUnitQty { get; set; }
        public string strUPCCode { get; set; }
        public int intSort { get; set; }

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

        public tblICItem tblICItem { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }

    }
}
