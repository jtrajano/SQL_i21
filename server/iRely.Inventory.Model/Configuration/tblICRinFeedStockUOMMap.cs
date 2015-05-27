using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICRinFeedStockUOMMap : EntityTypeConfiguration<tblICRinFeedStockUOM>
    {
        public tblICRinFeedStockUOMMap()
        {
            // Primary Key
            this.HasKey(t => t.intRinFeedStockUOMId);

            // Table & Column Mappings
            this.ToTable("tblICRinFeedStockUOM");
            this.Property(t => t.intRinFeedStockUOMId).HasColumnName("intRinFeedStockUOMId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strRinFeedStockUOMCode).HasColumnName("strRinFeedStockUOMCode");

            this.HasOptional(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICRinFeedStockUOMs)
                .HasForeignKey(p => p.intUnitMeasureId);
        }
    }
}
