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
        static InventoryEntities()
        {
            Database.SetInitializer<InventoryEntities>(null);
        }

        public InventoryEntities()
            : base(GetConnectionString())
        {
            this.Configuration.ProxyCreationEnabled = false;
        }

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

                var serverUrl = string.Format("{0}://localhost/{1}", HttpContext.Current.Request.Url.Scheme, rootPath);
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
        public DbSet<tblICCategoryStore> tblICCategoryStores { get; set; }
        public DbSet<tblICCategoryVendor> tblICCategoryVendors { get; set; }
        public DbSet<tblICClass> tblICClasss { get; set; }
        public DbSet<tblICCommodity> tblICCommodities { get; set; }
        public DbSet<tblICCommodityGroup> tblICCommodityGroups { get; set; }
        public DbSet<tblICCommodityUnitMeasure> tblICCommodityUnitMeasures { get; set; }
        public DbSet<tblICFamily> tblICFamilies { get; set; }
        public DbSet<tblICFuelType> tblICFuelTypes { get; set; }
        public DbSet<tblICItem> tblICItems { get; set; }
        public DbSet<tblICManufacturer> tblICManufacturers { get; set; }
        public DbSet<tblICPatronageCategory> tblICPatronageCategories { get; set; }
        public DbSet<tblICReasonCode> tblICReasonCodes { get; set; }
        public DbSet<tblICReasonCodeWorkCenter> tblICReasonCodeWorkCenters { get; set; }
        public DbSet<tblICRinFeedStock> tblICRinFeedStocks { get; set; }
        public DbSet<tblICRinFeedStockUOM> tblICRinFeedStockUOMs { get; set; }
        public DbSet<tblICRinFuel> tblICRinFuels { get; set; }
        public DbSet<tblICRinFuelType> tblICRinFuelTypes { get; set; }
        public DbSet<tblICRinProcess> tblICRinProcesss { get; set; }
        public DbSet<tblICTag> tblICTags { get; set; }
        public DbSet<tblICUnitMeasure> tblICUnitMeasures { get; set; }
        public DbSet<tblICUnitType> tblICUnitTypes { get; set; }
        
        protected override void OnModelCreating(DbModelBuilder modelBuilder) 
        {
            modelBuilder.Configurations.Add(new tblICBrandMap());
            modelBuilder.Configurations.Add(new tblICCatalogMap());
            modelBuilder.Configurations.Add(new tblICCategoryMap());
            modelBuilder.Configurations.Add(new tblICCategoryAccountMap());
            modelBuilder.Configurations.Add(new tblICCategoryStoreMap());
            modelBuilder.Configurations.Add(new tblICCategoryVendorMap());
            modelBuilder.Configurations.Add(new tblICClassMap());
            modelBuilder.Configurations.Add(new tblICCommodityMap());
            modelBuilder.Configurations.Add(new tblICCommodityGroupMap());
            modelBuilder.Configurations.Add(new tblICCommodityUnitMeasureMap());
            modelBuilder.Configurations.Add(new tblICFamilyMap());
            modelBuilder.Configurations.Add(new tblICFuelTypeMap());
            modelBuilder.Configurations.Add(new tblICItemMap());
            modelBuilder.Configurations.Add(new tblICManufacturerMap());
            modelBuilder.Configurations.Add(new tblICPatronageCategoryMap());
            modelBuilder.Configurations.Add(new tblICReasonCodeMap());
            modelBuilder.Configurations.Add(new tblICReasonCodeWorkCenterMap());
            modelBuilder.Configurations.Add(new tblICRinFeedStockMap());
            modelBuilder.Configurations.Add(new tblICRinFeedStockUOMMap());
            modelBuilder.Configurations.Add(new tblICRinFuelMap());
            modelBuilder.Configurations.Add(new tblICRinFuelTypeMap());
            modelBuilder.Configurations.Add(new tblICRinProcessMap());
            modelBuilder.Configurations.Add(new tblICTagMap());
            modelBuilder.Configurations.Add(new tblICUnitMeasureMap());
            modelBuilder.Configurations.Add(new tblICUnitTypeMap());
        }
    }
}
