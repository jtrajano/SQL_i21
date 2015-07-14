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
        public int? intItemLocationId { get; set; }
        public decimal? dblUnitOnHand { get; set; }
        public decimal? dblUnitInCustody { get; set; }
        public decimal? dblUnitInConsigned { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblBackOrder { get; set; }
        public decimal? dblLastCountRetail { get; set; }
        public int? intSort { get; set; }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblICItemLocation != null)
                        return tblICItemLocation.strLocationName;
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
        
        public tblICItem tblICItem { get; set; }
        public tblICItemLocation tblICItemLocation { get; set; }
    }

    public class ItemStockVM
    {
        public int intItemStockId { get; set; }
        public int intItemId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public decimal? dblUnitOnHand { get; set; }
        public decimal? dblUnitInCustody { get; set; }
        public decimal? dblUnitInConsigned { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblBackOrder { get; set; }
        public decimal? dblLastCountRetail { get; set; }
        
        public string strItemNo { get; set; }
        public string strLocationName { get; set; }
        public string strSubLocationName { get; set; }

    }
}
