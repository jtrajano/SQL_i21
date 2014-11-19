using System;
using System.Text;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Net;
using System.Web;
using System.IO;

namespace iRely.Inventory.Model
{
    public partial class InventoryEntities : DbContext
    {
        public InventoryEntities(string connectionString)
            : base(connectionString)
        {

        }

        public InventoryEntities()
            : base(GetConnectionString())
        {

        }

        //public InventoryEntities()
        //    : base("Name=InventoryEntities")
        //{
        //    this.Configuration.ProxyCreationEnabled = false;
        //}

        #region Function
        /// <summary>
        /// 
        /// </summary>
        /// <param name="token"></param>
        /// <returns></returns>
        public static string ConstructConnectionString(string token)
        {
            if (string.IsNullOrEmpty(token))
                return "";

            var tokenDecoded = Encoding.Default.GetString(Convert.FromBase64String(token.Replace("Basic ", "")));
            var tokens = tokenDecoded.Split(':');

            if (tokens.Length < 3)
            {
                return "";
            }
            else
            {
                var company = tokens[2];

                var appPath = HttpContext.Current.Request.ApplicationPath;
                var rootPath = appPath.Substring(0, appPath.LastIndexOf("/"));

                var serverUrl = string.Format("{0}://{1}/{2}", HttpContext.Current.Request.Url.Scheme, HttpContext.Current.Request.Url.Host, rootPath);
                var actionUrl = string.Format("{0}/SystemManager/api/CompanyConfiguration/GetCompanyConnection?CompanyName={1}", serverUrl, company);

                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(actionUrl);
                var result = request.GetResponse();
                var config = "";

                using (StreamReader reader = new StreamReader(result.GetResponseStream(), Encoding.UTF8))
                {
                    config = reader.ReadToEnd().Replace(@"\\", @"\").Replace("\"", "");
                    reader.Close();
                }

                if (!string.IsNullOrEmpty(config))
                    return config;
                else
                    return "";
            }
        }
        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public static string GetConnectionString()
        {
            var token = System.Web.HttpContext.Current.Request.Headers["Authorization"];
            var cs = ConstructConnectionString(token);

            return cs;
        }
        #endregion

