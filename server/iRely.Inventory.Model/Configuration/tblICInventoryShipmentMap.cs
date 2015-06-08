using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICInventoryShipmentMap : EntityTypeConfiguration<tblICInventoryShipment>
    {
        public tblICInventoryShipmentMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryShipment");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.strShipmentNumber).HasColumnName("strShipmentNumber");
            this.Property(t => t.dtmShipDate).HasColumnName("dtmShipDate");
            this.Property(t => t.intOrderType).HasColumnName("intOrderType");
            this.Property(t => t.intSourceType).HasColumnName("intSourceType");
            this.Property(t => t.strReferenceNumber).HasColumnName("strReferenceNumber");
            this.Property(t => t.dtmRequestedArrivalDate).HasColumnName("dtmRequestedArrivalDate");
            this.Property(t => t.intShipFromLocationId).HasColumnName("intShipFromLocationId");
            this.Property(t => t.intEntityCustomerId).HasColumnName("intEntityCustomerId");
            this.Property(t => t.intShipToLocationId).HasColumnName("intShipToLocationId");
            this.Property(t => t.intFreightTermId).HasColumnName("intFreightTermId");
            this.Property(t => t.strBOLNumber).HasColumnName("strBOLNumber");
            this.Property(t => t.intShipViaId).HasColumnName("intShipViaId");
            this.Property(t => t.strVessel).HasColumnName("strVessel");
            this.Property(t => t.strProNumber).HasColumnName("strProNumber");
            this.Property(t => t.strDriverId).HasColumnName("strDriverId");
            this.Property(t => t.strSealNumber).HasColumnName("strSealNumber");
            this.Property(t => t.strDeliveryInstruction).HasColumnName("strDeliveryInstruction");
            this.Property(t => t.dtmAppointmentTime).HasColumnName("dtmAppointmentTime");
            this.Property(t => t.dtmDepartureTime).HasColumnName("dtmDepartureTime");
            this.Property(t => t.dtmArrivalTime).HasColumnName("dtmArrivalTime");
            this.Property(t => t.dtmDeliveredDate).HasColumnName("dtmDeliveredDate");
            this.Property(t => t.dtmFreeTime).HasColumnName("dtmFreeTime");
            this.Property(t => t.strReceivedBy).HasColumnName("strReceivedBy");
            this.Property(t => t.strComment).HasColumnName("strComment");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.intCreatedUserId).HasColumnName("intCreatedUserId");

            this.HasMany(p => p.tblICInventoryShipmentItems)
                .WithRequired(p => p.tblICInventoryShipment)
                .HasForeignKey(p => p.intInventoryShipmentId);
            this.HasOptional(p => p.ShipFromLocation)
                .WithMany(p => p.ShipFromLocations)
                .HasForeignKey(p => p.intShipFromLocationId);
            this.HasOptional(p => p.ShipToLocation)
                .WithMany(p => p.tblICInventoryShipments)
                .HasForeignKey(p => p.intShipToLocationId);
        }
    }

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
            this.Property(t => t.intOwnershipType).HasColumnName("intOwnershipType");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.dblUnitPrice).HasColumnName("dblUnitPrice").HasPrecision(18, 6);
            this.Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            this.Property(t => t.intDockDoorId).HasColumnName("intDockDoorId");
            this.Property(t => t.strNotes).HasColumnName("strNotes");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasMany(p => p.tblICInventoryShipmentItemLots)
                .WithRequired(p => p.tblICInventoryShipmentItem)
                .HasForeignKey(p => p.intInventoryShipmentItemId);

            this.HasOptional(p => p.vyuICGetInventoryShipmentItem)
                .WithRequired(p => p.tblICInventoryShipmentItem);
        }
    }

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
            this.Property(t => t.dblQuantityShipped).HasColumnName("dblQuantityShipped").HasPrecision(18, 6);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.dblGrossWeight).HasColumnName("dblGrossWeight").HasPrecision(18, 6);
            this.Property(t => t.dblTareWeight).HasColumnName("dblTareWeight").HasPrecision(18, 6);
            this.Property(t => t.strWarehouseCargoNumber).HasColumnName("strWarehouseCargoNumber");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICLot)
                .WithMany(p => p.tblICInventoryShipmentItemLots)
                .HasForeignKey(p => p.intLotId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.ShipmentItemLots)
                .HasForeignKey(p => p.intItemUOMId);
            this.HasOptional(p => p.WeightUOM)
                .WithMany(p => p.WeightShipmentItemLot)
                .HasForeignKey(p => p.intWeightUOMId);
        }
    }

    public class vyuICGetInventoryShipmentItemMap : EntityTypeConfiguration<vyuICGetInventoryShipmentItem>
    {
        public vyuICGetInventoryShipmentItemMap()
        {
            // Primary Key
            this.HasKey(p => p.intInventoryShipmentItemId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryShipmentItem");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.intInventoryShipmentItemId).HasColumnName("intInventoryShipmentItemId");
            this.Property(t => t.intLineNo).HasColumnName("intLineNo");
            this.Property(t => t.intOrderId).HasColumnName("intOrderId");
            this.Property(t => t.strOrderNumber).HasColumnName("strOrderNumber");
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.strSourceNumber).HasColumnName("strSourceNumber");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.strOrderUOM).HasColumnName("strOrderUOM");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.dblQtyOrdered).HasColumnName("dblQtyOrdered").HasPrecision(18, 6);
            this.Property(t => t.dblQtyAllocated).HasColumnName("dblQtyAllocated").HasPrecision(18, 6);
            this.Property(t => t.dblUnitPrice).HasColumnName("dblUnitPrice").HasPrecision(18, 6);
            this.Property(t => t.dblDiscount).HasColumnName("dblDiscount").HasPrecision(18, 6);
            this.Property(t => t.dblTotal).HasColumnName("dblTotal").HasPrecision(18, 6);
        }
    }
}
