using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCategoryStore : BaseEntity
    {
        public int intCategoryStoreId { get; set; }
        public int intCategoryId { get; set; }
        public int intStoreId { get; set; }
        public int intRegisterDepartmentId { get; set; }
        public bool ysnUpdatePrices { get; set; }
        public bool ysnUseTaxFlag1 { get; set; }
        public bool ysnUseTaxFlag2 { get; set; }
        public bool ysnUseTaxFlag3 { get; set; }
        public bool ysnUseTaxFlag4 { get; set; }
        public bool ysnBlueLaw1 { get; set; }
        public bool ysnBlueLaw2 { get; set; }
        public int intNucleusGroupId { get; set; }
        public double dblTargetGrossProfit { get; set; }
        public double dblTargetInventoryCost { get; set; }
        public double dblCostInventoryBOM { get; set; }
        public double dblLowGrossMarginAlert { get; set; }
        public double dblHighGrossMarginAlert { get; set; }
        public DateTime dtmLastInventoryLevelEntry { get; set; }
    }
}
