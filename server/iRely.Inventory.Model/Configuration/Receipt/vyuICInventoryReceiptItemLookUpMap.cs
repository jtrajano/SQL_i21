using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;
using System.ComponentModel.DataAnnotations.Schema;

namespace iRely.Inventory.Model
{
    public class vyuICInventoryReceiptItemLookUpMap : EntityTypeConfiguration<vyuICInventoryReceiptItemLookUp>
    {
        public vyuICInventoryReceiptItemLookUpMap()
        {
            // Primary Key
            this.HasKey(p => p.intInventoryReceiptItemId);

            // Table & Column Mappings
            this.ToTable("vyuICInventoryReceiptItemLookUp");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.strOrderNumber).HasColumnName("strOrderNumber");
            this.Property(t => t.dtmDate).HasColumnName("dtmDate");
            this.Property(t => t.dblOrdered).HasColumnName("dblOrdered").HasPrecision(38, 20);
            this.Property(t => t.dblReceived).HasColumnName("dblReceived").HasPrecision(19, 6);
            this.Property(t => t.strSourceNumber).HasColumnName("strSourceNumber");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strContainer).HasColumnName("strContainer");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.strOrderUOM).HasColumnName("strOrderUOM");
            this.Property(t => t.dblOrderUOMConvFactor).HasColumnName("dblOrderUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.intWeightUnitMeasureId).HasColumnName("intWeightUnitMeasureId");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.dblItemUOMConvFactor).HasColumnName("dblItemUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.dblWeightUOMConvFactor).HasColumnName("dblWeightUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
            this.Property(t => t.dblCostUOMConvFactor).HasColumnName("dblCostUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.dblGrossMargin).HasColumnName("dblGrossMargin").HasPrecision(38, 6);
            this.Property(t => t.strGrade).HasColumnName("strGrade");
            this.Property(t => t.intLifeTime).HasColumnName("intLifeTime");
            this.Property(t => t.strLifeTimeType).HasColumnName("strLifeTimeType");
            this.Property(t => t.ysnLoad).HasColumnName("ysnLoad");
            this.Property(t => t.dblAvailableQty).HasColumnName("dblAvailableQty").HasPrecision(19, 6);
            this.Property(t => t.strDiscountSchedule).HasColumnName("strDiscountSchedule");
            this.Property(t => t.dblFranchise).HasColumnName("dblFranchise").HasPrecision(19, 6);
            this.Property(t => t.dblContainerWeightPerQty).HasColumnName("dblContainerWeightPerQty").HasPrecision(19, 6);
            this.Property(t => t.strSubCurrency).HasColumnName("strSubCurrency");
            this.Property(t => t.strPricingType).HasColumnName("strPricingType");
            this.Property(t => t.strForexRateType).HasColumnName("strForexRateType");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intItemUOMDecimalPlaces).HasColumnName("intItemUOMDecimalPlaces");
            this.Property(t => t.intContainerWeightUOMId).HasColumnName("intContainerWeightUOMId");
            this.Property(t => t.dblContainerWeightUOMConvFactor).HasColumnName("dblContainerWeightUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.ysnLotWeightsRequired).HasColumnName("ysnLotWeightsRequired");
        }
    }    
}
