using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCertification : BaseEntity
    {
        public int intCertificationId { get; set; }
        public string strCertificationName { get; set; }
        public string strIssuingOrganization { get; set; }
        public bool ysnGlobalCertification { get; set; }
        public int intCountryId { get; set; }
        public string strCertificationIdName { get; set; }

        public ICollection<tblICCertificationCommodity> tblICCertificationCommodities { get; set; }
        public ICollection<tblICItemCertification> tblICItemCertifications { get; set; }
    }

    public class tblICCertificationCommodity : BaseEntity
    {
        public int intCertificationCommodityId { get; set; }
        public int intCertificationId { get; set; }
        public int intCommodityId { get; set; }
        public int intCurrencyId { get; set; }
        public double dblCertificationPremium { get; set; }
        public int intUnitMeasureId { get; set; }
        public DateTime dtmDateEffective { get; set; }
        public int intSort { get; set; }

        public tblICCertification tblICCertification { get; set; }
    }
}
