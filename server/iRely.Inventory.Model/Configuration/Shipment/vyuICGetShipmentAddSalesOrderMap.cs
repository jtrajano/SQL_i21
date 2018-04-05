using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetShipmentAddSalesOrderMap : EntityTypeConfiguration<vyuICGetShipmentAddSalesOrder>
    {
        public vyuICGetShipmentAddSalesOrderMap()
        {
            // Primary Key
            this.HasKey(p => p.intLineNo);

            // Table & Column Mappings
            this.ToTable("vyuICGetShipmentAddSalesOrder");
            //this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.strOrderType).HasColumnName("strOrderType");
            this.Property(t => t.strSourceType).HasColumnName("strSourceType");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strShipFromLocation).HasColumnName("strShipFromLocation");
            this.Property(t => t.intEntityCustomerId).HasColumnName("intEntityCustomerId");
            this.Property(t => t.strCustomerNumber).HasColumnName("strCustomerNumber");
            this.Property(t => t.strCustomerName).HasColumnName("strCustomerName");
            this.Property(t => t.intLineNo).HasColumnName("intLineNo");
            this.Property(t => t.intOrderId).HasColumnName("intOrderId");
            this.Property(t => t.strOrderNumber).HasColumnName("strOrderNumber");
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.strSourceNumber).HasColumnName("strSourceNumber");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intOrderUOMId).HasColumnName("intOrderUOMId");
            this.Property(t => t.strOrderUOM).HasColumnName("strOrderUOM");
            this.Property(t => t.dblOrderUOMConvFactor).HasColumnName("dblOrderUOMConvFactor").HasPrecision(18, 6);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strItemUOM).HasColumnName("strItemUOM");
            this.Property(t => t.dblItemUOMConv).HasColumnName("dblItemUOMConv").HasPrecision(18, 6);
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.dblWeightItemUOMConv).HasColumnName("dblWeightItemUOMConv").HasPrecision(18, 6);
            this.Property(t => t.dblQtyOrdered).HasColumnName("dblQtyOrdered").HasPrecision(18, 6);
            this.Property(t => t.dblQtyAllocated).HasColumnName("dblQtyAllocated").HasPrecision(18, 6);
            this.Property(t => t.dblQtyShipped).HasColumnName("dblQtyShipped").HasPrecision(18, 6);
            this.Property(t => t.dblUnitPrice).HasColumnName("dblUnitPrice").HasPrecision(18, 6);
            this.Property(t => t.dblDiscount).HasColumnName("dblDiscount").HasPrecision(18, 6);
            this.Property(t => t.dblTotal).HasColumnName("dblTotal").HasPrecision(18, 6);
            this.Property(t => t.dblQtyToShip).HasColumnName("dblQtyToShip").HasPrecision(18, 6);
            this.Property(t => t.dblPrice).HasColumnName("dblPrice").HasPrecision(18, 6);
            this.Property(t => t.dblLineTotal).HasColumnName("dblLineTotal").HasPrecision(18, 6);
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.strGrade).HasColumnName("strGrade");
            this.Property(t => t.strDestinationWeights).HasColumnName("strDestinationWeights");
            this.Property(t => t.strDestinationGrades).HasColumnName("strDestinationGrades");
            this.Property(t => t.intDestinationGradeId).HasColumnName("intDestinationGradeId");
            this.Property(t => t.intDestinationWeightId).HasColumnName("intDestinationWeightId");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.intFreightTermId).HasColumnName("intFreightTermId");
            this.Property(t => t.intShipToLocationId).HasColumnName("intShipToLocationId");
            this.Property(t => t.intForexRateTypeId).HasColumnName("intForexRateTypeId");
            this.Property(t => t.strForexRateType).HasColumnName("strForexRateType");
            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate").HasPrecision(18, 6);
            this.Property(t => t.intPriceUOMId).HasColumnName("intPriceUOMId");
            this.Property(t => t.strPriceUOM).HasColumnName("strPriceUOM");

        }
    }
}
