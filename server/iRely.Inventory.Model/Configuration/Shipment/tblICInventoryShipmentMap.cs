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
            this.Property(t => t.strReceivedBy).HasColumnName("strReceivedBy");
            this.Property(t => t.strComment).HasColumnName("strComment");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.intCreatedUserId).HasColumnName("intCreatedUserId");
            this.Property(t => t.intShipToCompanyLocationId).HasColumnName("intShipToCompanyLocationId");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strFreeTime).HasColumnName("strFreeTime");

            this.HasMany(p => p.tblICInventoryShipmentItems)
                .WithRequired(p => p.tblICInventoryShipment)
                .HasForeignKey(p => p.intInventoryShipmentId);
            this.HasMany(p => p.tblICInventoryShipmentCharges)
                .WithRequired(p => p.tblICInventoryShipment)
                .HasForeignKey(p => p.intInventoryShipmentId);
            this.HasOptional(p => p.vyuICGetInventoryShipmentLookUp)
                .WithRequired(p => p.tblICInventoryShipment);
                
        }
    }
   
}
