using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryShipmentItemLotMap : EntityTypeConfiguration<vyuICGetInventoryShipmentItemLot>
    {
        public vyuICGetInventoryShipmentItemLotMap()
        {
            // Primary Key
            this.HasKey(p => p.intInventoryShipmentItemLotId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryShipmentItemLot");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.intInventoryShipmentItemId).HasColumnName("intInventoryShipmentItemId");
            this.Property(t => t.intInventoryShipmentItemLotId).HasColumnName("intInventoryShipmentItemLotId");
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
            this.Property(t => t.strOrderUOM).HasColumnName("strOrderUOM");
            this.Property(t => t.strItemUOM).HasColumnName("strItemUOM");
            this.Property(t => t.dblItemUOMConv).HasColumnName("dblItemUOMConv").HasPrecision(38, 20);
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.dblWeightItemUOMConv).HasColumnName("dblWeightItemUOMConv").HasPrecision(38, 20);
            this.Property(t => t.dblQtyOrdered).HasColumnName("dblQtyOrdered").HasPrecision(18, 6);
            this.Property(t => t.dblQtyAllocated).HasColumnName("dblQtyAllocated").HasPrecision(18, 6);
            this.Property(t => t.dblUnitPrice).HasColumnName("dblUnitPrice").HasPrecision(18, 6);
            this.Property(t => t.dblDiscount).HasColumnName("dblDiscount").HasPrecision(18, 6);
            this.Property(t => t.dblTotal).HasColumnName("dblTotal").HasPrecision(18, 6);
            this.Property(t => t.dblQtyToShip).HasColumnName("dblQtyToShip").HasPrecision(38, 20);
            this.Property(t => t.dblPrice).HasColumnName("dblPrice").HasPrecision(18, 6);
            this.Property(t => t.dblLineTotal).HasColumnName("dblLineTotal").HasPrecision(18, 6);
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.strGrade).HasColumnName("strGrade");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.strLotAlias).HasColumnName("strLotAlias");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocation).HasColumnName("strStorageLocation");
            this.Property(t => t.dblQuantityShipped).HasColumnName("dblQuantityShipped").HasPrecision(38, 20);
            this.Property(t => t.strLotUOM).HasColumnName("strLotUOM");
            this.Property(t => t.dblGrossWeight).HasColumnName("dblGrossWeight").HasPrecision(38, 20);
            this.Property(t => t.dblTareWeight).HasColumnName("dblTareWeight").HasPrecision(38, 20);
            this.Property(t => t.dblNetWeight).HasColumnName("dblNetWeight").HasPrecision(38, 20);
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.dblAvailableQty).HasColumnName("dblAvailableQty").HasPrecision(38, 20);
            this.Property(t => t.strWarehouseCargoNumber).HasColumnName("strWarehouseCargoNumber");
        }
    }
}
