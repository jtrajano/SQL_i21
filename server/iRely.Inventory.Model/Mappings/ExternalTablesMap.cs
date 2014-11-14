using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblSMCompanyLocationMap: EntityTypeConfiguration<tblSMCompanyLocation>
    {
        public tblSMCompanyLocationMap()
        {
            // Primary Key
            this.HasKey(t => t.intCompanyLocationId);

            // Table & Column Mappings
            this.ToTable("tblSMCompanyLocation");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strLocationType).HasColumnName("strLocationType");
            this.Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
        }
    }

    public class tblGLAccountMap : EntityTypeConfiguration<tblGLAccount>
    {
        public tblGLAccountMap()
        {
            // Primary Key
            this.HasKey(t => t.intAccountId);

            // Table & Column Mappings
            this.ToTable("tblGLAccount");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.strAccountId).HasColumnName("strAccountId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
        }
    }

    public class vyuAPVendorMap : EntityTypeConfiguration<vyuAPVendor>
    {
        public vyuAPVendorMap()
        {
            // Primary Key
            this.HasKey(t => t.intVendorId);

            // Table & Column Mappings
            this.ToTable("vyuAPVendor");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
            this.Property(t => t.strName).HasColumnName("strName");
            this.Property(t => t.strVendorAccountNum).HasColumnName("strVendorAccountNum");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
        }
    }

    public class tblARCustomerMap : EntityTypeConfiguration<tblARCustomer>
    {
        public tblARCustomerMap()
        {
            // Primary Key
            this.HasKey(t => t.intCustomerId);

            // Table & Column Mappings
            this.ToTable("tblARCustomer");
            this.Property(t => t.intCustomerId).HasColumnName("intCustomerId");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.strCustomerNumber).HasColumnName("strCustomerNumber");
            this.Property(t => t.strType).HasColumnName("strType");
        }
    }

    public class tblSMCountryMap : EntityTypeConfiguration<tblSMCountry>
    {
        public tblSMCountryMap()
        {
            // Primary Key
            this.HasKey(t => t.intCountryID);

            // Table & Column Mappings
            this.ToTable("tblSMCountry");
            this.Property(t => t.intCountryID).HasColumnName("intCountryID");
            this.Property(t => t.strCountry).HasColumnName("strCountry");   
        }
    }

    public class tblSTStoreMap : EntityTypeConfiguration<tblSTStore>
    {
        public tblSTStoreMap()
        {
            // Primary Key
            this.HasKey(t => t.intStoreId);

            // Table & Column Mappings
            this.ToTable("tblSTStore");
            this.Property(t => t.intStoreId).HasColumnName("intStoreId");
            this.Property(t => t.intStoreNo).HasColumnName("intStoreNo");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strDestrict).HasColumnName("strDestrict");
            this.Property(t => t.strRegion).HasColumnName("strRegion");
            this.Property(t => t.strStoreName).HasColumnName("strStoreName");
        }
    }

    public class tblSTSubcategoryClassMap : EntityTypeConfiguration<tblSTSubcategoryClass>
    {
        public tblSTSubcategoryClassMap()
        {
            // Primary Key
            this.HasKey(t => t.intClassId);

            // Table & Column Mappings
            this.ToTable("tblSTSubcategoryClass");
            this.Property(t => t.intClassId).HasColumnName("intClassId");
            this.Property(t => t.strClassComment).HasColumnName("strClassComment");
            this.Property(t => t.strClassDesc).HasColumnName("strClassDesc");
            this.Property(t => t.strClassId).HasColumnName("strClassId");
        }
    }

    public class tblSTSubcategoryFamilyMap : EntityTypeConfiguration<tblSTSubcategoryFamily>
    {
        public tblSTSubcategoryFamilyMap()
        {
            // Primary Key
            this.HasKey(t => t.intFamilyId);

            // Table & Column Mappings
            this.ToTable("tblSTSubcategoryFamily");
            this.Property(t => t.intFamilyId).HasColumnName("intFamilyId");
            this.Property(t => t.strFamilyComment).HasColumnName("strFamilyComment");
            this.Property(t => t.strFamilyDesc).HasColumnName("strFamilyDesc");
            this.Property(t => t.strFamilyId).HasColumnName("strFamilyId");
        }
    }

    public class tblSTSubcategoryRegProdMap : EntityTypeConfiguration<tblSTSubcategoryRegProd>
    {
        public tblSTSubcategoryRegProdMap()
        {
            // Primary Key
            this.HasKey(t => t.intRegProdId);

            // Table & Column Mappings
            this.ToTable("tblSTSubcategoryRegProd");
            this.Property(t => t.intRegProdId).HasColumnName("intRegProdId");
            this.Property(t => t.intStoreId).HasColumnName("intStoreId");
            this.Property(t => t.strRegProdCode).HasColumnName("strRegProdCode");
            this.Property(t => t.strRegProdComment).HasColumnName("strRegProdComment ");
            this.Property(t => t.strRegProdDesc).HasColumnName("strRegProdDesc");
        }
    }

    public class tblSTPaidOutMap : EntityTypeConfiguration<tblSTPaidOut>
    {
        public tblSTPaidOutMap()
        {
            // Primary Key
            this.HasKey(t => t.intPaidOutId);

            // Table & Column Mappings
            this.ToTable("tblSTPaidOut");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.intPaidOutId).HasColumnName("intPaidOutId");
            this.Property(t => t.intPaymentMethodId).HasColumnName("intPaymentMethodId");
            this.Property(t => t.intStoreId).HasColumnName("intStoreId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strPaidOutId).HasColumnName("strPaidOutId");
        }
    }

    public class tblGRStorageTypeMap : EntityTypeConfiguration<tblGRStorageType>
    {
        public tblGRStorageTypeMap()
        {
            // Primary Key
            this.HasKey(t => t.intStorageTypeId);

            // Table & Column Mappings
            this.ToTable("tblGRStorageType");
            this.Property(t => t.intStorageTypeId).HasColumnName("intStorageTypeId");
            this.Property(t => t.strStorageType).HasColumnName("strStorageType");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }

    public class tblSTPromotionSalesListMap : EntityTypeConfiguration<tblSTPromotionSalesList>
    {
        public tblSTPromotionSalesListMap()
        {
            // Primary Key
            this.HasKey(t => t.intPromoSalesListId);

            // Table & Column Mappings
            this.ToTable("tblSTPromotionSalesList");
            this.Property(t => t.dblPromoPrice).HasColumnName("dblPromoPrice");
            this.Property(t => t.intPromoSalesListId).HasColumnName("intPromoSalesListId");
            this.Property(t => t.intPromoUnits).HasColumnName("intPromoUnits");
            this.Property(t => t.intPromoCode).HasColumnName("intPromoCode");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strPromoType).HasColumnName("strPromoType");
        }
    }

}
