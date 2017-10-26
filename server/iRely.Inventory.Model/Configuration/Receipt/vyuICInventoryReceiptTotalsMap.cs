using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICInventoryReceiptTotalsMap : EntityTypeConfiguration<vyuICInventoryReceiptTotals>
    {
        public vyuICInventoryReceiptTotalsMap()
        {
            this.HasKey(k => k.intInventoryReceiptId);
            this.ToTable("vyuICInventoryReceiptTotals");
            this.Property(e => e.dblTotalCharge).HasColumnName("dblTotalCharge");
            this.Property(e => e.dblTotalChargeTax).HasColumnName("dblTotalChargeTax");
            this.Property(e => e.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
        }
    }
}
