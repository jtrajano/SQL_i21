using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryShipmentItemMap : EntityTypeConfiguration<vyuICGetInventoryShipmentItem>
    {
        public vyuICGetInventoryShipmentItemMap()
        {
            // Primary Key
            this.HasKey(p => p.intInventoryShipmentItemId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryShipmentItem");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.intInventoryShipmentItemId).HasColumnName("intInventoryShipmentItemId");
            this.Property(t => t.strOrderType).HasColumnName("strOrderType");
            this.Property(t => t.strSourceType).HasColumnName("strSourceType");
            this.Property(t => t.strShipmentNumber).HasColumnName("strShipmentNumber");
            this.Property(t => t.strShipFromLocation).HasColumnName("strShipFromLocation");
            this.Property(t => t.strShipToLocation).HasColumnName("strShipToLocation");
            this.Property(t => t.strBOLNumber).HasColumnName("strBOLNumber");
            this.Property(t => t.dtmShipDate).HasColumnName("dtmShipDate");
            this.Property(t => t.strCustomerNumber).HasColumnName("strCustomerNumber");
            this.Property(t => t.strCustomerName).HasColumnName("strCustomerName");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intLineNo).HasColumnName("intLineNo");
            this.Property(t => t.intOrderId).HasColumnName("intOrderId");
            this.Property(t => t.strOrderNumber).HasColumnName("strOrderNumber");
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.strSourceNumber).HasColumnName("strSourceNumber");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.strOrderUOM).HasColumnName("strOrderUOM");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.intDecimalPlaces).HasColumnName("intDecimalPlaces");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.dblItemUOMConv).HasColumnName("dblItemUOMConv").HasPrecision(38, 20);
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.dblWeightItemUOMConv).HasColumnName("dblWeightItemUOMConv").HasPrecision(38, 20);
            this.Property(t => t.dblUnitCost).HasColumnName("dblUnitCost").HasPrecision(38, 20);
            this.Property(t => t.dblQtyOrdered).HasColumnName("dblQtyOrdered").HasPrecision(18, 6);
            this.Property(t => t.dblQtyAllocated).HasColumnName("dblQtyAllocated").HasPrecision(18, 6);
            this.Property(t => t.dblUnitPrice).HasColumnName("dblUnitPrice").HasPrecision(18, 6);
            this.Property(t => t.dblDiscount).HasColumnName("dblDiscount").HasPrecision(18, 6);
            this.Property(t => t.dblTotal).HasColumnName("dblTotal").HasPrecision(18, 6);
            this.Property(t => t.dblQtyToShip).HasColumnName("dblQtyToShip").HasPrecision(38, 20);
            this.Property(t => t.dblPrice).HasColumnName("dblPrice").HasPrecision(18, 6);
            this.Property(t => t.dblLineTotal).HasColumnName("dblLineTotal").HasPrecision(37, 12);
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.strGrade).HasColumnName("strGrade");
            this.Property(t => t.strDestinationWeights).HasColumnName("strDestinationWeights");
            this.Property(t => t.strDestinationGrades).HasColumnName("strDestinationGrades");
            this.Property(t => t.intDestinationGradeId).HasColumnName("intDestinationGradeId");
            this.Property(t => t.intDestinationWeightId).HasColumnName("intDestinationWeightId");
            // this.Property(t => t.dblDestinationGrossQty).HasColumnName("dblDestinationGrossQty");
            // this.Property(t => t.dblDestinationNetQty).HasColumnName("dblDestinationNetQty");
            // this.Property(t => t.strDestinationQtyUOM).HasColumnName("strDestinationQtyUOM");
            // this.Property(t => t.intDestinationQtyUOMId).HasColumnName("intDestinationQtyUOMId");
            this.Property(t => t.intDiscountSchedule).HasColumnName("intDiscountSchedule");
            this.Property(t => t.strStorageTypeDescription).HasColumnName("strStorageTypeDescription");
            this.Property(t => t.strForexRateType).HasColumnName("strForexRateType");
            this.Property(t => t.strDockDoor).HasColumnName("strDockDoor");
            this.Property(t => t.dblDestinationQuantity).HasColumnName("dblDestinationQuantity").HasPrecision(38, 20);
            Property(t => t.intContractSeq).HasColumnName("intContractSeq");
        }
    }
}
