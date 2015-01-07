using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemStock : BaseEntity
    {
        public int intItemStockId { get; set; }
        public int intItemId { get; set; }
        public int? intLocationId { get; set; }
        public int intSubLocationId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public decimal? dblAverageCost { get; set; }
        public decimal? dblUnitOnHand { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblLastCountRetail { get; set; }
        public int intSort { get; set; }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblSMCompanyLocation != null)
                        return tblSMCompanyLocation.strLocationName;
                    else
                        return null;
                else
                    return _location;
            }
            set
            {
                _location = value;
            }
        }
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
        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
    }
}
