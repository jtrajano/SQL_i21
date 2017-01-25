using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class vyuICItemUOMMap : EntityTypeConfiguration<vyuICItemUOM>
    {
        public vyuICItemUOMMap()
        {
            this.HasKey(t => t.intItemUOMId);

            this.ToTable("vyuICItemUOM");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strCategoryCode).HasColumnName("strCategoryCode");
            this.Property(t => t.strCategory).HasColumnName("strCategory");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId ");
            this.Property(t => t.strCommodity).HasColumnName("strCommodity");
            this.Property(t => t.strCommodityCode).HasColumnName("strCommodityCode");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strStockUOM).HasColumnName("strStockUOM");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
            this.Property(t => t.ysnAllowPurchase).HasColumnName("ysnAllowPurchase");
            this.Property(t => t.ysnAllowSale).HasColumnName("ysnAllowSale");
            this.Property(t => t.dblMaxQty).HasColumnName("dblMaxQty");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty");
            this.Property(t => t.dblHeight).HasColumnName("dblHeight");
            this.Property(t => t.dblLength).HasColumnName("dblLength");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight");
            this.Property(t => t.dblVolume).HasColumnName("dblVolume");
        }
    }
}
