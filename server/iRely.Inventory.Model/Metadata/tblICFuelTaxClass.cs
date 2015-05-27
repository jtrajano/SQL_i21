using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICFuelTaxClass : BaseEntity
    {
        public tblICFuelTaxClass()
        {
            this.tblICFuelTaxClassProductCodes = new List<tblICFuelTaxClassProductCode>();
        }

        public int intFuelTaxClassId { get; set; }
        public string strTaxClassCode { get; set; }
        public string strDescription { get; set; }
        public string strIRSTaxCode { get; set; }

        public ICollection<tblICFuelTaxClassProductCode> tblICFuelTaxClassProductCodes { get; set; }
    }

    public class tblICFuelTaxClassProductCode : BaseEntity
    {
        public int intFuelTaxClassProductCodeId { get; set; }
        public int intFuelTaxClassId { get; set; }
        public string strState { get; set; }
        public string strProductCode { get; set; }
        public int intSort { get; set; }

        public tblICFuelTaxClass tblICFuelTaxClass { get; set; }
    }
}
