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
            this.Property(t => t.dblHeight).HasColumnName("dblHeight");
            this.Property(t => t.dblLength).HasColumnName("dblLength");
            this.Property(t => t.dblMaxQty).HasColumnName("dblMaxQty");
            this.Property(t => t.dblSellQty).HasColumnName("dblSellQty");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty");
            this.Property(t => t.dblVolume).HasColumnName("dblVolume");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight");
            this.Property(t => t.dblWidth).HasColumnName("dblWidth");
            
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
            this.Property(t => t.ysnAllowPurchase).HasColumnName("ysnAllowPurchase");
            this.Property(t => t.ysnAllowSale).HasColumnName("ysnAllowSale");
            this.Property(t => t.dblConvertToStock).HasColumnName("dblConvertToStock");
            this.Property(t => t.dblConvertFromStock).HasColumnName("dblConvertFromStock");

            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");

            this.HasRequired(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICItemUOMs)
                .HasForeignKey(p => p.intUnitMeasureId);
        }
    }
}
