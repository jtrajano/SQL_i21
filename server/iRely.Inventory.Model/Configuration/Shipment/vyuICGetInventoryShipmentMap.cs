﻿using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryShipmentMap : EntityTypeConfiguration<vyuICGetInventoryShipment>
    {
        public vyuICGetInventoryShipmentMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryShipment");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.strShipmentNumber).HasColumnName("strShipmentNumber");
            this.Property(t => t.dtmShipDate).HasColumnName("dtmShipDate");
            this.Property(t => t.intOrderType).HasColumnName("intOrderType");
            this.Property(t => t.strOrderType).HasColumnName("strOrderType");
            this.Property(t => t.intSourceType).HasColumnName("intSourceType");
            this.Property(t => t.strSourceType).HasColumnName("strSourceType");
            this.Property(t => t.strReferenceNumber).HasColumnName("strReferenceNumber");
            this.Property(t => t.dtmRequestedArrivalDate).HasColumnName("dtmRequestedArrivalDate");
            this.Property(t => t.intShipFromLocationId).HasColumnName("intShipFromLocationId");
            this.Property(t => t.strShipFromLocation).HasColumnName("strShipFromLocation");
            this.Property(t => t.strShipFromStreet).HasColumnName("strShipFromStreet");
            this.Property(t => t.strShipFromCity).HasColumnName("strShipFromCity");
            this.Property(t => t.strShipFromState).HasColumnName("strShipFromState");
            this.Property(t => t.strShipFromZipPostalCode).HasColumnName("strShipFromZipPostalCode");
            this.Property(t => t.strShipFromCountry).HasColumnName("strShipFromCountry");
            this.Property(t => t.strShipFromAddress).HasColumnName("strShipFromAddress");
            this.Property(t => t.intShipToCompanyLocationId).HasColumnName("intShipToCompanyLocationId");
            this.Property(t => t.strShipToLocation).HasColumnName("strShipToLocation");
            this.Property(t => t.strShipToStreet).HasColumnName("strShipToStreet");
            this.Property(t => t.strShipToCity).HasColumnName("strShipToCity");
            this.Property(t => t.strShipToState).HasColumnName("strShipToState");
            this.Property(t => t.strShipToZipPostalCode).HasColumnName("strShipToZipPostalCode");
            this.Property(t => t.strShipToCountry).HasColumnName("strShipToCountry");
            this.Property(t => t.strShipToAddress).HasColumnName("strShipToAddress");
            this.Property(t => t.intEntityCustomerId).HasColumnName("intEntityCustomerId");
            this.Property(t => t.strCustomerNumber).HasColumnName("strCustomerNumber");
            this.Property(t => t.strCustomerName).HasColumnName("strCustomerName");
            this.Property(t => t.intShipToLocationId).HasColumnName("intShipToLocationId");
            this.Property(t => t.intFreightTermId).HasColumnName("intFreightTermId");
            this.Property(t => t.strFreightTerm).HasColumnName("strFreightTerm");
            this.Property(t => t.strFobPoint).HasColumnName("strFobPoint");
            this.Property(t => t.strBOLNumber).HasColumnName("strBOLNumber");
            this.Property(t => t.intShipViaId).HasColumnName("intShipViaId");
            this.Property(t => t.strShipVia).HasColumnName("strShipVia");
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
            this.Property(t => t.intWarehouseInstructionHeaderId).HasColumnName("intWarehouseInstructionHeaderId");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.strFreeTime).HasColumnName("strFreeTime");
        }
    }
}
