using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemUOMMap : EntityTypeConfiguration<tblICItemUOM>
    {
        public tblICItemUOMMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemUOMId);

            // Table & Column Mappings
            this.ToTable("tblICItemUOM");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty").HasPrecision(18, 6);
            this.Property(t => t.dblWeight).HasColumnName("dblWeight").HasPrecision(18, 6);
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strUpcCode).HasColumnName("strUpcCode");
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
            this.Property(t => t.ysnAllowPurchase).HasColumnName("ysnAllowPurchase");
            this.Property(t => t.ysnAllowSale).HasColumnName("ysnAllowSale");
            this.Property(t => t.dblLength).HasColumnName("dblLength").HasPrecision(18, 6);
            this.Property(t => t.dblWidth).HasColumnName("dblWidth").HasPrecision(18, 6);
            this.Property(t => t.dblHeight).HasColumnName("dblHeight").HasPrecision(18, 6);
            this.Property(t => t.intDimensionUOMId).HasColumnName("intDimensionUOMId");
            this.Property(t => t.dblVolume).HasColumnName("dblVolume").HasPrecision(18, 6);
            this.Property(t => t.intVolumeUOMId).HasColumnName("intVolumeUOMId");
            this.Property(t => t.dblMaxQty).HasColumnName("dblMaxQty").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasRequired(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICItemUOMs)
                .HasForeignKey(p => p.intUnitMeasureId);
            this.HasOptional(p => p.WeightUOM)
                .WithMany(p => p.WeightItemUOMs)
                .HasForeignKey(p => p.intWeightUOMId);
            this.HasOptional(p => p.DimensionUOM)
                .WithMany(p => p.DimensionItemUOMs)
                .HasForeignKey(p => p.intDimensionUOMId);
            this.HasOptional(p => p.VolumeUOM)
                .WithMany(p => p.VolumeItemUOMs)
                .HasForeignKey(p => p.intVolumeUOMId);
        }
    }
}
