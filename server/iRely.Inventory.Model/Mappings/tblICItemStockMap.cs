using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemStockMap : EntityTypeConfiguration<tblICItemStock>
    {
        public tblICItemStockMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemStockId);

            // Table & Column Mappings
            this.ToTable("tblICItemStock");
            this.Property(t => t.dblLeadTime).HasColumnName("dblLeadTime");
            this.Property(t => t.dblMinOrder).HasColumnName("dblMinOrder");
            this.Property(t => t.dblOnOrder).HasColumnName("dblOnOrder");
            this.Property(t => t.dblOrderCommitted).HasColumnName("dblOrderCommitted");
            this.Property(t => t.dblReorderPoint).HasColumnName("dblReorderPoint");
            this.Property(t => t.dblSuggestedQuantity).HasColumnName("dblSuggestedQuantity");
            this.Property(t => t.dblUnitOnHand).HasColumnName("dblUnitOnHand");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemStockId).HasColumnName("intItemStockId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strCounted).HasColumnName("strCounted");
            this.Property(t => t.strInventoryGroup).HasColumnName("strInventoryGroup");
            this.Property(t => t.strWarehouse).HasColumnName("strWarehouse");
            this.Property(t => t.ysnCountedDaily).HasColumnName("ysnCountedDaily");
        }
    }
}