        public DbSet<tblICBrand> tblICBrands { get; set; }
        public DbSet<tblICCatalog> tblICCatalogs { get; set; }
        public DbSet<tblICCategory> tblICCategorys { get; set; }
        public DbSet<tblICCategoryAccount> tblICCategoryAccounts { get; set; }
        public DbSet<tblICCategoryLocation> tblICCategoryLocations { get; set; }
        public DbSet<tblICCategoryVendor> tblICCategoryVendors { get; set; }
        public DbSet<tblICCertification> tblICCertifications { get; set; }
        public DbSet<tblICCertificationCommodity> tblICCertificationCommoditys { get; set; }
        public DbSet<tblICCommodity> tblICCommoditys { get; set; }
        public DbSet<tblICCommodityAccount> tblICCommodityAccounts { get; set; }
        public DbSet<tblICCommodityAttribute> tblICCommodityAttributes { get; set; }
        public DbSet<tblICCommodityGroup> tblICCommodityGroups { get; set; }
        public DbSet<tblICCommodityUnitMeasure> tblICCommodityUnitMeasures { get; set; }
        public DbSet<tblICCountGroup> tblICCountGroups { get; set; }
        public DbSet<tblICDocument> tblICDocuments { get; set; }
        public DbSet<tblICFuelTaxClass> tblICFuelTaxClasss { get; set; }
        public DbSet<tblICFuelTaxClassProductCode> tblICFuelTaxClassProductCodes { get; set; }
        public DbSet<tblICFuelType> tblICFuelTypes { get; set; }
        public DbSet<tblICItem> tblICItems { get; set; }
        public DbSet<tblICItemAccount> tblICItemAccounts { get; set; }
        public DbSet<tblICItemAssembly> tblICItemAssemblys { get; set; }
        public DbSet<tblICItemBundle> tblICItemBundles { get; set; }
        public DbSet<tblICItemCertification> tblICItemCertifications { get; set; }
        public DbSet<tblICItemContract> tblICItemContracts { get; set; }
        public DbSet<tblICItemContractDocument> tblICItemContractDocuments { get; set; }
        public DbSet<tblICItemCustomerXref> tblICItemCustomerXrefs { get; set; }
        public DbSet<tblICItemKit> tblICItemKits { get; set; }
        public DbSet<tblICItemKitDetail> tblICItemKitDetails { get; set; }
        public DbSet<tblICItemLocation> tblICItemLocations { get; set; }
        public DbSet<tblICItemManufacturingUOM> tblICItemManufacturingUOMs { get; set; }
        public DbSet<tblICItemNote> tblICItemNotes { get; set; }
        public DbSet<tblICItemPOSCategory> tblICItemPOSCategorys { get; set; }
        public DbSet<tblICItemPOSSLA> tblICItemPOSSLAs { get; set; }
        public DbSet<tblICItemPricing> tblICItemPricings { get; set; }
        public DbSet<tblICItemPricingLevel> tblICItemPricingLevels { get; set; }
        public DbSet<tblICItemSpecialPricing> tblICItemSpecialPricings { get; set; }
        public DbSet<tblICItemStock> tblICItemStocks { get; set; }
        public DbSet<tblICItemSubstitution> tblICItemSubstitutions { get; set; }
        public DbSet<tblICItemSubstitutionDetail> tblICItemSubstitutionDetails { get; set; }
        public DbSet<tblICItemUOM> tblICItemUOMs { get; set; }
        public DbSet<tblICItemUPC> tblICItemUPCs { get; set; }
        public DbSet<tblICItemVendorXref> tblICItemVendorXrefs { get; set; }
        public DbSet<tblICLineOfBusiness> tblICLineOfBusinesss { get; set; }
        public DbSet<tblICLotStatus> tblICLotStatuss { get; set; }
        public DbSet<tblICManufacturer> tblICManufacturers { get; set; }
        public DbSet<tblICManufacturingCell> tblICManufacturingCells { get; set; }
        public DbSet<tblICManufacturingCellPackType> tblICManufacturingCellPackTypes { get; set; }
        public DbSet<tblICMaterialNMFC> tblICMaterialNMFCs { get; set; }
        public DbSet<tblICPackType> tblICPackTypes { get; set; }
        public DbSet<tblICPackTypeDetail> tblICPackTypeDetails { get; set; }
        public DbSet<tblICPatronageCategory> tblICPatronageCategorys { get; set; }
        public DbSet<tblICReasonCode> tblICReasonCodes { get; set; }
        public DbSet<tblICReasonCodeWorkCenter> tblICReasonCodeWorkCenters { get; set; }
        public DbSet<tblICRinFeedStock> tblICRinFeedStocks { get; set; }
        public DbSet<tblICRinFeedStockUOM> tblICRinFeedStockUOMs { get; set; }
        public DbSet<tblICRinFuel> tblICRinFuels { get; set; }
        public DbSet<tblICRinFuelCategory> tblICRinFuelCategorys { get; set; }
        public DbSet<tblICRinProcess> tblICRinProcesss { get; set; }
        public DbSet<tblICStorageLocation> tblICStorageLocations { get; set; }
        public DbSet<tblICStorageLocationCategory> tblICStorageLocationCategorys { get; set; }
        public DbSet<tblICStorageLocationMeasurement> tblICStorageLocationMeasurements { get; set; }
        public DbSet<tblICStorageUnitType> tblICStorageUnitTypes { get; set; }
        public DbSet<tblICTag> tblICTags { get; set; }
        public DbSet<tblICUnitMeasure> tblICUnitMeasures { get; set; }
        public DbSet<tblICUnitMeasureConversion> tblICUnitMeasureConversions { get; set; }
        
        public DbSet<tblSMCompanyLocation> tblSMCompanyLocations { get; set; }
        public DbSet<tblGLAccount> tblGLAccounts { get; set; }
        public DbSet<vyuAPVendor> vyuAPVendors { get; set; }
        public DbSet<tblARCustomer> tblARCustomers { get; set; }
        public DbSet<tblSMCountry> tblSMCountries { get; set; }

