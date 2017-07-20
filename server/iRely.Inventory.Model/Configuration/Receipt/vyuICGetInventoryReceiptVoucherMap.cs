using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;
using System.ComponentModel.DataAnnotations.Schema;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptVoucherMap : EntityTypeConfiguration<vyuICGetInventoryReceiptVoucher>
    {
        public vyuICGetInventoryReceiptVoucherMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptItemId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryReceiptVoucher2");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.dtmReceiptDate).HasColumnName("dtmReceiptDate");
            this.Property(t => t.strVendor).HasColumnName("strVendor");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strReceiptNumber).HasColumnName("strReceiptNumber");
            this.Property(t => t.strBillOfLading).HasColumnName("strBillOfLading");
            this.Property(t => t.strReceiptType).HasColumnName("strReceiptType");
            this.Property(t => t.strOrderNumber).HasColumnName("strOrderNumber");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.dblUnitCost).HasColumnName("dblUnitCost");
            this.Property(t => t.dblReceiptQty).HasColumnName("dblReceiptQty");
            this.Property(t => t.dblVoucherQty).HasColumnName("dblVoucherQty");
            this.Property(t => t.dblReceiptLineTotal).HasColumnName("dblReceiptLineTotal");
            this.Property(t => t.dblVoucherLineTotal).HasColumnName("dblVoucherLineTotal");
            this.Property(t => t.dblReceiptTax).HasColumnName("dblReceiptTax");
            this.Property(t => t.dblVoucherTax).HasColumnName("dblVoucherTax");
            this.Property(t => t.dblOpenQty).HasColumnName("dblOpenQty");
            this.Property(t => t.dblItemsPayable).HasColumnName("dblItemsPayable");
            this.Property(t => t.dblTaxesPayable).HasColumnName("dblTaxesPayable");
            this.Property(t => t.dtmLastVoucherDate).HasColumnName("dtmLastVoucherDate");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.strAllVouchers).HasColumnName("strAllVouchers");
            this.Property(t => t.strFilterString).HasColumnName("strFilterString");
            this.Property(t => t.strContainerNumber).HasColumnName("strContainerNumber");
            this.Property(t => t.strItemUOM).HasColumnName("strItemUOM");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.ysnBundleItem).HasColumnName("ysnBundleItem");
            this.Property(t => t.intBundledItemId).HasColumnName("intBundledItemId");
            this.Property(t => t.strBundledItemNo).HasColumnName("strBundledItemNo");
        }
    }
}
