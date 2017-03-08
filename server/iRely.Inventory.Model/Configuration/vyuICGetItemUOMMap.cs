using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemUOMMap : EntityTypeConfiguration<vyuICGetItemUOM>
    {
        public vyuICGetItemUOMMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemUOMId);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemUOM");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.strUpcCode).HasColumnName("strUpcCode");
            this.Property(t => t.strLongUPCCode).HasColumnName("strLongUPCCode");
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
            this.Property(t => t.ysnAllowPurchase).HasColumnName("ysnAllowPurchase");
            this.Property(t => t.ysnAllowSale).HasColumnName("ysnAllowSale");
            this.Property(t => t.dblLength).HasColumnName("dblLength");
            this.Property(t => t.dblWidth).HasColumnName("dblWidth");
            this.Property(t => t.dblHeight).HasColumnName("dblHeight");
            this.Property(t => t.intDimensionUOMId).HasColumnName("intDimensionUOMId");
            this.Property(t => t.strDimensionUOM).HasColumnName("strDimensionUOM");
            this.Property(t => t.dblVolume).HasColumnName("dblVolume");
            this.Property(t => t.intVolumeUOMId).HasColumnName("intVolumeUOMId");
            this.Property(t => t.strVolumeUOM).HasColumnName("strVolumeUOM");
            this.Property(t => t.dblMaxQty).HasColumnName("dblMaxQty");
        }
    }
}
