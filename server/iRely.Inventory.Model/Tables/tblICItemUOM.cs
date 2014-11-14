using System;
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
        public int intUnitMeasureId { get; set; }
        public decimal? dblUnitQty { get; set; }
        public decimal? dblSellQty { get; set; }
        public decimal? dblWeight { get; set; }
        public string strDescription { get; set; }
        public decimal? dblLength { get; set; }
        public decimal? dblWidth { get; set; }
        public decimal? dblHeight { get; set; }
        public decimal? dblVolume { get; set; }
        public decimal? dblMaxQty { get; set; }

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
