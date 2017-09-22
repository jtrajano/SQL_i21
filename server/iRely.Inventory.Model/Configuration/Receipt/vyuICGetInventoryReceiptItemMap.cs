using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptItemMap : EntityTypeConfiguration<vyuICGetInventoryReceiptItem>
    {
        public vyuICGetInventoryReceiptItemMap()
        {
            // Primary Key
            this.HasKey(p => p.intInventoryReceiptItemId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryReceiptItem");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.strReceiptNumber).HasColumnName("strReceiptNumber");
            this.Property(t => t.strReceiptType).HasColumnName("strReceiptType");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strSourceType).HasColumnName("strSourceType");
            this.Property(t => t.dtmReceiptDate).HasColumnName("dtmReceiptDate");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.strVendorName).HasColumnName("strVendorName");
            this.Property(t => t.strBillOfLading).HasColumnName("strBillOfLading");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intLineNo).HasColumnName("intLineNo");
            this.Property(t => t.intOrderId).HasColumnName("intOrderId");
            this.Property(t => t.strOrderNumber).HasColumnName("strOrderNumber");
            this.Property(t => t.dtmDate).HasColumnName("dtmDate");
            this.Property(t => t.dblOrdered).HasColumnName("dblOrdered").HasPrecision(38, 20);
            this.Property(t => t.dblReceived).HasColumnName("dblReceived").HasPrecision(19, 6);
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.strSourceNumber).HasColumnName("strSourceNumber");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.dblQtyToReceive).HasColumnName("dblQtyToReceive").HasPrecision(38, 20);
            this.Property(t => t.intLoadToReceive).HasColumnName("intLoadToReceive");
            this.Property(t => t.dblUnitCost).HasColumnName("dblUnitCost").HasPrecision(38, 20);
            this.Property(t => t.dblTax).HasColumnName("dblTax").HasPrecision(18, 6);
            this.Property(t => t.dblLineTotal).HasColumnName("dblLineTotal").HasPrecision(18, 6);
            this.Property(t => t.dblGrossWgt).HasColumnName("dblGrossWgt").HasPrecision(38, 20);
            this.Property(t => t.dblNetWgt).HasColumnName("dblNetWgt").HasPrecision(38, 20);
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intContainerId).HasColumnName("intContainerId");
            this.Property(t => t.strContainer).HasColumnName("strContainer");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.strOrderUOM).HasColumnName("strOrderUOM");
            this.Property(t => t.dblOrderUOMConvFactor).HasColumnName("dblOrderUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.dblItemUOMConvFactor).HasColumnName("dblItemUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.dblWeightUOMConvFactor).HasColumnName("dblWeightUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
            this.Property(t => t.dblCostUOMConvFactor).HasColumnName("dblCostUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.dblGrossMargin).HasColumnName("dblGrossMargin").HasPrecision(38, 6);
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.dblBillQty).HasColumnName("dblBillQty").HasPrecision(18, 6);
            this.Property(t => t.strGrade).HasColumnName("strGrade");
            this.Property(t => t.intLifeTime).HasColumnName("intLifeTime");
            this.Property(t => t.strLifeTimeType).HasColumnName("strLifeTimeType");
            this.Property(t => t.ysnLoad).HasColumnName("ysnLoad");
            this.Property(t => t.dblAvailableQty).HasColumnName("dblAvailableQty").HasPrecision(19, 6);
            this.Property(t => t.intDiscountSchedule).HasColumnName("intDiscountSchedule");
            this.Property(t => t.strDiscountSchedule).HasColumnName("strDiscountSchedule");
            this.Property(t => t.ysnExported).HasColumnName("ysnExported");
            this.Property(t => t.dtmExportedDate).HasColumnName("dtmExportedDate");
            this.Property(t => t.dblFranchise).HasColumnName("dblFranchise").HasPrecision(19, 6);
            this.Property(t => t.dblContainerWeightPerQty).HasColumnName("dblContainerWeightPerQty").HasPrecision(19, 6);
            this.Property(t => t.ysnSubCurrency).HasColumnName("ysnSubCurrency");
            this.Property(t => t.strSubCurrency).HasColumnName("strSubCurrency");
            this.Property(t => t.strVendorRefNo).HasColumnName("strVendorRefNo");
            this.Property(t => t.strShipFrom).HasColumnName("strShipFrom");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.ysnLotWeightsRequired).HasColumnName("ysnLotWeightsRequired");
        }
    }
}