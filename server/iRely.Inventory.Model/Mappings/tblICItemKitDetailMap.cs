using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemKitDetailMap : EntityTypeConfiguration<tblICItemKitDetail>
    {
        public tblICItemKitDetailMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemKitDetailId);

            // Table & Column Mappings
            this.ToTable("tblICItemKitDetail");
            this.Property(t => t.intItemKitDetailId).HasColumnName("intItemKitDetailId");
            this.Property(t => t.intItemKitId).HasColumnName("intItemKitId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.dblPrice).HasColumnName("dblPrice").HasPrecision(18, 6);
            this.Property(t => t.ysnSelected).HasColumnName("ysnSelected");
            this.Property(t => t.inSort).HasColumnName("inSort");

            this.HasOptional(p => p.tblICItem)
                .WithMany(p => p.tblICItemKitDetails)
                .HasForeignKey(p => p.intItemId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICItemKitDetails)
                .HasForeignKey(p => p.intItemUnitMeasureId);
        }
    }
}
