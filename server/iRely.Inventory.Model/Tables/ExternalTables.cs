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

        public ICollection<tblICManufacturingCell> tblICManufacturingCells { get; set; }
        public ICollection<tblICCategoryLocation> tblICCategoryLocations { get; set; }
        
        public ICollection<tblICItemLocation> tblICItemLocations { get; set; }
        public ICollection<tblICItemFactory> tblICItemFactories { get; set; }
        public ICollection<tblICInventoryReceipt> tblICInventoryReceipts { get; set; }

        public ICollection<tblICInventoryShipment> ShipFromLocations { get; set; }

        public ICollection<tblICInventoryAdjustment> tblICInventoryAdjustments { get; set; }
        public ICollection<tblICBuildAssembly> tblICBuildAssemblies { get; set; }

        public ICollection<tblICInventoryTransfer> FromInventoryTransfers { get; set; }
        public ICollection<tblICInventoryTransfer> ToInventoryTransfers { get; set; }
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

    public class tblGLAccountCategory
    {
        public int intAccountCategoryId { get; set; }
        public string strAccountCategory { get; set; }
        
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
        public ICollection<tblICItemLocation> tblICItemLocations { get; set; }
        public ICollection<tblICCategoryVendor> tblICCategoryVendors { get; set; }
        public ICollection<tblICInventoryReceipt> tblICInventoryReceipts { get; set; }
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

    public class tblSTSubcategoryClass : BaseEntity
    {
        public int intClassId { get; set; }
        public string strClassId { get; set; }
        public string strClassDesc { get; set; }
        public string strClassComment { get; set; }

        public ICollection<tblICCategoryVendor> tblICCategoryVendorSellClasses { get; set; }
        public ICollection<tblICCategoryVendor> tblICCategoryVendorOrderClasses { get; set; }
    }

    public class tblSTSubcategoryFamily : BaseEntity
    {
        public int intFamilyId { get; set; }
        public string strFamilyId { get; set; }
        public string strFamilyDesc { get; set; }
        public string strFamilyComment { get; set; }

        public ICollection<tblICCategoryVendor> tblICCategoryVendors { get; set; }
    }

    public class tblSTSubcategoryRegProd : BaseEntity
    {
        public int intRegProdId { get; set; }
        public int intStoreId { get; set; }
        public string strRegProdCode { get; set; }
        public string strRegProdDesc { get; set; }
        public string strRegProdComment { get; set; }
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

    public class tblSMFreightTerm : BaseEntity
    {
        public int intFreightTermId { get; set; }
        public string strFreightTerm { get; set; }
        public string strFobPoint { get; set; }
        public bool ysnActive { get; set; }

        public ICollection<tblICInventoryReceipt> tblICInventoryReceipts { get; set; }
    }

    public class tblMFQAProperty : BaseEntity
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
    }

    public class vyuSMGetLocationPricingLevel
    {
        [Key]
        public int intKey { get; set; }
        public int intCompanyLocationId { get; set; }
        public string strPriceLevel { get; set; }
    }

    public class tblSMCompanyLocationSubLocation : BaseEntity
    {
        public int intCompanyLocationSubLocationId { get; set; }
        public int intCompanyLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public string strSubLocationDescription { get; set; }
        public string strClassification { get; set; }
        public int? intNewLotBin { get; set; }
        public int? intAuditBin { get; set; }
        public string strAddressKey { get; set; }

        public ICollection<tblICInventoryReceiptItem> tblICInventoryReceiptItems { get; set; }
        public ICollection<tblICInventoryShipmentItem> tblICInventoryShipmentItems { get; set; }
        public ICollection<tblICItemLocation> tblICItemLocations { get; set; }
        public ICollection<tblICStorageLocation> tblICStorageLocations { get; set; }
        public ICollection<tblICItemStock> tblICItemStocks { get; set; }
        public ICollection<tblICInventoryAdjustmentDetail> tblICInventoryAdjustmentDetails { get; set; }
        public ICollection<tblICBuildAssemblyDetail> tblICBuildAssemblyDetails { get; set; }
        public ICollection<tblICBuildAssembly> tblICBuildAssemblies { get; set; }

        public ICollection<tblICInventoryTransferDetail> FromTransferDetails { get; set; }
        public ICollection<tblICInventoryTransferDetail> ToTransferDetails { get; set; }
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

        public ICollection<tblICInventoryTransferDetail> tblICInventoryTransferDetails { get; set; }
    }

    public class tblEntityLocation : BaseEntity
    {
        public int intEntityLocationId { get; set; }
        public int intEntityId { get; set; }
        public string strLocationName { get; set; }
        public string strAddress { get; set; }
        public string strCity { get; set; }
        public string strCountry { get; set; }
        public string strState { get; set; }
        public string strZipCode { get; set; }
        public string strPhone { get; set; }
        public string strFax { get; set; }
        public string strPricingLevel { get; set; }
        public string strNotes { get; set; }
        public int? intShipViaId { get; set; }
        public int? intTaxCodeId { get; set; }
        public int? intTermsId { get; set; }
        public int? intWarehouseId { get; set; }
        public bool? ysnDefaultLocation { get; set; }

        public ICollection<tblICInventoryShipment> tblICInventoryShipments { get; set; }
    }
}
