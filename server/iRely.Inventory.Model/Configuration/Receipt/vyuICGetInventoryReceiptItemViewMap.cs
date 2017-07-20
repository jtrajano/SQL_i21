using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptItemViewMap : EntityTypeConfiguration<vyuICGetInventoryReceiptItemView>
    {
        public vyuICGetInventoryReceiptItemViewMap()
        {
            this.HasKey(p => p.intInventoryReceiptItemId);

            this.ToTable("vyuICGetInventoryReceiptItemView");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.dblReceived).HasColumnName("dblReceived").HasPrecision(9, 6);
            this.Property(t => t.dblBillQty).HasColumnName("dblBillQty").HasPrecision(9, 6);
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.strOrderNumber).HasColumnName("strOrderNumber");
            this.Property(t => t.strSourceNumber).HasColumnName("strSourceNumber");
            this.Property(t => t.strSourceType).HasColumnName("strSourceType");
        }
    }
}
