using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICStockReservationMap: EntityTypeConfiguration<tblICStockReservation>
    {
        public tblICStockReservationMap()
        {
            // Primary Key
            this.HasKey(t => t.intStockReservationId);

            // Table & Column Mappings
            this.ToTable("tblICStockReservation");
            this.Property(t => t.intStockReservationId).HasColumnName("intStockReservationId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.intTransactionId).HasColumnName("intTransactionId");
            this.Property(t => t.strTransactionId).HasColumnName("strTransactionId");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }
}
