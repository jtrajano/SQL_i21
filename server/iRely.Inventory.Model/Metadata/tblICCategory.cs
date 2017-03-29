using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCategory : BaseEntity
    {
        public tblICCategory()
        {
            this.tblICCategoryAccounts = new List<tblICCategoryAccount>();
            this.tblICCategoryLocations = new List<tblICCategoryLocation>();
            this.tblICCategoryVendors = new List<tblICCategoryVendor>();
            this.tblICCategoryUOMs = new List<tblICCategoryUOM>();
            this.tblICCategoryTaxes = new List<tblICCategoryTax>();
        }

        public int intCategoryId { get; set; }
        public string strCategoryCode { get; set; }
        public string strDescription { get; set; }
        public string strInventoryType { get; set; }
        public int? intLineOfBusinessId { get; set; }
        public int? intCostingMethod { get; set; }
        public string strInventoryTracking { get; set; }
        public decimal? dblStandardQty { get; set; }
        public int? intUOMId { get; set; }
        public string strGLDivisionNumber { get; set; }
        public bool ysnSalesAnalysisByTon { get; set; }
        public string strMaterialFee { get; set; }
        public int? intMaterialItemId { get; set; }
        public bool ysnAutoCalculateFreight { get; set; }
        public int? intFreightItemId { get; set; }
        public string strERPItemClass { get; set; }
        public decimal? dblLifeTime { get; set; }
        public decimal? dblBOMItemShrinkage { get; set; }
        public decimal? dblBOMItemUpperTolerance { get; set; }
        public decimal? dblBOMItemLowerTolerance { get; set; }
        public bool ysnScaled { get; set; }
        public bool ysnOutputItemMandatory { get; set; }
        public string strConsumptionMethod { get; set; }
        public string strBOMItemType { get; set; }
        public string strShortName { get; set; }
        public byte[] imgReceiptImage { get; set; }
        public byte[] imgWIPImage { get; set; }
        public byte[] imgFGImage { get; set; }
        public byte[] imgShipImage { get; set; }
        public decimal? dblLaborCost { get; set; }
        public decimal? dblOverHead { get; set; }
        public decimal? dblPercentage { get; set; }
        public string strCostDistributionMethod { get; set; }
        public bool ysnSellable { get; set; }
        public bool ysnYieldAdjustment { get; set; }
        public bool ysnWarehouseTracked { get; set; }

        private string _lineOfBusiness;

        [NotMapped]
        public string strLineOfBusiness
        {
            get
            {
                if (string.IsNullOrEmpty(_lineOfBusiness))
                    if (tblSMLineOfBusiness != null)
                        return tblSMLineOfBusiness.strLineOfBusiness;
                    else
                        return null;
                else
                    return _lineOfBusiness;
            }
            set
            {
                _lineOfBusiness = value;
            }
        }

        public ICollection<tblICCategoryAccount> tblICCategoryAccounts { get; set; }
        public ICollection<tblICCategoryLocation> tblICCategoryLocations { get; set; }
        public ICollection<tblICCategoryVendor> tblICCategoryVendors { get; set; }
        public ICollection<tblICCategoryUOM> tblICCategoryUOMs { get; set; }
        public ICollection<tblICCategoryTax> tblICCategoryTaxes { get; set; }
        public ICollection<tblICItem> tblICItems { get; set; }

        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public ICollection<tblICStorageLocationCategory> tblICStorageLocationCategories { get; set; }
        public tblSMLineOfBusiness tblSMLineOfBusiness { get; set; }

    }

    public class tblICCategoryAccount : BaseEntity
    {
        public int intCategoryAccountId { get; set; }
        public int intCategoryId { get; set; }
        public int? intAccountCategoryId { get; set; }
        public int? intAccountId { get; set; }
        public int? intSort { get; set; }

        private string _accountid;
        [NotMapped]
        public string strAccountId
        {
            get
            {
                if (string.IsNullOrEmpty(_accountid))
                    if (tblGLAccount != null)
                        return tblGLAccount.strAccountId;
                    else
                        return null;
                else
                    return _accountid;
            }
            set
            {
                _accountid = value;
            }
        }
        private string _description;
        [NotMapped]
        public string strDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_description))
                    if (tblGLAccount != null)
                        return tblGLAccount.strDescription;
                    else
                        return null;
                else
                    return _description;
            }
            set
            {
                _description = value;
            }
        }
        private string _accountGroup;
        [NotMapped]
        public string strAccountGroup
        {
            get
            {
                if (string.IsNullOrEmpty(_accountGroup))
                    if (tblGLAccount != null)
                        return tblGLAccount.strAccountGroup;
                    else
                        return null;
                else
                    return _accountGroup;
            }
            set
            {
                _accountGroup = value;
            }
        }
        private string _accountCategory;
        [NotMapped]
        public string strAccountCategory
        {
            get
            {
                if (string.IsNullOrEmpty(_accountCategory))
                    if (tblGLAccountCategory != null)
                        return tblGLAccountCategory.strAccountCategory;
                    else
                        return null;
                else
                    return _accountCategory;
            }
            set
            {
                _accountCategory = value;
            }
        }

        public tblICCategory tblICCategory { get; set; }
        public tblGLAccount tblGLAccount { get; set; }
        public tblGLAccountCategory tblGLAccountCategory { get; set; }
    }

    public class tblICCategoryLocation : BaseEntity
    {
        public int intCategoryLocationId { get; set; }
        public int intCategoryId { get; set; }
        public int? intLocationId { get; set; }
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
        public int? intMinimumAge { get; set; }
        public int? intSort { get; set; }

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
        private string _locationType;
        [NotMapped]
        public string strLocationType
        {
            get
            {
                if (string.IsNullOrEmpty(_locationType))
                    if (tblSMCompanyLocation != null)
                        return tblSMCompanyLocation.strLocationType;
                    else
                        return null;
                else
                    return _locationType;
            }
            set
            {
                _locationType = value;
            }
        }
        [NotMapped]
        public int? intCompanyLocationId
        {
            get
            {
                if (tblSMCompanyLocation != null)
                    return tblSMCompanyLocation.intCompanyLocationId;
                else
                    return null;
            }
        }

        public tblICCategory tblICCategory { get; set; }
        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public ICollection<tblICCategoryVendor> tblICCategoryVendors { get; set; }
    }

    public class CategoryLocationVM
    {
        public int intCategoryLocationId { get; set; }
        public int intCategoryId { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intCompanyLocationId { get; set; }
    }

    public class tblICCategoryUOM : BaseEntity
    {
        public int intCategoryUOMId { get; set; }
        public int intCategoryId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public decimal? dblUnitQty { get; set; }
        public bool ysnStockUnit { get; set; }
        public bool ysnAllowPurchase { get; set; }
        public bool ysnAllowSale { get; set; }
        public bool ysnDefault { get; set; }
        public int? intSort { get; set; }

        private string _unitmeasure;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_unitmeasure))
                    if (tblICUnitMeasure != null)
                        return tblICUnitMeasure.strUnitMeasure;
                    else
                        return null;
                else
                    return _unitmeasure;
            }
            set
            {
                _unitmeasure = value;
            }
        }
        private string _unitType;
        [NotMapped]
        public string strUnitType
        {
            get
            {
                if (string.IsNullOrEmpty(_unitType))
                    if (tblICUnitMeasure != null)
                        return tblICUnitMeasure.strUnitType;
                    else
                        return null;
                else
                    return _unitType;
            }
            set
            {
                _unitType = value;
            }
        }
        
        public tblICCategory tblICCategory { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
    }

    public class CategoryUOMVM
    {
        public int intCategoryUOMId { get; set; }
        public int intCategoryId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public decimal? dblUnitQty { get; set; }
        public bool ysnStockUnit { get; set; }
        public bool ysnAllowPurchase { get; set; }
        public bool ysnAllowSale { get; set; }
        public bool ysnDefault { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
    }

    public class tblICCategoryVendor : BaseEntity
    {
        public int intCategoryVendorId { get; set; }
        public int intCategoryId { get; set; }
        public int? intCategoryLocationId { get; set; }
        public int? intVendorId { get; set; }
        public string strVendorDepartment { get; set; }
        public bool ysnAddOrderingUPC { get; set; }
        public bool ysnUpdateExistingRecords { get; set; }
        public bool ysnAddNewRecords { get; set; }
        public bool ysnUpdatePrice { get; set; }
        public int? intFamilyId { get; set; }
        public int? intSellClassId { get; set; }
        public int? intOrderClassId { get; set; }
        public string strComments { get; set; }
        public int? intSort { get; set; }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblICCategoryLocation != null)
                        return tblICCategoryLocation.strLocationName;
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
        private string _vendorId;
        [NotMapped]
        public string strVendorId
        {
            get
            {
                if (string.IsNullOrEmpty(_vendorId))
                    if (vyuAPVendor != null)
                        return vyuAPVendor.strVendorId;
                    else
                        return null;
                else
                    return _vendorId;
            }
            set
            {
                _vendorId = value;
            }
        }
        private string _familyId;
        [NotMapped]
        public string strFamilyId
        {
            get
            {
                if (string.IsNullOrEmpty(_familyId))
                    if (Family != null)
                        return Family.strSubcategoryId;
                    else
                        return null;
                else
                    return _familyId;
            }
            set
            {
                _familyId = value;
            }
        }
        private string _sellclassId;
        [NotMapped]
        public string strSellClassId
        {
            get
            {
                if (string.IsNullOrEmpty(_sellclassId))
                    if (SellClass != null)
                        return SellClass.strSubcategoryId;
                    else
                        return null;
                else
                    return _sellclassId;
            }
            set
            {
                _sellclassId = value;
            }
        }
        private string _orderclassId;
        [NotMapped]
        public string strOrderClassId
        {
            get
            {
                if (string.IsNullOrEmpty(_orderclassId))
                    if (OrderClass != null)
                        return OrderClass.strSubcategoryId;
                    else
                        return null;
                else
                    return _orderclassId;
            }
            set
            {
                _orderclassId = value;
            }
        }

        public vyuAPVendor vyuAPVendor { get; set; }
        public tblICCategory tblICCategory { get; set; }
        public tblSTSubcategory Family { get; set; }
        public tblSTSubcategory SellClass { get; set; }
        public tblSTSubcategory OrderClass { get; set; }
        public tblICCategoryLocation tblICCategoryLocation { get; set; }

    }

    public class tblICCategoryTax : BaseEntity
    {
        public int intCategoryTaxId { get; set; }
        public int intCategoryId { get; set; }
        public int? intTaxClassId { get; set; }
        public bool ysnActive { get; set; }

        private string _category;
        [NotMapped]
        public string strCategory
        {
            get
            {
                if (string.IsNullOrEmpty(_category))
                    if (vyuICGetCategoryTax != null)
                        return vyuICGetCategoryTax.strCategory;
                    else
                        return null;
                else
                    return _category;
            }
            set
            {
                _category = value;
            }
        }

        private string _taxClass;
        [NotMapped]
        public string strTaxClass
        {
            get
            {
                if (string.IsNullOrEmpty(_taxClass))
                    if (vyuICGetCategoryTax != null)
                        return vyuICGetCategoryTax.strTaxClass;
                    else
                        return null;
                else
                    return _taxClass;
            }
            set
            {
                _taxClass = value;
            }
        }
        
        public vyuICGetCategoryTax vyuICGetCategoryTax { get; set; }
        public tblICCategory tblICCategory { get; set; }
    }

    public class vyuICGetCategoryTax
    {
        [Key]
        public int intCategoryTaxId { get; set; }
        public int intCategoryId { get; set; }
        public string strCategory { get; set; }
        public int? intTaxClassId { get; set; }
        public string strTaxClass { get; set; }
        public bool? ysnActive { get; set; }

        public tblICCategoryTax tblICCategoryTax { get; set; }
    }

}
