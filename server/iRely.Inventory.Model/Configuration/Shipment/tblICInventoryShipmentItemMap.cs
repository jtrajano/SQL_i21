using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICInventoryShipmentItemMap : EntityTypeConfiguration<tblICInventoryShipmentItem>
    {
        public tblICInventoryShipmentItemMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentItemId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryShipmentItem");
            this.Property(t => t.intInventoryShipmentItemId).HasColumnName("intInventoryShipmentItemId");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.intOrderId).HasColumnName("intOrderId");
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.intLineNo).HasColumnName("intLineNo");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intOwnershipType).HasColumnName("intOwnershipType");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.dblUnitPrice).HasColumnName("dblUnitPrice").HasPrecision(38, 20);
            this.Property(t => t.intDockDoorId).HasColumnName("intDockDoorId");
            this.Property(t => t.strNotes).HasColumnName("strNotes");
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.intDiscountSchedule).HasColumnName("intDiscountSchedule");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intStorageScheduleTypeId).HasColumnName("intStorageScheduleTypeId");
            this.Property(t => t.intDestinationGradeId).HasColumnName("intDestinationGradeId");
            this.Property(t => t.intDestinationWeightId).HasColumnName("intDestinationWeightId");
            // this.Property(t => t.intDestinationQtyUOMId).HasColumnName("intDestinationQtyUOMId");
            // this.Property(t => t.dblDestinationGrossQty).HasColumnName("dblDestinationGrossQty");
            // this.Property(t => t.dblDestinationNetQty).HasColumnName("dblDestinationNetQty");
            this.Property(t => t.intForexRateTypeId).HasColumnName("intForexRateTypeId");
            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate").HasPrecision(18, 6);
            this.Property(t => t.dblDestinationQuantity).HasColumnName("dblDestinationQuantity").HasPrecision(38, 20);
            this.Property(t => t.strChargesLink).HasColumnName("strChargesLink");
            this.Property(t => t.strItemType).HasColumnName("strItemType");
            this.Property(t => t.intParentItemLinkId).HasColumnName("intParentItemLinkId");
            this.Property(t => t.intChildItemLinkId).HasColumnName("intChildItemLinkId");

            this.HasMany(p => p.tblICInventoryShipmentItemLots)
                .WithRequired(p => p.tblICInventoryShipmentItem)
                .HasForeignKey(p => p.intInventoryShipmentItemId);

            this.HasOptional(p => p.vyuICGetInventoryShipmentItem)
                .WithRequired(p => p.tblICInventoryShipmentItem);
        }
    }
}
