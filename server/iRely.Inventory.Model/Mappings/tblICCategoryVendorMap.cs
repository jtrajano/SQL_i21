using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCategoryVendorMap : EntityTypeConfiguration<tblICCategoryVendor>
    {
        public tblICCategoryVendorMap()
        {
            // Primary Key
            this.HasKey(t => t.intCategoryVendorId);

            // Table & Column Mappings
            this.ToTable("tblICCategoryVendor");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intCategoryVendorId).HasColumnName("intCategoryVendorId");
            this.Property(t => t.intFamilyId).HasColumnName("intFamilyId");
            this.Property(t => t.intOrderClassId).HasColumnName("intOrderClassId");
            this.Property(t => t.intSellClassId).HasColumnName("intSellClassId");
            this.Property(t => t.intStoreId).HasColumnName("intStoreId");
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
            this.Property(t => t.strComments).HasColumnName("strComments");
            this.Property(t => t.strVendorDepartment).HasColumnName("strVendorDepartment");
            this.Property(t => t.ysnAddNewRecords).HasColumnName("ysnAddNewRecords");
            this.Property(t => t.ysnAddOrderingUPC).HasColumnName("ysnAddOrderingUPC");
            this.Property(t => t.ysnUpdateExistingRecords).HasColumnName("ysnUpdateExistingRecords");
            this.Property(t => t.ysnUpdatePrice).HasColumnName("ysnUpdatePrice");
        }
    }
}
