using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemContract : BaseEntity
    {
        public int intItemContractId { get; set; }
        public int intItemId { get; set; }
        public int? intLocationId { get; set; }
        public string strContractItemName { get; set; }
        public int? intCountryId { get; set; }
        public string strGrade { get; set; }
        public string strGradeType { get; set; }
        public string strGarden { get; set; }
        public double dblYieldPercent { get; set; }
        public double dblTolerancePercent { get; set; }
        public double dblFranchisePercent { get; set; }
        public int intSort { get; set; }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblSMCompanyLocation != null)
                        return tblSMCompanyLocation.strLocationName;
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
        private string _country;
        [NotMapped]
        public string strCountry
        {
            get
            {
                if (string.IsNullOrEmpty(_country))
                    if (tblSMCountry != null)
                        return tblSMCountry.strCountry;
                    else
                        return null;
                else
                    return _country;
            }
            set
            {
                _country = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public tblSMCountry tblSMCountry { get; set; }

        public ICollection<tblICItemContractDocument> tblICItemContractDocuments { get; set; }

    }
}
