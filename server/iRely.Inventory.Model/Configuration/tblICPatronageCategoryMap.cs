using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICPatronageCategoryMap : EntityTypeConfiguration<tblICPatronageCategory>
    {
        public tblICPatronageCategoryMap()
        {
            // Primary Key
            this.HasKey(t => t.intPatronageCategoryId);

            // Table & Column Mappings
            this.ToTable("tblICPatronageCategory");
            this.Property(t => t.intPatronageCategoryId).HasColumnName("intPatronageCategoryId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strCategoryCode).HasColumnName("strCategoryCode");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strPurchaseSale).HasColumnName("strPurchaseSale");
            this.Property(t => t.strUnitAmount).HasColumnName("strUnitAmount");
        }
    }
}