        public DbSet<tblSTPaidOut> tblSTPaidOut { get; set; }
        public DbSet<tblSTStore> tblSTStore { get; set; }
        public DbSet<tblSTSubcategoryClass> tblSTSubcategoryClasses { get; set; }
        public DbSet<tblSTSubcategoryFamily> tblSTSubcategoryFamilies { get; set; }
        public DbSet<tblSTSubcategoryRegProd> tblSTSubcategoryRegProds { get; set; }

        public DbSet<tblGRStorageType> tblGRStorageTypes { get; set; }
        public DbSet<tblSTPromotionSalesList> tblSTPromotionSalesLists { get; set; }
        
        protected override void OnModelCreating(DbModelBuilder modelBuilder) 
        {
            modelBuilder.Configurations.Add(new tblICBrandMap());
            modelBuilder.Configurations.Add(new tblICCatalogMap());
            modelBuilder.Configurations.Add(new tblICCategoryMap());
            modelBuilder.Configurations.Add(new tblICCategoryAccountMap());
            modelBuilder.Configurations.Add(new tblICCategoryLocationMap());
            modelBuilder.Configurations.Add(new tblICCategoryVendorMap());
            modelBuilder.Configurations.Add(new tblICCertificationMap());
            modelBuilder.Configurations.Add(new tblICCertificationCommodityMap());
            modelBuilder.Configurations.Add(new tblICCommodityMap());
            modelBuilder.Configurations.Add(new tblICCommodityAccountMap());
            modelBuilder.Configurations.Add(new tblICCommodityAttributeMap());
            modelBuilder.Configurations.Add(new tblICCommodityGroupMap());
            modelBuilder.Configurations.Add(new tblICCommodityUnitMeasureMap());
            modelBuilder.Configurations.Add(new tblICCountGroupMap());
            modelBuilder.Configurations.Add(new tblICDocumentMap());
            modelBuilder.Configurations.Add(new tblICFuelTaxClassMap());
            modelBuilder.Configurations.Add(new tblICFuelTaxClassProductCodeMap());
            modelBuilder.Configurations.Add(new tblICFuelTypeMap());
            modelBuilder.Configurations.Add(new tblICItemMap());
            modelBuilder.Configurations.Add(new tblICItemAccountMap());
            modelBuilder.Configurations.Add(new tblICItemAssemblyMap());
            modelBuilder.Configurations.Add(new tblICItemBundleMap());
            modelBuilder.Configurations.Add(new tblICItemCertificationMap());
            modelBuilder.Configurations.Add(new tblICItemContractMap());
            modelBuilder.Configurations.Add(new tblICItemContractDocumentMap());
            modelBuilder.Configurations.Add(new tblICItemCustomerXrefMap());
            modelBuilder.Configurations.Add(new tblICItemKitMap());
            modelBuilder.Configurations.Add(new tblICItemKitDetailMap());
            modelBuilder.Configurations.Add(new tblICItemLocationMap());
            modelBuilder.Configurations.Add(new tblICItemManufacturingUOMMap());
            modelBuilder.Configurations.Add(new tblICItemNoteMap());
            modelBuilder.Configurations.Add(new tblICItemPOSCategoryMap());
            modelBuilder.Configurations.Add(new tblICItemPOSSLAMap());
            modelBuilder.Configurations.Add(new tblICItemPricingMap());
            modelBuilder.Configurations.Add(new tblICItemPricingLevelMap());
            modelBuilder.Configurations.Add(new tblICItemSpecialPricingMap());
            modelBuilder.Configurations.Add(new tblICItemStockMap());
            modelBuilder.Configurations.Add(new tblICItemSubstitutionMap());
            modelBuilder.Configurations.Add(new tblICItemSubstitutionDetailMap());
            modelBuilder.Configurations.Add(new tblICItemUOMMap());
            modelBuilder.Configurations.Add(new tblICItemUPCMap());
            modelBuilder.Configurations.Add(new tblICItemVendorXrefMap());
            modelBuilder.Configurations.Add(new tblICLineOfBusinessMap());
            modelBuilder.Configurations.Add(new tblICLotStatusMap());
            modelBuilder.Configurations.Add(new tblICManufacturerMap());
            modelBuilder.Configurations.Add(new tblICManufacturingCellMap());
            modelBuilder.Configurations.Add(new tblICManufacturingCellPackTypeMap());
            modelBuilder.Configurations.Add(new tblICMaterialNMFCMap());
            modelBuilder.Configurations.Add(new tblICPackTypeMap());
            modelBuilder.Configurations.Add(new tblICPackTypeDetailMap());
            modelBuilder.Configurations.Add(new tblICPatronageCategoryMap());
            modelBuilder.Configurations.Add(new tblICReasonCodeMap());
            modelBuilder.Configurations.Add(new tblICReasonCodeWorkCenterMap());
            modelBuilder.Configurations.Add(new tblICRinFeedStockMap());
            modelBuilder.Configurations.Add(new tblICRinFeedStockUOMMap());
            modelBuilder.Configurations.Add(new tblICRinFuelMap());
            modelBuilder.Configurations.Add(new tblICRinFuelCategoryMap());
            modelBuilder.Configurations.Add(new tblICRinProcessMap());
            modelBuilder.Configurations.Add(new tblICStorageLocationMap());
            modelBuilder.Configurations.Add(new tblICStorageLocationCategoryMap());
            modelBuilder.Configurations.Add(new tblICStorageLocationMeasurementMap());
            modelBuilder.Configurations.Add(new tblICStorageUnitTypeMap());
            modelBuilder.Configurations.Add(new tblICTagMap());
            modelBuilder.Configurations.Add(new tblICUnitMeasureMap());
            modelBuilder.Configurations.Add(new tblICUnitMeasureConversionMap());

            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommodityClassVariant>(p => p.Requires("strType").HasValue("Class"));
            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommodityGrade>(p => p.Requires("strType").HasValue("Grade"));
            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommodityOrigin>(p => p.Requires("strType").HasValue("Origin"));
            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommodityProductLine>(p => p.Requires("strType").HasValue("ProductLine"));
            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommodityProductType>(p => p.Requires("strType").HasValue("ProductType"));
            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommodityRegion>(p => p.Requires("strType").HasValue("Region"));
            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommoditySeason>(p => p.Requires("strType").HasValue("Season"));

            modelBuilder.Configurations.Add(new tblICCommodityClassVariantMap());
            modelBuilder.Configurations.Add(new tblICCommodityGradeMap());
            modelBuilder.Configurations.Add(new tblICCommodityOriginMap());
            modelBuilder.Configurations.Add(new tblICCommodityProductLineMap());
            modelBuilder.Configurations.Add(new tblICCommodityProductTypeMap());
            modelBuilder.Configurations.Add(new tblICCommodityRegionMap());
            modelBuilder.Configurations.Add(new tblICCommoditySeasonMap());

            modelBuilder.Configurations.Add(new tblSMCompanyLocationMap());
            modelBuilder.Configurations.Add(new tblGLAccountMap());
            modelBuilder.Configurations.Add(new vyuAPVendorMap());
            modelBuilder.Configurations.Add(new tblARCustomerMap());
            modelBuilder.Configurations.Add(new tblSMCountryMap());

            modelBuilder.Configurations.Add(new tblSTPaidOutMap());
            modelBuilder.Configurations.Add(new tblSTStoreMap());
            modelBuilder.Configurations.Add(new tblSTSubcategoryClassMap());
            modelBuilder.Configurations.Add(new tblSTSubcategoryFamilyMap());
            modelBuilder.Configurations.Add(new tblSTSubcategoryRegProdMap());

            modelBuilder.Configurations.Add(new tblGRStorageTypeMap());
            modelBuilder.Configurations.Add(new tblSTPromotionSalesListMap());
        }
    }
}
