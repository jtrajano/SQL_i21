using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICRinFuelCategoryMap : EntityTypeConfiguration<tblICRinFuelCategory>
    {
        public tblICRinFuelCategoryMap()
        {
            // Primary Key
            this.HasKey(t => t.intRinFuelCategoryId);

            // Table & Column Mappings
            this.ToTable("tblICRinFuelCategory");
            this.Property(t => t.intRinFuelCategoryId).HasColumnName("intRinFuelCategoryId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strEquivalenceValue).HasColumnName("strEquivalenceValue");
            this.Property(t => t.strRinFuelCategoryCode).HasColumnName("strRinFuelCategoryCode");
        }
    }
}
