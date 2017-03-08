using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblSMCompanyLocation : BaseEntity
    {
        public int intCompanyLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intProfitCenter { get; set; }

        public string strAddress { get; set; }
        public string strZipPostalCode { get; set; }
        public string strCity { get; set; }
        public string strStateProvince { get; set; }
        public string strCountry { get; set; }
        public string strPhone { get; set; }
        public string strFax { get; set; }

        public ICollection<tblICCategoryLocation> tblICCategoryLocations { get; set; }
        
        public ICollection<tblICItemFactory> tblICItemFactories { get; set; }

        public ICollection<tblICBuildAssembly> tblICBuildAssemblies { get; set; }

        public ICollection<tblICInventoryTransfer> FromInventoryTransfers { get; set; }
        public ICollection<tblICInventoryTransfer> ToInventoryTransfers { get; set; }

        public ICollection<tblICStorageMeasurementReading> tblICStorageMeasurementReadings { get; set; }
    }

    public class tblGLAccount
    {
        public int intAccountId { get; set; }
        public string strAccountId { get; set; }
        public string strDescription { get; set; }
        public string strAccountGroup { get; set; }

        public ICollection<tblICItemAccount> tblICItemAccounts { get; set; }
        public ICollection<tblICCommodityAccount> tblICCommodityAccounts { get; set; }
        public ICollection<tblICCategoryAccount> tblICCategoryAccounts { get; set; }
        
    }

    public class tblGLAccountGroup
    {
        public int intAccountGroupId { get; set; }
        public string strAccountGroup { get; set; }
        public string strAccountType { get; set; }
        public int? intParentGroupId { get; set; }
        public int? intGroup { get; set; }
        public int? intSort { get; set; }
        public int? intAccountBegin { get; set; }
        public int? intAccountEnd { get; set; }
        public string strAccountGroupNamespace { get; set; }
        public int? intEntityIdLastModified { get; set; }
        public int? intAccountCategoryId { get;set;}
        public int? intAccountRangeId { get; set; }
    }

    public class tblGLAccountCategory
    {
        public int intAccountCategoryId { get; set; }
        public string strAccountCategory { get; set; }
        public string strAccountGroupFilter { get; set; }
        public bool ysnRestricted { get; set; }
        public int intConcurrencyId { get; set; }
        
        public ICollection<tblICItemAccount> tblICItemAccounts { get; set; }
        public ICollection<tblICCommodityAccount> tblICCommodityAccounts { get; set; }
        public ICollection<tblICCategoryAccount> tblICCategoryAccounts { get; set; }
    }

    public class vyuAPVendor
    {
        public int intEntityId { get; set; }
        public string strName { get; set; }
        public int intEntityVendorId { get; set; }
        public string strVendorAccountNum { get; set; }
        public string strVendorId { get; set; }

        public ICollection<tblICItemVendorXref> tblICItemVendorXrefs { get; set; }
        public ICollection<tblICCategoryVendor> tblICCategoryVendors { get; set; }
    }

    public class tblARCustomer
    {
        public int intEntityCustomerId { get; set; }
        public string strCustomerName { get; set; }
        public string strCustomerNumber { get; set; }

        public ICollection<tblICItemCustomerXref> tblICItemCustomerXrefs { get; set; }
        public ICollection<tblICItemOwner> tblICItemOwners { get; set; }
    }

    public class tblSMCountry : BaseEntity
    {
        public int intCountryID { get; set; }
        public string strCountry { get; set; }

        public ICollection<tblICItemContract> tblICItemContracts { get; set; }
    }

    public class tblSMCurrency : BaseEntity
    {
        public int intCurrencyID { get; set; }
        public string strCurrency { get; set; }
        public string strDescription { get; set; }

        public ICollection<tblICCertificationCommodity> tblICCertificationCommodities { get; set; }
        public ICollection<tblICItemPricingLevel> tblICItemPricingLevels { get; set; }
        public ICollection<tblICItemSpecialPricing> tblICItemSpecialPricings { get; set; }
    }

    public class tblSTStore : BaseEntity
    {
        public int intStoreId { get; set; }
        public int intStoreNo { get; set; }
        public string strStoreName { get; set; }
        public string strDescription { get; set; }
        public string strRegion { get; set; }
        public string strDestrict { get; set; }
    }

    public class tblSTSubcategory : BaseEntity
    {
        public int intSubcategoryId { get; set; }
        public string strSubcategoryType { get; set; }
        public string strSubcategoryId { get; set; }
        public string strSubcategoryDesc { get; set; }
        public string strSubCategoryComment { get; set; }

        public ICollection<tblICCategoryVendor> tblICCategoryVendorFamily { get; set; }
        public ICollection<tblICCategoryVendor> tblICCategoryVendorSellClasses { get; set; }
        public ICollection<tblICCategoryVendor> tblICCategoryVendorOrderClasses { get; set; }
    }

    public class tblSTSubcategoryRegProd : BaseEntity
    {
        public int intRegProdId { get; set; }
        public int intStoreId { get; set; }
        public string strRegProdCode { get; set; }
        public string strRegProdDesc { get; set; }
        public string strRegProdComment { get; set; }

        public ICollection<vyuICGetItemLocation> vyuICGetItemLocation { get; set; }
    }

    public class tblSTPaidOut : BaseEntity
    {
        public int intPaidOutId { get; set; }
        public int intStoreId { get; set; }
        public string strPaidOutId { get; set; }
        public string strDescription { get; set; }
        public int intAccountId { get; set; }
        public int intPaymentMethodId { get; set; }
    }

    public class tblGRStorageType : BaseEntity
    {
        public int intStorageTypeId { get; set; }
        public string strStorageType { get; set; }
        public string strDescription { get; set; }
        public int intSort { get; set; }
    }

    public class tblSTPromotionSalesList : BaseEntity
    {
        public int intPromoSalesListId { get; set; }
        public string strPromoType { get; set; }
        public string strDescription { get; set; }
        public int intPromoCode { get; set; }
        public int intPromoUnits { get; set; }
        public decimal? dblPromoPrice { get; set; }
    }

    public class tblSMStartingNumber : BaseEntity
    {
        public int intStartingNumberId { get; set; }
        public string strTransactionType { get; set; }
        public string strPrefix { get; set; }
        public int intNumber { get; set; }
        public string strModule { get; set; }
        public bool ysnEnable { get; set; }
    }

   /* public class tblMFQAProperty : BaseEntity
    {
        public int intQAPropertyId { get; set; }
        public string strPropertyName { get; set; }
        public string strDescription { get; set; }
        public string strAnalysisType { get; set; }
        public string strDataType { get; set; }
        public string strListName { get; set; }
        public int intDecimalPlaces { get; set; }
        public string strMandatory { get; set; }
        public bool ysnActive { get; set; }

        public ICollection<tblICInventoryReceiptInspection> tblICInventoryReceiptInspections { get; set; }
    }*/

    public class tblSMCompanyLocationSubLocation : BaseEntity
    {
        public int intCompanyLocationSubLocationId { get; set; }
        public int intCompanyLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public string strSubLocationDescription { get; set; }
        public string strClassification { get; set; }
        public int? intNewLotBin { get; set; }
        public int? intAuditBin { get; set; }
        public string strAddress { get; set; }

        public ICollection<tblICStorageLocation> tblICStorageLocations { get; set; }
        public ICollection<tblICBuildAssemblyDetail> tblICBuildAssemblyDetails { get; set; }
        public ICollection<tblICBuildAssembly> tblICBuildAssemblies { get; set; }
    }

    public class tblSMTaxCode : BaseEntity
    {
        public int intTaxCodeId { get; set; }
        public string strTaxCode { get; set; }
        public int? intTaxClassId { get; set; }
        public string strDescription { get; set; }
        public string strCalculationMethod { get; set; }
        public decimal? numRate { get; set; }
        public string strTaxAgency { get; set; }
        public string strAddress { get; set; }
        public string strZipCode { get; set; }
        public string strState { get; set; }
        public string strCity { get; set; }
        public string strCountry { get; set; }
        public string strCounty { get; set; }
        public int? intSalesTaxAccountId { get; set; }
        public int? intPurchaseTaxAccountId { get; set; }
        public string strTaxableByOtherTaxes { get; set; }
    }

    public class tblICMeasurement : BaseEntity
    {
        public int intMeasurementId { get; set; }
        public string strMeasurementName { get; set; }
        public string strDescription { get; set; }
        public string strMeasurementType { get; set; }
        public int? intSort { get; set; }

        public ICollection<tblICStorageLocationMeasurement> tblICStorageLocationMeasurements { get; set; }
    }

    public class tblICReadingPoint : BaseEntity
    {
        public int intReadingPointId { get; set; }
        public string strReadingPoint { get; set; }
        public int? intSort { get; set; }

        public ICollection<tblICStorageLocationMeasurement> tblICStorageLocationMeasurements { get; set; }
    }

    public class tblICContainer : BaseEntity
    {
        public int intContainerId { get; set; }
        public int? intExternalSystemId { get; set; }
        public string strContainerId { get; set; }
        public int? intContainerTypeId { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strLastUpdateBy { get; set; }
        public DateTime? dtmLastUpdateOn { get; set; }
        public int? intSort { get; set; }

        public tblICContainerType tblICContainerType { get; set; }

        public ICollection<tblICStorageLocationSku> tblICStorageLocationSkus { get; set; }
        public ICollection<tblICStorageLocationContainer> tblICStorageLocationContainers { get; set; }
    }

    public class tblICContainerType : BaseEntity
    {
        public int intContainerTypeId { get; set; }
        public int? intExternalSystemId { get; set; }
        public string strInternalCode { get; set; }
        public string strDisplayMember { get; set; }
        public int? intDimensionUnitMeasureId { get; set; }
        public decimal? dblHeight { get; set; }
        public decimal? dblWidth { get; set; }
        public decimal? dblDepth { get; set; }
        public int? intWeightUnitMeasureId { get; set; }
        public decimal? dblMaxWeight { get; set; }
        public bool ysnLocked { get; set; }
        public bool ysnDefault { get; set; }
        public decimal? dblPalletWeight { get; set; }
        public string strLastUpdateBy { get; set; }
        public DateTime dtmLastUpdateOn { get; set; }
        public string strContainerDescription { get; set; }
        public bool ysnReusable { get; set; }
        public bool ysnAllowMultipleItems { get; set; }
        public bool ysnAllowMultipleLots { get; set; }
        public bool ysnMergeOnMove { get; set; }
        public int? intTareUnitMeasureId { get; set; }
        public int? intSort { get; set; }

        public ICollection<tblICContainer> tblICContainers { get; set; }
        public ICollection<tblICStorageLocationContainer> tblICStorageLocationContainers { get; set; }
    }

    public class tblICSku : BaseEntity
    {
        public int intSKUId { get; set; }
        public int? intExternalSystemId { get; set; }
        public string strSKU { get; set; }
        public int? intSKUStatusId { get; set; }
        public string strLotCode { get; set; }
        public string strSerialNo { get; set; }
        public decimal? dblQuantity { get; set; }
        public DateTime? dtmReceiveDate { get; set; }
        public DateTime? dtmProductionDate { get; set; }
        public int? intItemId { get; set; }
        public int? intContainerId { get; set; }
        public int? intOwnerId { get; set; }
        public string strLastUpdateBy { get; set; }
        public DateTime? dtmLastUpdateOn { get; set; }
        public int? intLotId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public int? intReasonId { get; set; }
        public string strComment { get; set; }
        public int? intParentSKUId { get; set; }
        public decimal? dblWeightPerUnit { get; set; }
        public int? intWeightPerUnitMeasureId { get; set; }
        public int? intUnitPerLayer { get; set; }
        public int? intLayerPerPallet { get; set; }
        public bool ysnSanitized { get; set; }
        public string strBatch { get; set; }
        public int? intSort { get; set; }

        public ICollection<tblICStorageLocationSku> tblICStorageLocationSkus { get; set; }
    }

    public class tblICMaterialNMFC : BaseEntity
    {
        public int intMaterialNMFCId { get; set; }
        public int? intExternalSystemId { get; set; }
        public string strInternalCode { get; set; }
        public string strDisplayMember { get; set; }
        public bool ysnDefault { get; set; }
        public bool ysnLocked { get; set; }
        public string strLastUpdateBy { get; set; }
        public DateTime dtmLastUpdateOn { get; set; }
        public int intSort { get; set; }
    }

    public class tblICReasonCode : BaseEntity
    {
        public int intReasonCodeId { get; set; }
        public string strReasonCode { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public string strLotTransactionType { get; set; }
        public bool ysnDefault { get; set; }
        public bool ysnReduceAvailableTime { get; set; }
        public bool ysnExplanationRequired { get; set; }
        public string strLastUpdatedBy { get; set; }
        public DateTime dtmLastUpdatedOn { get; set; }
    }

    public class tblICReasonCodeWorkCenter : BaseEntity
    {
        public int intReasonCodeWorkCenterId { get; set; }
        public int intReasonCodeId { get; set; }
        public string strWorkCenterId { get; set; }
        public int intSort { get; set; }
    }

    public class tblICRestriction : BaseEntity
    {
        public int intRestrictionId { get; set; }
        public string strInternalCode { get; set; }
        public string strDisplayMember { get; set; }
        public bool ysnDefault { get; set; }
        public bool ysnLocked { get; set; }
        public string strLastUpdateBy { get; set; }
        public DateTime? dtmLastUpdateOn { get; set; }
        public int? intSort { get; set; }
    }

    public class tblICEquipmentLength : BaseEntity
    {
        public int intEquipmentLengthId { get; set; }
        public string strEquipmentLength { get; set; }
        public string strDescription { get; set; }
        public int intSort { get; set; }
    }
}
