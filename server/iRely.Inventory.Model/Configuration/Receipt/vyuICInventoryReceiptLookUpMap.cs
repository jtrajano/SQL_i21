using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICInventoryReceiptLookUpMap : EntityTypeConfiguration<vyuICInventoryReceiptLookUp>
    {
        public vyuICInventoryReceiptLookUpMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptId);

            // Table & Column Mappings
            this.ToTable("vyuICInventoryReceiptLookUp");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.strVendorName).HasColumnName("strVendorName");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strFobPoint).HasColumnName("strFobPoint");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.strFromLocation).HasColumnName("strFromLocation");
            this.Property(t => t.strUserName).HasColumnName("strUserName");
            this.Property(t => t.strShipFrom).HasColumnName("strShipFrom");
            this.Property(t => t.strShipVia).HasColumnName("strShipVia");
            this.Property(t => t.strFreightTerm).HasColumnName("strFreightTerm");
        }
    }
}
