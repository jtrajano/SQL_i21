using System;
using System.Collections.Generic;
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
        public int intProfitCenter { get; set; }

        //public string strAddress { get; set; }
        //public string strZipPostalCode { get; set; }
        //public string strCity { get; set; }
        //public string strStateProvince { get; set; }
        //public string strCountry { get; set; }
        //public string strPhone { get; set; }
        //public string strFax { get; set; }
        //public string strEmail { get; set; }
        //public string strWebsite { get; set; }
        //public string strInternalNotes { get; set; }
        //public string strUseLocationAddress { get; set; }
        //public string strSkipSalesmanDefault { get; set; }
        //public bool ysnSkipTermsDefault { get; set; }
        //public string strOrderTypeDefault { get; set; }
        //public string strPrintCashReceipts { get; set; }
        //public bool ysnPrintCashTendered { get; set; }
        //public string strSalesTaxByLocation { get; set; }
        //public string strDeliverPickupDefault { get; set; }
        //public string strTaxState { get; set; }
        //public string strTaxAuthorityId1 { get; set; }
        //public string strTaxAuthorityId2 { get; set; }
        //public bool ysnOverridePatronage { get; set; }
        //public string strOutOfStockWarning { get; set; }
        //public string strLotOverdrawnWarning { get; set; }
        //public string strDefaultCarrier { get; set; }
        //public bool ysnOrderSection2Required { get; set; }
        //public string strPrintonPO { get; set; }
        //public decimal? dblMixerSize { get; set; }
        //public bool ysnOverrideMixerSize { get; set; }
        //public bool ysnEvenBatches { get; set; }
        //public bool ysnDefaultCustomBlend { get; set; }
        //public bool ysnAgroguideInterface { get; set; }
        //public bool ysnLocationActive { get; set; }
        //public int intCashAccount { get; set; }
        //public int intDepositAccount { get; set; }
        //public int intARAccount { get; set; }
        //public int intAPAccount { get; set; }
        //public int intSalesAdvAcct { get; set; }
        //public int intPurchaseAdvAccount { get; set; }
        //public int intFreightAPAccount { get; set; }
        //public int intFreightExpenses { get; set; }
        //public int intFreightIncome { get; set; }
        //public int intServiceCharges { get; set; }
        //public int intSalesDiscounts { get; set; }
        //public int intCashOverShort { get; set; }
        //public int intWriteOff { get; set; }
        //public int intCreditCardFee { get; set; }
        //public int intSalesAccount { get; set; }
        //public int intCostofGoodsSold { get; set; }
        //public int intInventory { get; set; }
        //public string strInvoiceType { get; set; }
        //public string strDefaultInvoicePrinter { get; set; }
        //public string strPickTicketType { get; set; }
        //public string strDefaultTicketPrinter { get; set; }
        //public string strLastOrderNumber { get; set; }
        //public string strLastInvoiceNumber { get; set; }
        //public string strPrintonInvoice { get; set; }
        //public bool ysnPrintContractBalance { get; set; }
        //public string strJohnDeereMerchant { get; set; }
        //public string strInvoiceComments { get; set; }
        //public bool ysnUseOrderNumberforInvoiceNumber { get; set; }
        //public bool ysnOverrideOrderInvoiceNumber { get; set; }
        //public bool ysnPrintInvoiceMedTags { get; set; }
        //public bool ysnPrintPickTicketMedTags { get; set; }
        //public bool ysnSendtoEnergyTrac { get; set; }
        //public string strDiscountScheduleType { get; set; }
        //public string strLocationDiscount { get; set; }
        //public string strLocationStorage { get; set; }
        //public string strMarketZone { get; set; }
        //public string strLastTicket { get; set; }
        //public bool ysnDirectShipLocation { get; set; }
        //public bool ysnScaleInstalled { get; set; }
        //public string strDefaultScaleId { get; set; }
        //public bool ysnActive { get; set; }
        //public bool ysnUsingCashDrawer { get; set; }
        //public string strCashDrawerDeviceId { get; set; }
        //public bool ysnPrintRegisterTape { get; set; }
        //public bool ysnUseUPConOrders { get; set; }
        //public bool ysnUseUPConPhysical { get; set; }
        //public bool ysnUseUPConPurchaseOrders { get; set; }
        //public string strUPCSearchSequence { get; set; }
        //public string strBarCodePrinterName { get; set; }
        //public string strPriceLevel1 { get; set; }
        //public string strPriceLevel2 { get; set; }
        //public string strPriceLevel3 { get; set; }
        //public string strPriceLevel4 { get; set; }
        //public string strPriceLevel5 { get; set; }
        //public bool ysnOverShortEntries { get; set; }
        //public string strOverShortCustomer { get; set; }
        //public string strOverShortAccount { get; set; }
        //public bool ysnAutomaticCashDepositEntries { get; set; }

        public ICollection<tblICItemNote> tblICItemNotes { get; set; }
        public ICollection<tblICItemAccount> tblICItemAccounts { get; set; }
        public ICollection<tblICItemCustomerXref> tblICItemCustomerXrefs { get; set; }
        public ICollection<tblICItemVendorXref> tblICItemVendorXrefs { get; set; }
        public ICollection<tblICItemContract> tblICItemContracts { get; set; }
        public ICollection<tblICItemStock> tblICItemStocks { get; set; }
        public ICollection<tblICItemLocation> tblICItemLocations { get; set; }
        public ICollection<tblICItemPricing> tblICItemPricings { get; set; }
        public ICollection<tblICItemPricingLevel> tblICItemPricingLevels { get; set; }
        public ICollection<tblICItemSpecialPricing> tblICItemSpecialPricings { get; set; }
    }

    public class tblGLAccount : BaseEntity
    {
        public int intAccountId { get; set; }
        public string strAccountId { get; set; }
        public string strDescription { get; set; }

        public ICollection<tblICItemAccount> tblICItemAccounts { get; set; }
        public ICollection<tblICItemAccount> tblICItemAccountProfitCenters { get; set; }
        public ICollection<tblICCommodityAccount> tblICCommodityAccounts { get; set; }

    }

    public class vyuAPVendor
    {
        public int intEntityId { get; set; }
        public string strName { get; set; }
        public int intVendorId { get; set; }
        public string strVendorAccountNum { get; set; }
        public string strVendorId { get; set; }

        public ICollection<tblICItemVendorXref> tblICItemVendorXrefs { get; set; }
        public ICollection<tblICItemLocation> tblICItemLocations { get; set; }
    }

    public class tblARCustomer : BaseEntity
    {
        public int intEntityId { get; set; }
        public int intCustomerId { get; set; }
        public string strCustomerNumber { get; set; }
        public string strType { get; set; }

        public ICollection<tblICItemCustomerXref> tblICItemCustomerXrefs { get; set; }
    }

    public class tblSMCountry : BaseEntity
    {
        public int intCountryID { get; set; }
        public string strCountry { get; set; }

        public ICollection<tblICItemContract> tblICItemContracts { get; set; }
    }
}
