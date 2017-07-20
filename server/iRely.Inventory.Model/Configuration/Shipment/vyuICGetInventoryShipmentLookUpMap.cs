using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryShipmentLookUpMap : EntityTypeConfiguration<vyuICGetInventoryShipmentLookUp>
    {
        public vyuICGetInventoryShipmentLookUpMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryShipmentLookUp");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.strOrderType).HasColumnName("strOrderType");
            this.Property(t => t.strSourceType).HasColumnName("strSourceType");
            this.Property(t => t.strShipFromLocation).HasColumnName("strShipFromLocation");
            this.Property(t => t.strShipFromStreet).HasColumnName("strShipFromStreet");
            this.Property(t => t.strShipFromCity).HasColumnName("strShipFromCity");
            this.Property(t => t.strShipFromState).HasColumnName("strShipFromState");
            this.Property(t => t.strShipFromZipPostalCode).HasColumnName("strShipFromZipPostalCode");
            this.Property(t => t.strShipFromCountry).HasColumnName("strShipFromCountry");
            this.Property(t => t.strShipFromAddress).HasColumnName("strShipFromAddress");
            this.Property(t => t.strShipToLocation).HasColumnName("strShipToLocation");
            this.Property(t => t.strShipToStreet).HasColumnName("strShipToStreet");
            this.Property(t => t.strShipToCity).HasColumnName("strShipToCity");
            this.Property(t => t.strShipToState).HasColumnName("strShipToState");
            this.Property(t => t.strShipToZipPostalCode).HasColumnName("strShipToZipPostalCode");
            this.Property(t => t.strShipToCountry).HasColumnName("strShipToCountry");
            this.Property(t => t.strShipToAddress).HasColumnName("strShipToAddress");
            this.Property(t => t.strCustomerNumber).HasColumnName("strCustomerNumber");
            this.Property(t => t.strCustomerName).HasColumnName("strCustomerName");
            this.Property(t => t.strFreightTerm).HasColumnName("strFreightTerm");
            this.Property(t => t.strFobPoint).HasColumnName("strFobPoint");
            this.Property(t => t.strShipVia).HasColumnName("strShipVia");
            this.Property(t => t.intWarehouseInstructionHeaderId).HasColumnName("intWarehouseInstructionHeaderId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
        }
    }
}
