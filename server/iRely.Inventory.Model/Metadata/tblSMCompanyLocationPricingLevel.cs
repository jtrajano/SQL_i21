using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblSMCompanyLocationPricingLevel : BaseEntity
    {
        public int intCompanyLocationPricingLevelId { get; set; }
        public int intCompanyLocationId { get; set; }
        public string strPricingLevelName { get; set; }
    }
}
