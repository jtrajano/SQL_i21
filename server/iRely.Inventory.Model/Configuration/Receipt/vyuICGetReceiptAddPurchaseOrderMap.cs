using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;
using System.ComponentModel.DataAnnotations.Schema;

namespace iRely.Inventory.Model
{
    public class vyuICGetReceiptAddPurchaseOrderMap : EntityTypeConfiguration<vyuICGetReceiptAddPurchaseOrder>
    {
        public vyuICGetReceiptAddPurchaseOrderMap()
        {
            // Primary Key
            this.HasKey(t => t.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetReceiptAddPurchaseOrder");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.strVendorName).HasColumnName("strVendorName");
            this.Property(t => t.strReceiptType).HasColumnName("strReceiptType");
            this.Property(t => t.intLineNo).HasColumnName("intLineNo");
            this.Property(t => t.intOrderId).HasColumnName("intOrderId");
            this.Property(t => t.strOrderNumber).HasColumnName("strOrderNumber");
            this.Property(t => t.dblOrdered).HasColumnName("dblOrdered").HasPrecision(18, 6);
            this.Property(t => t.dblReceived).HasColumnName("dblReceived").HasPrecision(18, 6);
            this.Property(t => t.intSourceType).HasColumnName("intSourceType");
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
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intContainerId).HasColumnName("intContainerId");
            this.Property(t => t.strContainer).HasColumnName("strContainer");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intOrderUOMId).HasColumnName("intOrderUOMId");
            this.Property(t => t.strOrderUOM).HasColumnName("strOrderUOM");
            this.Property(t => t.dblOrderUOMConvFactor).HasColumnName("dblOrderUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.dblItemUOMConvFactor).HasColumnName("dblItemUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.dblWeightUOMConvFactor).HasColumnName("dblWeightUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
            this.Property(t => t.dblCostUOMConvFactor).HasColumnName("dblCostUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.intLifeTime).HasColumnName("intLifeTime");
            this.Property(t => t.strLifeTimeType).HasColumnName("strLifeTimeType");
            this.Property(t => t.ysnLoad).HasColumnName("ysnLoad");
            this.Property(t => t.dblAvailableQty).HasColumnName("dblAvailableQty");
            this.Property(t => t.strBOL).HasColumnName("strBOL");
            this.Property(t => t.dblFranchise).HasColumnName("dblFranchise").HasPrecision(19, 6);
            this.Property(t => t.dblContainerWeightPerQty).HasColumnName("dblContainerWeightPerQty").HasPrecision(19, 6);
            this.Property(t => t.ysnSubCurrency).HasColumnName("ysnSubCurrency");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strSubCurrency).HasColumnName("strSubCurrency");
            this.Property(t => t.dblGross).HasColumnName("dblGross").HasPrecision(38, 20);
            this.Property(t => t.dblNet).HasColumnName("dblNet").HasPrecision(38, 20);
            this.Property(t => t.intForexRateTypeId).HasColumnName("intForexRateTypeId");
            this.Property(t => t.strForexRateType).HasColumnName("strForexRateType");
            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate").HasPrecision(18, 6);
            this.Property(t => t.ysnBundleItem).HasColumnName("ysnBundleItem");
            this.Property(t => t.intBundledItemId).HasColumnName("intBundledItemId");
            this.Property(t => t.strBundledItemNo).HasColumnName("strBundledItemNo");
            this.Property(t => t.strBundledItemDescription).HasColumnName("strBundledItemDescription");
            this.Property(t => t.ysnIsBasket).HasColumnName("ysnIsBasket");
            this.Property(t => t.intFreightTermId).HasColumnName("intFreightTermId");
            this.Property(t => t.strFreightTerm).HasColumnName("strFreightTerm");
            this.Property(t => t.strBundleType).HasColumnName("strBundleType");
        }
    }
}
