using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCategoryLocation : BaseEntity
    {
        public int intCategoryLocationId { get; set; }
        public int intCategoryId { get; set; }
        public int intLocationId { get; set; }
        public int? intRegisterDepartmentId { get; set; }
        public bool ysnUpdatePrices { get; set; }
        public bool ysnUseTaxFlag1 { get; set; }
        public bool ysnUseTaxFlag2 { get; set; }
        public bool ysnUseTaxFlag3 { get; set; }
        public bool ysnUseTaxFlag4 { get; set; }
        public bool ysnBlueLaw1 { get; set; }
        public bool ysnBlueLaw2 { get; set; }
        public int? intNucleusGroupId { get; set; }
        public decimal? dblTargetGrossProfit { get; set; }
        public decimal? dblTargetInventoryCost { get; set; }
        public decimal? dblCostInventoryBOM { get; set; }
        public decimal? dblLowGrossMarginAlert { get; set; }
        public decimal? dblHighGrossMarginAlert { get; set; }
        public DateTime? dtmLastInventoryLevelEntry { get; set; }
        public bool ysnNonRetailUseDepartment { get; set; }
        public bool ysnReportNetGross { get; set; }
        public bool ysnDepartmentForPumps { get; set; }
        public int? intConvertPaidOutId { get; set; }
        public bool ysnDeleteFromRegister { get; set; }
        public bool ysnDeptKeyTaxed { get; set; }
        public int? intProductCodeId { get; set; }
        public int? intFamilyId { get; set; }
        public int? intClassId { get; set; }
        public bool ysnFoodStampable { get; set; }
        public bool ysnReturnable { get; set; }
        public bool ysnSaleable { get; set; }
        public bool ysnPrePriced { get; set; }
        public bool ysnIdRequiredLiquor { get; set; }
        public bool ysnIdRequiredCigarette { get; set; }
        public int intMinimumAge { get; set; }
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

        public tblICCategory tblICCategory { get; set; }
        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
    }
}
