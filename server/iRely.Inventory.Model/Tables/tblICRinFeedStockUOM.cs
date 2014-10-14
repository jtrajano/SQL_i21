using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICRinFeedStockUOM : BaseEntity
    {

        public int intRinFeedStockUOMId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public string strRinFeedStockUOMCode { get; set; }
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

        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public ICollection<tblICFuelType> RinFeedStockUOMs { get; set; }
    }
}
