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
            this.Property(t => t.dblOnOrder).HasColumnName("dblOnOrder");
            this.Property(t => t.dblOrderCommitted).HasColumnName("dblOrderCommitted");
            this.Property(t => t.dblUnitOnHand).HasColumnName("dblUnitOnHand");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemStockId).HasColumnName("intItemStockId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.dblAverageCost).HasColumnName("dblAverageCost");
            this.Property(t => t.dblLastCountRetail).HasColumnName("dblLastCountRetail");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");

            this.HasOptional(p => p.tblICItemLocation)
                .WithMany(p => p.tblICItemStocks)
                .HasForeignKey(p => p.intLocationId);
        }
    }
}
