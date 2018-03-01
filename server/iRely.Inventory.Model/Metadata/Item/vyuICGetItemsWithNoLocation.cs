using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemsWithNoLocation
    {
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strType { get; set; }
        public string strCommodityCode { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategoryCode { get; set; }
        public string strManufacturer { get; set; }
        public string strBrandName { get; set; }
        public int? intVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
    }
}
