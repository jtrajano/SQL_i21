using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemUOM : BaseEntity
    {
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public int intManufacturerId { get; set; }
        public int intBrandId { get; set; }
        public string strStatus { get; set; }
        public string strModelNo { get; set; }
        public int intTrackingId { get; set; }
        public string strLotTracking { get; set; }
    }
}
