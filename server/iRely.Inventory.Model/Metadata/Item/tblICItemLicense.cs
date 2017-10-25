using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICItemLicense : BaseEntity
    {
        public int intItemLicenseId { get; set; }
        public int intItemId { get; set; }
        public int intLicenseTypeId { get; set; }

        public tblICItem tblICItem { get; set; }
        public tblSMLicenseType tblSMLicenseType { get; set; }
    }

    public class vyuICItemLicense
    {
        public int intItemLicenseId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int intLicenseTypeId { get; set; }
        public string strCode { get; set; }
        public string strCodeDescription { get; set; }
        public int intConcurrencyId { get; set; }
    }
}
