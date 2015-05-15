﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Drawing;
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
        }

        public int intCategoryId { get; set; }
        public string strCategoryCode { get; set; }
        public string strDescription { get; set; }
        public int? intLineOfBusinessId { get; set; }
        public int? intCatalogGroupId { get; set; }
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

        public ICollection<tblICCategoryAccount> tblICCategoryAccounts { get; set; }
        public ICollection<tblICCategoryLocation> tblICCategoryLocations { get; set; }
        public ICollection<tblICCategoryVendor> tblICCategoryVendors { get; set; }
        public ICollection<tblICCategoryUOM> tblICCategoryUOMs { get; set; }
        public ICollection<tblICItem> tblICItems { get; set; }

        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public ICollection<tblICStorageLocationCategory> tblICStorageLocationCategories { get; set; }

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

        public tblICCategory tblICCategory { get; set; }
        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public ICollection<tblICCategoryVendor> tblICCategoryVendors { get; set; }
    }

    public class tblICCategoryUOM : BaseEntity
    {
        public int intCategoryUOMId { get; set; }
        public int intCategoryId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public decimal? dblUnitQty { get; set; }
        public decimal? dblSellQty { get; set; }
        public decimal? dblWeight { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strDescription { get; set; }
        public string strUpcCode { get; set; }
        public bool ysnStockUnit { get; set; }
        public bool ysnAllowPurchase { get; set; }
        public bool ysnAllowSale { get; set; }
        public decimal? dblLength { get; set; }
        public decimal? dblWidth { get; set; }
        public decimal? dblHeight { get; set; }
        public int? intDimensionUOMId { get; set; }
        public decimal? dblVolume { get; set; }
        public int? intVolumeUOMId { get; set; }
        public decimal? dblMaxQty { get; set; }
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
        private string _weightUOM;
        [NotMapped]
        public string strWeightUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_weightUOM))
                    if (WeightUOM != null)
                        return WeightUOM.strUnitMeasure;
                    else
                        return null;
                else
                    return _weightUOM;
            }
            set
            {
                _weightUOM = value;
            }
        }
        private string _dimensionUOM;
        [NotMapped]
        public string strDimensionUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_dimensionUOM))
                    if (DimensionUOM != null)
                        return DimensionUOM.strUnitMeasure;
                    else
                        return null;
                else
                    return _dimensionUOM;
            }
            set
            {
                _dimensionUOM = value;
            }
        }
        private string _volumeUOM;
        [NotMapped]
        public string strVolumeUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_volumeUOM))
                    if (VolumeUOM != null)
                        return VolumeUOM.strUnitMeasure;
                    else
                        return null;
                else
                    return _volumeUOM;
            }
            set
            {
                _volumeUOM = value;
            }
        }

        public tblICCategory tblICCategory { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public tblICUnitMeasure WeightUOM { get; set; }
        public tblICUnitMeasure DimensionUOM { get; set; }
        public tblICUnitMeasure VolumeUOM { get; set; }
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
                        return Family.strFamilyId;
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
                        return SellClass.strClassId;
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
                        return OrderClass.strClassId;
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
        public tblSTSubcategoryFamily Family { get; set; }
        public tblSTSubcategoryClass SellClass { get; set; }
        public tblSTSubcategoryClass OrderClass { get; set; }
        public tblICCategoryLocation tblICCategoryLocation { get; set; }

    }

}
