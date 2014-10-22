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
}
