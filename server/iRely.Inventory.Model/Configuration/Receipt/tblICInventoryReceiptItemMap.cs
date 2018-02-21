using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICInventoryReceiptItemMap : EntityTypeConfiguration<tblICInventoryReceiptItem>
    {
        public tblICInventoryReceiptItemMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptItemId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryReceiptItem");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intLineNo).HasColumnName("intLineNo");
            this.Property(t => t.intOrderId).HasColumnName("intOrderId");
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intContainerId).HasColumnName("intContainerId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intOwnershipType).HasColumnName("intOwnershipType");
            this.Property(t => t.dblOrderQty).HasColumnName("dblOrderQty").HasPrecision(38, 15);
            this.Property(t => t.dblBillQty).HasColumnName("dblBillQty").HasPrecision(38, 15);
            this.Property(t => t.dblOpenReceive).HasColumnName("dblOpenReceive").HasPrecision(38, 15);
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.dblUnitCost).HasColumnName("dblUnitCost").HasPrecision(38, 15);
            this.Property(t => t.dblUnitRetail).HasColumnName("dblUnitRetail").HasPrecision(38, 15);
            this.Property(t => t.dblLineTotal).HasColumnName("dblLineTotal").HasPrecision(38, 15);
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.dblGross).HasColumnName("dblGross").HasPrecision(38, 15);
            this.Property(t => t.dblNet).HasColumnName("dblNet").HasPrecision(38, 15);
            this.Property(t => t.dblTax).HasColumnName("dblTax").HasPrecision(38, 15);
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.ysnSubCurrency).HasColumnName("ysnSubCurrency");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.intForexRateTypeId).HasColumnName("intForexRateTypeId");
            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate").HasPrecision(18, 6);
            this.Property(t => t.ysnLotWeightsRequired).HasColumnName("ysnLotWeightsRequired");
            this.Property(t => t.strChargesLink).HasColumnName("strChargesLink");
            this.Property(t => t.strItemType).HasColumnName("strItemType");
            this.Property(t => t.intParentItemLinkId).HasColumnName("intParentItemLinkId");
            this.Property(t => t.intChildItemLinkId).HasColumnName("intChildItemLinkId");

            this.HasOptional(p => p.vyuICInventoryReceiptItemLookUp)
                .WithRequired(p => p.tblICInventoryReceiptItem);
            this.HasMany(p => p.tblICInventoryReceiptItemLots)
                .WithRequired(p => p.tblICInventoryReceiptItem)
                .HasForeignKey(p => p.intInventoryReceiptItemId);

        }
    }
}
