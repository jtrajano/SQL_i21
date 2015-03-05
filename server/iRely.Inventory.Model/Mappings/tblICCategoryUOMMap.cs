using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCategoryUOMMap: EntityTypeConfiguration<tblICCategoryUOM>
    {
        public tblICCategoryUOMMap()
        {
            // Primary Key
            this.HasKey(t => t.intCategoryUOMId);

            // Table & Column Mappings
            this.ToTable("tblICCategoryUOM");
            this.Property(t => t.intCategoryUOMId).HasColumnName("intCategoryUOMId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty");
            this.Property(t => t.dblSellQty).HasColumnName("dblSellQty");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strUpcCode).HasColumnName("strUpcCode");
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
            this.Property(t => t.ysnAllowPurchase).HasColumnName("ysnAllowPurchase");
            this.Property(t => t.ysnAllowSale).HasColumnName("ysnAllowSale");
            this.Property(t => t.dblLength).HasColumnName("dblLength");
            this.Property(t => t.dblWidth).HasColumnName("dblWidth");
            this.Property(t => t.dblHeight).HasColumnName("dblHeight");
            this.Property(t => t.intDimensionUOMId).HasColumnName("intDimensionUOMId");
            this.Property(t => t.dblVolume).HasColumnName("dblVolume");
            this.Property(t => t.intVolumeUOMId).HasColumnName("intVolumeUOMId");
            this.Property(t => t.dblMaxQty).HasColumnName("dblMaxQty");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasRequired(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICCategoryUOMs)
                .HasForeignKey(p => p.intUnitMeasureId);
            this.HasOptional(p => p.WeightUOM)
                .WithMany(p => p.WeightCategoryUOMs)
                .HasForeignKey(p => p.intWeightUOMId);
            this.HasOptional(p => p.DimensionUOM)
                .WithMany(p => p.DimensionCategoryUOMs)
                .HasForeignKey(p => p.intDimensionUOMId);
            this.HasOptional(p => p.VolumeUOM)
                .WithMany(p => p.VolumeCategoryUOMs)
                .HasForeignKey(p => p.intVolumeUOMId);
        }
    }
}
