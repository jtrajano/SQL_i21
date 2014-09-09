using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCategoryVendor : BaseEntity
    {
        public int intCategoryVendorId { get; set; }
        public int intCategoryId { get; set; }
        public int intStoreId { get; set; }
        public int intVendorId { get; set; }
        public int strVendorDepartment { get; set; }
        public bool ysnAddOrderingUPC { get; set; }
        public bool ysnUpdateExistingRecords { get; set; }
        public bool ysnAddNewRecords { get; set; }
        public bool ysnUpdatePrice { get; set; }
        public int intFamilyId { get; set; }
        public int intSellClassId { get; set; }
        public int intOrderClassId { get; set; }
        public int strComments { get; set; }
    }
}
