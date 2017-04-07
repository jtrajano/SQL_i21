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
            this.ToTable("vyuICItemStock");
            this.Property(t => t.intItemStockId).HasColumnName("intItemStockId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.dblOnOrder).HasColumnName("dblOnOrder").HasPrecision(38, 20);
            this.Property(t => t.dblInTransitInbound).HasColumnName("dblInTransitInbound").HasPrecision(38, 20);
            this.Property(t => t.dblUnitOnHand).HasColumnName("dblUnitOnHand").HasPrecision(38, 20);
            this.Property(t => t.dblInTransitOutbound).HasColumnName("dblInTransitOutbound").HasPrecision(38, 20);
            this.Property(t => t.dblBackOrder).HasColumnName("dblBackOrder").HasPrecision(38, 20);
            this.Property(t => t.dblOrderCommitted).HasColumnName("dblOrderCommitted").HasPrecision(38, 20);
            this.Property(t => t.dblUnitStorage).HasColumnName("dblUnitStorage").HasPrecision(38, 20);
            this.Property(t => t.dblConsignedPurchase).HasColumnName("dblConsignedPurchase").HasPrecision(38, 20);
            this.Property(t => t.dblConsignedSale).HasColumnName("dblConsignedSale").HasPrecision(38, 20);
            this.Property(t => t.dblUnitReserved).HasColumnName("dblUnitReserved").HasPrecision(38, 20);
            this.Property(t => t.dblLastCountRetail).HasColumnName("dblLastCountRetail").HasPrecision(38, 20);
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
        }
    }
}
