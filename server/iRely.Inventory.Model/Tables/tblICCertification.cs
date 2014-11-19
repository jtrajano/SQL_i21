using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
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
        public int? intCountryId { get; set; }
        public string strCertificationIdName { get; set; }

        public ICollection<tblICCertificationCommodity> tblICCertificationCommodities { get; set; }
        public ICollection<tblICItemCertification> tblICItemCertifications { get; set; }
    }

    public class tblICCertificationCommodity : BaseEntity
    {
        public int intCertificationCommodityId { get; set; }
        public int intCertificationId { get; set; }
        public int? intCommodityId { get; set; }
        public int? intCurrencyId { get; set; }
        public decimal? dblCertificationPremium { get; set; }
        public int? intUnitMeasureId { get; set; }
        public DateTime? dtmDateEffective { get; set; }
        public int intSort { get; set; }

        private string _commodity;
        [NotMapped]
        public string strCommodityCode
        {
            get
            {
                if (string.IsNullOrEmpty(_commodity))
                    if (tblICCommodity != null)
                        return tblICCommodity.strCommodityCode;
                    else
                        return null;
                else
                    return _commodity;
            }
            set
            {
                _commodity = value;
            }
        }
        private string _currency;
        [NotMapped]
        public string strCurrency
        {
            get
            {
                if (string.IsNullOrEmpty(_currency))
                    if (tblSMCurrency != null)
                        return tblSMCurrency.strCurrency;
                    else
                        return null;
                else
                    return _currency;
            }
            set
            {
                _currency = value;
            }
        }
        private string _uom;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_uom))
                    if (tblICUnitMeasure != null)
                        return tblICUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _uom;
            }
            set
            {
                _uom = value;
            }
        }

        public tblICCertification tblICCertification { get; set; }
        public tblICCommodity tblICCommodity { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public tblSMCurrency tblSMCurrency { get; set; }

    }
}
