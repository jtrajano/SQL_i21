using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICInventoryShipmentMap : EntityTypeConfiguration<tblICInventoryShipment>
    {
        public tblICInventoryShipmentMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryShipment");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.strShipmentNumber).HasColumnName("strShipmentNumber");
            this.Property(t => t.dtmShipDate).HasColumnName("dtmShipDate");
            this.Property(t => t.intOrderType).HasColumnName("intOrderType");
            this.Property(t => t.intSourceType).HasColumnName("intSourceType");
            this.Property(t => t.strReferenceNumber).HasColumnName("strReferenceNumber");
            this.Property(t => t.dtmRequestedArrivalDate).HasColumnName("dtmRequestedArrivalDate");
            this.Property(t => t.intShipFromLocationId).HasColumnName("intShipFromLocationId");
            this.Property(t => t.intEntityCustomerId).HasColumnName("intEntityCustomerId");
            this.Property(t => t.intShipToLocationId).HasColumnName("intShipToLocationId");
            this.Property(t => t.intFreightTermId).HasColumnName("intFreightTermId");
            this.Property(t => t.strBOLNumber).HasColumnName("strBOLNumber");
            this.Property(t => t.intShipViaId).HasColumnName("intShipViaId");
            this.Property(t => t.strVessel).HasColumnName("strVessel");
            this.Property(t => t.strProNumber).HasColumnName("strProNumber");
            this.Property(t => t.strDriverId).HasColumnName("strDriverId");
            this.Property(t => t.strSealNumber).HasColumnName("strSealNumber");
            this.Property(t => t.strDeliveryInstruction).HasColumnName("strDeliveryInstruction");
            this.Property(t => t.dtmAppointmentTime).HasColumnName("dtmAppointmentTime");
            this.Property(t => t.dtmDepartureTime).HasColumnName("dtmDepartureTime");
            this.Property(t => t.dtmArrivalTime).HasColumnName("dtmArrivalTime");
            this.Property(t => t.dtmDeliveredDate).HasColumnName("dtmDeliveredDate");
            this.Property(t => t.strReceivedBy).HasColumnName("strReceivedBy");
            this.Property(t => t.strComment).HasColumnName("strComment");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.intCreatedUserId).HasColumnName("intCreatedUserId");
            this.Property(t => t.intShipToCompanyLocationId).HasColumnName("intShipToCompanyLocationId");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strFreeTime).HasColumnName("strFreeTime");

            this.HasMany(p => p.tblICInventoryShipmentItems)
                .WithRequired(p => p.tblICInventoryShipment)
                .HasForeignKey(p => p.intInventoryShipmentId);
            this.HasMany(p => p.tblICInventoryShipmentCharges)
                .WithRequired(p => p.tblICInventoryShipment)
                .HasForeignKey(p => p.intInventoryShipmentId);
            this.HasOptional(p => p.vyuICGetInventoryShipment)
                .WithRequired(p => p.tblICInventoryShipment);
                
        }
    }

    public class vyuICShipmentInvoiceMap: EntityTypeConfiguration<vyuICShipmentInvoice>
    {
        public vyuICShipmentInvoiceMap()
        {
            this.HasKey(t => t.intInventoryShipmentItemId);
            this.ToTable("vyuICShipmentInvoice2");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.intInventoryShipmentItemId).HasColumnName("intInventoryShipmentItemId");
            this.Property(t => t.intInventoryShipmentChargeId).HasColumnName("intInventoryShipmentChargeId");
            this.Property(t => t.strShipmentNumber).HasColumnName("strShipmentNumber");
            this.Property(t => t.dtmShipDate).HasColumnName("dtmShipDate");
            this.Property(t => t.strCustomer).HasColumnName("strCustomer");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strDestination).HasColumnName("strDestination");
            this.Property(t => t.strBOLNumber).HasColumnName("strBOLNumber");
            this.Property(t => t.strOrderType).HasColumnName("strOrderType");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.dblUnitCost).HasColumnName("dblUnitCost");
            this.Property(t => t.dblShipmentQty).HasColumnName("dblShipmentQty");
            this.Property(t => t.dblInTransitQty).HasColumnName("dblInTransitQty");
            this.Property(t => t.dblInvoiceQty).HasColumnName("dblInvoiceQty");
            this.Property(t => t.dblShipmentLineTotal).HasColumnName("dblShipmentLineTotal");
            this.Property(t => t.dblInTransitTotal).HasColumnName("dblInTransitTotal");
            this.Property(t => t.dblInvoiceLineTotal).HasColumnName("dblInvoiceLineTotal");
            this.Property(t => t.dblShipmentTax).HasColumnName("dblShipmentTax");
            this.Property(t => t.dblInvoiceTax).HasColumnName("dblInvoiceTax");
            this.Property(t => t.dblOpenQty).HasColumnName("dblOpenQty");
            this.Property(t => t.dblItemsReceivable).HasColumnName("dblItemsReceivable");
            this.Property(t => t.dblTaxesReceivable).HasColumnName("dblTaxesReceivable");
            this.Property(t => t.dtmLastInvoiceDate).HasColumnName("dtmLastInvoiceDate");
            this.Property(t => t.strAllVouchers).HasColumnName("strAllVouchers");
            this.Property(t => t.strFilterString).HasColumnName("strFilterString");
            this.Property(t => t.dtmCreated).HasColumnName("dtmCreated");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.strItemUOM).HasColumnName("strItemUOM");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");

        }
    }

    public class vyuICGetInventoryShipmentMap : EntityTypeConfiguration<vyuICGetInventoryShipment>
    {
        public vyuICGetInventoryShipmentMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryShipment");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.strShipmentNumber).HasColumnName("strShipmentNumber");
            this.Property(t => t.dtmShipDate).HasColumnName("dtmShipDate");
            this.Property(t => t.intOrderType).HasColumnName("intOrderType");
            this.Property(t => t.strOrderType).HasColumnName("strOrderType");
            this.Property(t => t.intSourceType).HasColumnName("intSourceType");
            this.Property(t => t.strSourceType).HasColumnName("strSourceType");
            this.Property(t => t.strReferenceNumber).HasColumnName("strReferenceNumber");
            this.Property(t => t.dtmRequestedArrivalDate).HasColumnName("dtmRequestedArrivalDate");
            this.Property(t => t.intShipFromLocationId).HasColumnName("intShipFromLocationId");
            this.Property(t => t.strShipFromLocation).HasColumnName("strShipFromLocation");
            this.Property(t => t.strShipFromAddress).HasColumnName("strShipFromAddress");
            this.Property(t => t.strShipFromStreet).HasColumnName("strShipFromStreet");
            this.Property(t => t.strShipFromCity).HasColumnName("strShipFromCity");
            this.Property(t => t.strShipFromState).HasColumnName("strShipFromState");
            this.Property(t => t.strShipFromZipPostalCode).HasColumnName("strShipFromZipPostalCode");
            this.Property(t => t.strShipFromCountry).HasColumnName("strShipFromCountry");
            this.Property(t => t.intEntityCustomerId).HasColumnName("intEntityCustomerId");
            this.Property(t => t.strCustomerNumber).HasColumnName("strCustomerNumber");
            this.Property(t => t.strCustomerName).HasColumnName("strCustomerName");
            this.Property(t => t.intShipToLocationId).HasColumnName("intShipToLocationId");
            this.Property(t => t.strShipToLocation).HasColumnName("strShipToLocation");
            this.Property(t => t.strShipToAddress).HasColumnName("strShipToAddress");
            this.Property(t => t.strShipToStreet).HasColumnName("strShipToStreet");
            this.Property(t => t.strShipToCity).HasColumnName("strShipToCity");
            this.Property(t => t.strShipToState).HasColumnName("strShipToState");
            this.Property(t => t.strShipToZipPostalCode).HasColumnName("strShipToZipPostalCode");
            this.Property(t => t.strShipToCountry).HasColumnName("strShipToCountry");
            this.Property(t => t.intFreightTermId).HasColumnName("intFreightTermId");
            this.Property(t => t.strFreightTerm).HasColumnName("strFreightTerm");
            this.Property(t => t.strFobPoint).HasColumnName("strFobPoint");
            this.Property(t => t.strBOLNumber).HasColumnName("strBOLNumber");
            this.Property(t => t.intShipViaId).HasColumnName("intShipViaId");
            this.Property(t => t.strShipVia).HasColumnName("strShipVia");
            this.Property(t => t.strVessel).HasColumnName("strVessel");
            this.Property(t => t.strProNumber).HasColumnName("strProNumber");
            this.Property(t => t.strDriverId).HasColumnName("strDriverId");
            this.Property(t => t.strSealNumber).HasColumnName("strSealNumber");
            this.Property(t => t.strDeliveryInstruction).HasColumnName("strDeliveryInstruction");
            this.Property(t => t.dtmAppointmentTime).HasColumnName("dtmAppointmentTime");
            this.Property(t => t.dtmDepartureTime).HasColumnName("dtmDepartureTime");
            this.Property(t => t.dtmArrivalTime).HasColumnName("dtmArrivalTime");
            this.Property(t => t.dtmDeliveredDate).HasColumnName("dtmDeliveredDate");
            this.Property(t => t.strReceivedBy).HasColumnName("strReceivedBy");
            this.Property(t => t.strComment).HasColumnName("strComment");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
        }
    }

    public class tblICInventoryShipmentItemMap : EntityTypeConfiguration<tblICInventoryShipmentItem>
    {
        public tblICInventoryShipmentItemMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentItemId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryShipmentItem");
            this.Property(t => t.intInventoryShipmentItemId).HasColumnName("intInventoryShipmentItemId");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.intOrderId).HasColumnName("intOrderId");
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.intLineNo).HasColumnName("intLineNo");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intOwnershipType).HasColumnName("intOwnershipType");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.dblUnitPrice).HasColumnName("dblUnitPrice").HasPrecision(38, 20);
            this.Property(t => t.intDockDoorId).HasColumnName("intDockDoorId");
            this.Property(t => t.strNotes).HasColumnName("strNotes");
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.intDiscountSchedule).HasColumnName("intDiscountSchedule");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intStorageScheduleTypeId).HasColumnName("intStorageScheduleTypeId");
            this.Property(t => t.intDestinationGradeId).HasColumnName("intDestinationGradeId");
            this.Property(t => t.intDestinationWeightId).HasColumnName("intDestinationWeightId");
            this.Property(t => t.intForexRateTypeId).HasColumnName("intForexRateTypeId");
            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate");

            this.HasMany(p => p.tblICInventoryShipmentItemLots)
                .WithRequired(p => p.tblICInventoryShipmentItem)
                .HasForeignKey(p => p.intInventoryShipmentItemId);

            this.HasOptional(p => p.vyuICGetInventoryShipmentItem)
                .WithRequired(p => p.tblICInventoryShipmentItem);
        }
    }

    public class tblICInventoryShipmentChargeMap : EntityTypeConfiguration<tblICInventoryShipmentCharge>
    {
        public tblICInventoryShipmentChargeMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentChargeId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryShipmentCharge");
            this.Property(t => t.intInventoryShipmentChargeId).HasColumnName("intInventoryShipmentChargeId");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.intContractId).HasColumnName("intContractId");
            this.Property(t => t.intChargeId).HasColumnName("intChargeId");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.strAllocatePriceBy).HasColumnName("strAllocatePriceBy");
            this.Property(t => t.ysnAccrue).HasColumnName("ysnAccrue");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intForexRateTypeId).HasColumnName("intForexRateTypeId");
            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate");

            this.HasOptional(p => p.vyuICGetInventoryShipmentCharge)
                .WithRequired(p => p.tblICInventoryShipmentCharge);
        }
    }

    public class vyuICGetInventoryShipmentChargeMap : EntityTypeConfiguration<vyuICGetInventoryShipmentCharge>
    {
        public vyuICGetInventoryShipmentChargeMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentChargeId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryShipmentCharge");
            this.Property(t => t.intInventoryShipmentChargeId).HasColumnName("intInventoryShipmentChargeId");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.intContractId).HasColumnName("intContractId");
            this.Property(t => t.strContractNumber).HasColumnName("strContractNumber");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.intOnCostTypeId).HasColumnName("intOnCostTypeId");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.strOnCostType).HasColumnName("strOnCostType");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.strAllocatePriceBy).HasColumnName("strAllocatePriceBy");
            this.Property(t => t.ysnAccrue).HasColumnName("ysnAccrue");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.strVendorName).HasColumnName("strVendorName");
            this.Property(t => t.strForexRateType).HasColumnName("strForexRateType");
        }
    }

    public class tblICInventoryShipmentItemLotMap : EntityTypeConfiguration<tblICInventoryShipmentItemLot>
    {
        public tblICInventoryShipmentItemLotMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentItemLotId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryShipmentItemLot");
            this.Property(t => t.intInventoryShipmentItemLotId).HasColumnName("intInventoryShipmentItemLotId");
            this.Property(t => t.intInventoryShipmentItemId).HasColumnName("intInventoryShipmentItemId");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.dblQuantityShipped).HasColumnName("dblQuantityShipped").HasPrecision(38, 20);
            this.Property(t => t.dblGrossWeight).HasColumnName("dblGrossWeight").HasPrecision(38, 20);
            this.Property(t => t.dblTareWeight).HasColumnName("dblTareWeight").HasPrecision(38, 20);
            this.Property(t => t.dblWeightPerQty).HasColumnName("dblWeightPerQty").HasPrecision(38, 20);
            this.Property(t => t.strWarehouseCargoNumber).HasColumnName("strWarehouseCargoNumber");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICLot)
                .WithMany(p => p.tblICInventoryShipmentItemLots)
                .HasForeignKey(p => p.intLotId);
        }
    }

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
            this.Property(t => t.intDiscountSchedule).HasColumnName("intDiscountSchedule");
            this.Property(t => t.strStorageTypeDescription).HasColumnName("strStorageTypeDescription");
            this.Property(t => t.strForexRateType).HasColumnName("strForexRateType");
        }
    }

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
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
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
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.dblLotQty).HasColumnName("dblLotQty").HasPrecision(38, 20);
            this.Property(t => t.strLotUOM).HasColumnName("strLotUOM");
            this.Property(t => t.dblGrossWeight).HasColumnName("dblGrossWeight").HasPrecision(38, 20);
            this.Property(t => t.dblTareWeight).HasColumnName("dblTareWeight").HasPrecision(38, 20);
            this.Property(t => t.dblNetWeight).HasColumnName("dblNetWeight").HasPrecision(38, 20);
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
        }
    }

    public class vyuICGetShipmentAddOrderMap : EntityTypeConfiguration<vyuICGetShipmentAddOrder>
    {
        public vyuICGetShipmentAddOrderMap()
        {
            // Primary Key
            this.HasKey(p => p.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetShipmentAddOrder");
            this.Property(t => t.intKey).HasColumnName("intKey");
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
        }
    }

    public class vyuICGetShipmentAddSalesOrderMap : EntityTypeConfiguration<vyuICGetShipmentAddSalesOrder>
    {
        public vyuICGetShipmentAddSalesOrderMap()
        {
            // Primary Key
            this.HasKey(p => p.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetShipmentAddSalesOrder");
            this.Property(t => t.intKey).HasColumnName("intKey");
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
            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate");
        }
    }

    public class vyuICGetShipmentAddSalesContractMap : EntityTypeConfiguration<vyuICGetShipmentAddSalesContract>
    {
        public vyuICGetShipmentAddSalesContractMap()
        {
            // Primary Key
            this.HasKey(p => p.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetShipmentAddSalesContract");
            this.Property(t => t.intKey).HasColumnName("intKey");
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
            this.Property(t => t.strDestinationWeights).HasColumnName("strDestinationWeights");
            this.Property(t => t.strDestinationGrades).HasColumnName("strDestinationGrades");
            this.Property(t => t.intDestinationGradeId).HasColumnName("intDestinationGradeId");
            this.Property(t => t.intDestinationWeightId).HasColumnName("intDestinationWeightId");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.intForexRateTypeId).HasColumnName("intForexRateTypeId");
            this.Property(t => t.strForexRateType).HasColumnName("strForexRateType");
            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate");
        }
    }

    public class vyuICGetShipmentAddSalesContractPickLotMap : EntityTypeConfiguration<vyuICGetShipmentAddSalesContractPickLot>
    {
        public vyuICGetShipmentAddSalesContractPickLotMap()
        {
            // Primary Key
            this.HasKey(p => p.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetShipmentAddSalesContractPickLot");
            this.Property(t => t.intKey).HasColumnName("intKey");
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
            this.Property(t => t.intForexRateTypeId).HasColumnName("intForexRateTypeId");
            this.Property(t => t.strForexRateType).HasColumnName("strForexRateType");
            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate");
        }
    }
}
