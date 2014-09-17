using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemMap : EntityTypeConfiguration<tblICItem>
    {
        public tblICItemMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemId);

            // Table & Column Mappings
            this.ToTable("tblICItem");
            this.Property(t => t.intBrandId).HasColumnName("intBrandId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intManufacturerId).HasColumnName("intManufacturerId");
            this.Property(t => t.intTrackingId).HasColumnName("intTrackingId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.strModelNo).HasColumnName("strModelNo");
            this.Property(t => t.strStatus).HasColumnName("strStatus");
            this.Property(t => t.strType).HasColumnName("strType");

            this.HasMany(p => p.tblICItemUOMs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
        }
    }
}
