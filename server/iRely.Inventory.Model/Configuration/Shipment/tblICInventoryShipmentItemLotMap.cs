using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICInventoryShipmentItemLotMap : EntityTypeConfiguration<tblICInventoryShipmentItemLot>
    {
        public tblICInventoryShipmentItemLotMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentItemLotId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryShipmentItemLot");
            this.Property(t => t.intInventoryShipmentItemLotId).HasColumnName("intInventoryShipmentItemLotId");
            this.Property(t => t.intInventoryShipmentItemId).HasColumnName("intInventoryShipmentItemId");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.dblQuantityShipped).HasColumnName("dblQuantityShipped").HasPrecision(38, 20);
            this.Property(t => t.dblGrossWeight).HasColumnName("dblGrossWeight").HasPrecision(38, 20);
            this.Property(t => t.dblTareWeight).HasColumnName("dblTareWeight").HasPrecision(38, 20);
            this.Property(t => t.dblWeightPerQty).HasColumnName("dblWeightPerQty").HasPrecision(38, 20);
            this.Property(t => t.strWarehouseCargoNumber).HasColumnName("strWarehouseCargoNumber");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICLot)
                .WithMany(p => p.tblICInventoryShipmentItemLots)
                .HasForeignKey(p => p.intLotId);
        }
    }
}
