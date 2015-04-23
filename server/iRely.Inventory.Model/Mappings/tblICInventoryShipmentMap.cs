﻿using System.ComponentModel.DataAnnotations.Schema;
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
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.dblUnitPrice).HasColumnName("dblUnitPrice").HasPrecision(18, 6);
            this.Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            this.Property(t => t.intDockDoorId).HasColumnName("intDockDoorId");
            this.Property(t => t.strNotes).HasColumnName("strNotes");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasMany(p => p.tblICInventoryShipmentItemLots)
                .WithRequired(p => p.tblICInventoryShipmentItem)
                .HasForeignKey(p => p.intInventoryShipmentItemId);

            this.HasOptional(p => p.tblICItem)
                .WithMany(p => p.tblICInventoryShipmentItems)
                .HasForeignKey(p => p.intItemId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICInventoryShipmentItems)
                .HasForeignKey(p => p.intItemUOMId);
            this.HasOptional(p => p.tblSMCompanyLocationSubLocation)
                .WithMany(p => p.tblICInventoryShipmentItems)
                .HasForeignKey(p => p.intSubLocationId);
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
            this.Property(t => t.dblQuantityShipped).HasColumnName("dblQuantityShipped").HasPrecision(18, 6);
            this.Property(t => t.intInventoryShipmentItemId).HasColumnName("intInventoryShipmentItemId");
            this.Property(t => t.intInventoryShipmentItemLotId).HasColumnName("intInventoryShipmentItemLotId");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strWarehouseCargoNumber).HasColumnName("strWarehouseCargoNumber");

        }
    }
}
