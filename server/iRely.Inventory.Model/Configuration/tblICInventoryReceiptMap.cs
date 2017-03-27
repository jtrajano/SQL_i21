using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICInventoryReceiptMap : EntityTypeConfiguration<tblICInventoryReceipt>
    {
        public tblICInventoryReceiptMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryReceipt");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.strReceiptType).HasColumnName("strReceiptType");
            this.Property(t => t.intSourceType).HasColumnName("intSourceType");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.intTransferorId).HasColumnName("intTransferorId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strReceiptNumber).HasColumnName("strReceiptNumber");
            this.Property(t => t.dtmReceiptDate).HasColumnName("dtmReceiptDate");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.intSubCurrencyCents).HasColumnName("intSubCurrencyCents");
            this.Property(t => t.intBlanketRelease).HasColumnName("intBlanketRelease");
            this.Property(t => t.strVendorRefNo).HasColumnName("strVendorRefNo");
            this.Property(t => t.strBillOfLading).HasColumnName("strBillOfLading");
            this.Property(t => t.intShipViaId).HasColumnName("intShipViaId");
            this.Property(t => t.intShipFromId).HasColumnName("intShipFromId");
            this.Property(t => t.intReceiverId).HasColumnName("intReceiverId");
            this.Property(t => t.strVessel).HasColumnName("strVessel");
            this.Property(t => t.intFreightTermId).HasColumnName("intFreightTermId");
            this.Property(t => t.intShiftNumber).HasColumnName("intShiftNumber");
            this.Property(t => t.dblInvoiceAmount).HasColumnName("dblInvoiceAmount").HasPrecision(18, 6);
            this.Property(t => t.ysnPrepaid).HasColumnName("ysnPrepaid");
            this.Property(t => t.ysnInvoicePaid).HasColumnName("ysnInvoicePaid");
            this.Property(t => t.intCheckNo).HasColumnName("intCheckNo");
            this.Property(t => t.dtmCheckDate).HasColumnName("dtmCheckDate");
            this.Property(t => t.intTrailerTypeId).HasColumnName("intTrailerTypeId");
            this.Property(t => t.dtmTrailerArrivalDate).HasColumnName("dtmTrailerArrivalDate");
            this.Property(t => t.dtmTrailerArrivalTime).HasColumnName("dtmTrailerArrivalTime");
            this.Property(t => t.strSealNo).HasColumnName("strSealNo");
            this.Property(t => t.strSealStatus).HasColumnName("strSealStatus");
            this.Property(t => t.dtmReceiveTime).HasColumnName("dtmReceiveTime");
            this.Property(t => t.dblActualTempReading).HasColumnName("dblActualTempReading").HasPrecision(18, 6);
            this.Property(t => t.intShipmentId).HasColumnName("intShipmentId");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intCreatedUserId).HasColumnName("intCreatedUserId");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.ysnOrigin).HasColumnName("ysnOrigin");
            this.Property(t => t.strWarehouseRefNo).HasColumnName("strWarehouseRefNo");

            this.HasOptional(p => p.vyuICInventoryReceiptLookUp)
                .WithRequired(p => p.tblICInventoryReceipt);
            this.HasMany(p => p.tblICInventoryReceiptItems)
                .WithRequired(p => p.tblICInventoryReceipt)
                .HasForeignKey(p => p.intInventoryReceiptId);
            this.HasMany(p => p.tblICInventoryReceiptCharges)
                .WithRequired(p => p.tblICInventoryReceipt)
                .HasForeignKey(p => p.intInventoryReceiptId);
                
        }
    }

    public class vyuICGetInventoryReceiptMap : EntityTypeConfiguration<vyuICGetInventoryReceipt>
    {
        public vyuICGetInventoryReceiptMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryReceipt");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.strReceiptType).HasColumnName("strReceiptType");
            this.Property(t => t.intSourceType).HasColumnName("intSourceType");
            this.Property(t => t.strSourceType).HasColumnName("strSourceType");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.strVendorName).HasColumnName("strVendorName");
            this.Property(t => t.intTransferorId).HasColumnName("intTransferorId");
            this.Property(t => t.strTransferor).HasColumnName("strTransferor");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strReceiptNumber).HasColumnName("strReceiptNumber");
            this.Property(t => t.dtmReceiptDate).HasColumnName("dtmReceiptDate");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.intSubCurrencyCents).HasColumnName("intSubCurrencyCents");
            this.Property(t => t.intBlanketRelease).HasColumnName("intBlanketRelease");
            this.Property(t => t.strVendorRefNo).HasColumnName("strVendorRefNo");
            this.Property(t => t.strBillOfLading).HasColumnName("strBillOfLading");
            this.Property(t => t.intShipViaId).HasColumnName("intShipViaId");
            this.Property(t => t.strShipVia).HasColumnName("strShipVia");
            this.Property(t => t.intShipFromId).HasColumnName("intShipFromId");
            this.Property(t => t.strShipFrom).HasColumnName("strShipFrom");
            this.Property(t => t.intReceiverId).HasColumnName("intReceiverId");
            this.Property(t => t.strReceiver).HasColumnName("strReceiver");
            this.Property(t => t.strVessel).HasColumnName("strVessel");
            this.Property(t => t.intFreightTermId).HasColumnName("intFreightTermId");
            this.Property(t => t.strFreightTerm).HasColumnName("strFreightTerm");
            this.Property(t => t.strFobPoint).HasColumnName("strFobPoint");
            this.Property(t => t.intShiftNumber).HasColumnName("intShiftNumber");
            this.Property(t => t.dblInvoiceAmount).HasColumnName("dblInvoiceAmount").HasPrecision(18, 6);
            this.Property(t => t.ysnPrepaid).HasColumnName("ysnPrepaid");
            this.Property(t => t.ysnInvoicePaid).HasColumnName("ysnInvoicePaid");
            this.Property(t => t.intCheckNo).HasColumnName("intCheckNo");
            this.Property(t => t.dtmCheckDate).HasColumnName("dtmCheckDate");
            this.Property(t => t.intTrailerTypeId).HasColumnName("intTrailerTypeId");
            this.Property(t => t.dtmTrailerArrivalDate).HasColumnName("dtmTrailerArrivalDate");
            this.Property(t => t.dtmTrailerArrivalTime).HasColumnName("dtmTrailerArrivalTime");
            this.Property(t => t.strSealNo).HasColumnName("strSealNo");
            this.Property(t => t.strSealStatus).HasColumnName("strSealStatus");
            this.Property(t => t.dtmReceiveTime).HasColumnName("dtmReceiveTime");
            this.Property(t => t.dblActualTempReading).HasColumnName("dblActualTempReading").HasPrecision(18, 6);
            this.Property(t => t.intShipmentId).HasColumnName("intShipmentId");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.strTaxGroup).HasColumnName("strTaxGroup");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.strEntityName).HasColumnName("strEntityName");
            this.Property(t => t.strActualCostId).HasColumnName("strActualCostId");
            this.Property(t => t.strWarehouseRefNo).HasColumnName("strWarehouseRefNo");
            this.Property(t => t.dblSubTotal).HasColumnName("dblSubTotal");
            this.Property(t => t.dblTotalTax).HasColumnName("dblTotalTax");
            this.Property(t => t.dblTotalCharges).HasColumnName("dblTotalCharges");
            this.Property(t => t.dblTotalGross).HasColumnName("dblTotalGross");
            this.Property(t => t.dblTotalNet).HasColumnName("dblTotalNet");
            this.Property(t => t.dblGrandTotal).HasColumnName("dblGrandTotal");
        }
    }

    public class vyuICInventoryReceiptLookUpMap : EntityTypeConfiguration<vyuICInventoryReceiptLookUp>
    {
        public vyuICInventoryReceiptLookUpMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptId);

            // Table & Column Mappings
            this.ToTable("vyuICInventoryReceiptLookUp");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.strVendorName).HasColumnName("strVendorName");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strFobPoint).HasColumnName("strFobPoint");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
        }
    }

    public class vyuICGetInventoryReceiptItemLot2Map : EntityTypeConfiguration<vyuICGetInventoryReceiptItemLot2>
    {
        public vyuICGetInventoryReceiptItemLot2Map()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptItemLotId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryReceiptItemLot2");
            this.Property(t => t.intInventoryReceiptItemLotId).HasColumnName("intInventoryReceiptItemLotId");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.strLotAlias).HasColumnName("strLotAlias");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.dblGrossWeight).HasColumnName("dblGrossWeight");
            this.Property(t => t.dblTareWeight).HasColumnName("dblTareWeight");
            this.Property(t => t.dblCost).HasColumnName("dblCost");
            this.Property(t => t.intNoPallet).HasColumnName("intNoPallet");
            this.Property(t => t.intUnitPallet).HasColumnName("intUnitPallet");
            this.Property(t => t.dblStatedGrossPerUnit).HasColumnName("dblStatedGrossPerUnit");
            this.Property(t => t.dblStatedTarePerUnit).HasColumnName("dblStatedTarePerUnit");
            this.Property(t => t.strContainerNo).HasColumnName("strContainerNo");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.strGarden).HasColumnName("strGarden");
            this.Property(t => t.strMarkings).HasColumnName("strMarkings");
            this.Property(t => t.intOriginId).HasColumnName("intOriginId");
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.intSeasonCropYear).HasColumnName("intSeasonCropYear");
            this.Property(t => t.strVendorLotId).HasColumnName("strVendorLotId");
            this.Property(t => t.dtmManufacturedDate).HasColumnName("dtmManufacturedDate");
            this.Property(t => t.strRemarks).HasColumnName("strRemarks");
            this.Property(t => t.strCondition).HasColumnName("strCondition");
            this.Property(t => t.dtmCertified).HasColumnName("dtmCertified");
            this.Property(t => t.dtmExpiryDate).HasColumnName("dtmExpiryDate");
            this.Property(t => t.intParentLotId).HasColumnName("intParentLotId");
            this.Property(t => t.strParentLotNumber).HasColumnName("strParentLotNumber");
            this.Property(t => t.strParentLotAlias).HasColumnName("strParentLotAlias");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.dblNetWeight).HasColumnName("dblNetWeight");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty");
            this.Property(t => t.strItemUOM).HasColumnName("strItemUOM");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.dblLotUOMConvFactor).HasColumnName("dblLotUOMConvFactor");
            this.Property(t => t.strStorageLocation).HasColumnName("strStorageLocation");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.strGrade).HasColumnName("strGrade");
            this.Property(t => t.strOrigin).HasColumnName("strOrigin");
            this.Property(t => t.dblStatedNetPerUnit).HasColumnName("dblStatedNetPerUnit").HasPrecision(38, 20);
            this.Property(t => t.dblStatedTotalNet).HasColumnName("dblStatedTotalNet").HasPrecision(38, 20);
            this.Property(t => t.dblPhysicalVsStated).HasColumnName("dblPhysicalVsStated").HasPrecision(38, 20);
        }
    }

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
            this.Property(t => t.dblOrderQty).HasColumnName("dblOrderQty").HasPrecision(18, 6);
            this.Property(t => t.dblBillQty).HasColumnName("dblBillQty").HasPrecision(18, 6);
            this.Property(t => t.dblOpenReceive).HasColumnName("dblOpenReceive").HasPrecision(38, 20);
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.dblUnitCost).HasColumnName("dblUnitCost").HasPrecision(38, 20);
            this.Property(t => t.dblUnitRetail).HasColumnName("dblUnitRetail").HasPrecision(38, 20);
            this.Property(t => t.dblLineTotal).HasColumnName("dblLineTotal").HasPrecision(18, 6);
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.dblGross).HasColumnName("dblGross").HasPrecision(38, 20);
            this.Property(t => t.dblNet).HasColumnName("dblNet").HasPrecision(38, 20);
            this.Property(t => t.dblTax).HasColumnName("dblTax").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.ysnSubCurrency).HasColumnName("ysnSubCurrency");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.intForexRateTypeId).HasColumnName("intForexRateTypeId");
            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate");

            this.HasOptional(p => p.vyuICInventoryReceiptItemLookUp)
                .WithRequired(p => p.tblICInventoryReceiptItem);
            this.HasMany(p => p.tblICInventoryReceiptItemLots)
                .WithRequired(p => p.tblICInventoryReceiptItem)
                .HasForeignKey(p => p.intInventoryReceiptItemId);

        }
    }

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
        }
    }

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
        }
    }

    public class tblICInventoryReceiptChargeMap : EntityTypeConfiguration<tblICInventoryReceiptCharge>
    {
        public tblICInventoryReceiptChargeMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptChargeId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryReceiptCharge");
            this.Property(t => t.intInventoryReceiptChargeId).HasColumnName("intInventoryReceiptChargeId");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intContractId).HasColumnName("intContractId");
            this.Property(t => t.intContractDetailId).HasColumnName("intContractDetailId");
            this.Property(t => t.intChargeId).HasColumnName("intChargeId");
            this.Property(t => t.ysnInventoryCost).HasColumnName("ysnInventoryCost");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.strAllocateCostBy).HasColumnName("strAllocateCostBy");
            this.Property(t => t.ysnAccrue).HasColumnName("ysnAccrue");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.Property(t => t.ysnSubCurrency).HasColumnName("ysnSubCurrency");
            this.Property(t => t.dblTax).HasColumnName("dblTax");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
           // this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
           // this.Property(t => t.dblExchangeRate).HasColumnName("dblExchangeRate");
           // this.Property(t => t.intCent).HasColumnName("intCent");
            
            this.HasOptional(p => p.vyuICGetInventoryReceiptCharge)
                .WithRequired(p => p.tblICInventoryReceiptCharge);
        }
    }

    public class vyuICGetInventoryReceiptChargeMap : EntityTypeConfiguration<vyuICGetInventoryReceiptCharge>
    {
        public vyuICGetInventoryReceiptChargeMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptChargeId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryReceiptCharge");
            this.Property(t => t.intInventoryReceiptChargeId).HasColumnName("intInventoryReceiptChargeId");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intContractId).HasColumnName("intContractId");
            this.Property(t => t.strContractNumber).HasColumnName("strContractNumber");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.ysnInventoryCost).HasColumnName("ysnInventoryCost");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
            this.Property(t => t.intOnCostTypeId).HasColumnName("intOnCostTypeId");
            this.Property(t => t.strOnCostType).HasColumnName("strOnCostType");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.strAllocateCostBy).HasColumnName("strAllocateCostBy");
            this.Property(t => t.ysnAccrue).HasColumnName("ysnAccrue");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.ysnSubCurrency).HasColumnName("ysnSubCurrency");
            this.Property(t => t.dblTax).HasColumnName("dblTax");
            this.Property(t => t.strReceiptNumber).HasColumnName("strReceiptNumber");
            this.Property(t => t.dtmReceiptDate).HasColumnName("dtmReceiptDate");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strBillOfLading).HasColumnName("strBillOfLading");
            this.Property(t => t.strReceiptVendor).HasColumnName("strReceiptVendor");
            this.Property(t => t.strForexRateType).HasColumnName("strForexRateType");
            //  this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            //   this.Property(t => t.intCent).HasColumnName("intCent");

        }
    }

    public class tblICInventoryReceiptItemLotMap : EntityTypeConfiguration<tblICInventoryReceiptItemLot>
    {
        public tblICInventoryReceiptItemLotMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptItemLotId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryReceiptItemLot");
            this.Property(t => t.intInventoryReceiptItemLotId).HasColumnName("intInventoryReceiptItemLotId");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.strLotAlias).HasColumnName("strLotAlias");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.dblGrossWeight).HasColumnName("dblGrossWeight").HasPrecision(38, 20);
            this.Property(t => t.dblTareWeight).HasColumnName("dblTareWeight").HasPrecision(38, 20);
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(38, 20);
            this.Property(t => t.intUnitPallet).HasColumnName("intUnitPallet");
            this.Property(t => t.dblStatedGrossPerUnit).HasColumnName("dblStatedGrossPerUnit").HasPrecision(38, 20);
            this.Property(t => t.dblStatedTarePerUnit).HasColumnName("dblStatedTarePerUnit").HasPrecision(38, 20);
            this.Property(t => t.strContainerNo).HasColumnName("strContainerNo");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.strGarden).HasColumnName("strGarden");
            this.Property(t => t.strMarkings).HasColumnName("strMarkings");
            this.Property(t => t.intOriginId).HasColumnName("intOriginId");
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.intSeasonCropYear).HasColumnName("intSeasonCropYear");
            this.Property(t => t.strVendorLotId).HasColumnName("strVendorLotId");
            this.Property(t => t.dtmManufacturedDate).HasColumnName("dtmManufacturedDate");
            this.Property(t => t.strRemarks).HasColumnName("strRemarks");
            this.Property(t => t.strCondition).HasColumnName("strCondition");
            this.Property(t => t.dtmCertified).HasColumnName("dtmCertified");
            this.Property(t => t.dtmExpiryDate).HasColumnName("dtmExpiryDate");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intParentLotId).HasColumnName("intParentLotId");
            this.Property(t => t.strParentLotNumber).HasColumnName("strParentLotNumber");
            this.Property(t => t.strParentLotAlias).HasColumnName("strParentLotAlias");
            this.Property(t => t.dblStatedNetPerUnit).HasColumnName("dblStatedNetPerUnit").HasPrecision(38, 20);
            this.Property(t => t.dblStatedTotalNet).HasColumnName("dblStatedTotalNet").HasPrecision(38, 20);
            this.Property(t => t.dblPhysicalVsStated).HasColumnName("dblPhysicalVsStated").HasPrecision(38, 20);
            this.HasOptional(p => p.vyuICGetInventoryReceiptItemLot)
                .WithRequired(p => p.tblICInventoryReceiptItemLot);
        }
    }

    public class vyuICGetInventoryReceiptItemLotMap : EntityTypeConfiguration<vyuICGetInventoryReceiptItemLot>
    {
        public vyuICGetInventoryReceiptItemLotMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptItemLotId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryReceiptItemLot");
            this.Property(t => t.intInventoryReceiptItemLotId).HasColumnName("intInventoryReceiptItemLotId");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.strReceiptNumber).HasColumnName("strReceiptNumber");
            this.Property(t => t.strReceiptType).HasColumnName("strReceiptType");
            this.Property(t => t.strOrderNumber).HasColumnName("strOrderNumber");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strSourceType).HasColumnName("strSourceType");
            this.Property(t => t.strSourceNumber).HasColumnName("strSourceNumber");
            this.Property(t => t.dtmReceiptDate).HasColumnName("dtmReceiptDate");
            this.Property(t => t.strBillOfLading).HasColumnName("strBillOfLading");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strItemUOM).HasColumnName("strItemUOM");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.strLotAlias).HasColumnName("strLotAlias");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty").HasPrecision(38, 20);
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.dblGrossWeight).HasColumnName("dblGrossWeight").HasPrecision(38, 20);
            this.Property(t => t.dblTareWeight).HasColumnName("dblTareWeight").HasPrecision(38, 20);
            this.Property(t => t.dblNetWeight).HasColumnName("dblNetWeight").HasPrecision(38, 20);
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(38, 20);
            this.Property(t => t.intUnitPallet).HasColumnName("intUnitPallet");
            this.Property(t => t.dblStatedGrossPerUnit).HasColumnName("dblStatedGrossPerUnit").HasPrecision(38, 20);
            this.Property(t => t.dblStatedTarePerUnit).HasColumnName("dblStatedTarePerUnit").HasPrecision(38, 20);
            this.Property(t => t.strContainerNo).HasColumnName("strContainerNo");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.strGarden).HasColumnName("strGarden");
            this.Property(t => t.strMarkings).HasColumnName("strMarkings");
            this.Property(t => t.intOriginId).HasColumnName("intOriginId");
            this.Property(t => t.strOrigin).HasColumnName("strOrigin");
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.strGrade).HasColumnName("strGrade");
            this.Property(t => t.intSeasonCropYear).HasColumnName("intSeasonCropYear");
            this.Property(t => t.strVendorLotId).HasColumnName("strVendorLotId");
            this.Property(t => t.dtmManufacturedDate).HasColumnName("dtmManufacturedDate");
            this.Property(t => t.strRemarks).HasColumnName("strRemarks");
            this.Property(t => t.strCondition).HasColumnName("strCondition");
            this.Property(t => t.dtmCertified).HasColumnName("dtmCertified");
            this.Property(t => t.dtmExpiryDate).HasColumnName("dtmExpiryDate");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intParentLotId).HasColumnName("intParentLotId");
            this.Property(t => t.strParentLotNumber).HasColumnName("strParentLotNumber");
            this.Property(t => t.strParentLotAlias).HasColumnName("strParentLotAlias");
            this.Property(t => t.dblStatedNetPerUnit).HasColumnName("dblStatedNetPerUnit").HasPrecision(38, 20);
            this.Property(t => t.dblStatedTotalNet).HasColumnName("dblStatedTotalNet").HasPrecision(38, 20);
            this.Property(t => t.dblPhysicalVsStated).HasColumnName("dblPhysicalVsStated").HasPrecision(38, 20);
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
        }
    }

    public class tblICInventoryReceiptItemTaxMap : EntityTypeConfiguration<tblICInventoryReceiptItemTax>
    {
        public tblICInventoryReceiptItemTaxMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptItemTaxId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryReceiptItemTax");
            this.Property(t => t.intInventoryReceiptItemTaxId).HasColumnName("intInventoryReceiptItemTaxId");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.strTaxableByOtherTaxes).HasColumnName("strTaxableByOtherTaxes");
            this.Property(t => t.strCalculationMethod).HasColumnName("strCalculationMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.dblTax).HasColumnName("dblTax").HasPrecision(18, 6);
            this.Property(t => t.dblAdjustedTax).HasColumnName("dblAdjustedTax").HasPrecision(18, 6);
            this.Property(t => t.intTaxAccountId).HasColumnName("intTaxAccountId");
            this.Property(t => t.ysnTaxAdjusted).HasColumnName("ysnTaxAdjusted");
            this.Property(t => t.ysnSeparateOnInvoice).HasColumnName("ysnSeparateOnInvoice");
            this.Property(t => t.ysnCheckoffTax).HasColumnName("ysnCheckoffTax");
            this.Property(t => t.strTaxCode).HasColumnName("strTaxCode");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }

    public class vyuICGetInventoryReceiptItemTaxMap : EntityTypeConfiguration<vyuICGetInventoryReceiptItemTax>
    {
        public vyuICGetInventoryReceiptItemTaxMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptItemTaxId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryReceiptItemTax");
            this.Property(t => t.intInventoryReceiptItemTaxId).HasColumnName("intInventoryReceiptItemTaxId");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.strTaxGroup).HasColumnName("strTaxGroup");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.strTaxClass).HasColumnName("strTaxClass");
            this.Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            this.Property(t => t.strTaxCode).HasColumnName("strTaxCode");
            this.Property(t => t.strTaxableByOtherTaxes).HasColumnName("strTaxableByOtherTaxes");
            this.Property(t => t.strCalculationMethod).HasColumnName("strCalculationMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.dblTax).HasColumnName("dblTax").HasPrecision(18, 6);
            this.Property(t => t.dblAdjustedTax).HasColumnName("dblAdjustedTax").HasPrecision(18, 6);
            this.Property(t => t.intTaxAccountId).HasColumnName("intTaxAccountId");
            this.Property(t => t.ysnTaxAdjusted).HasColumnName("ysnTaxAdjusted");
            this.Property(t => t.ysnSeparateOnInvoice).HasColumnName("ysnSeparateOnInvoice");
            this.Property(t => t.ysnCheckoffTax).HasColumnName("ysnCheckoffTax");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }

    public class tblICInventoryReceiptInspectionMap : EntityTypeConfiguration<tblICInventoryReceiptInspection>
    {
        public tblICInventoryReceiptInspectionMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptInspectionId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryReceiptInspection");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intInventoryReceiptInspectionId).HasColumnName("intInventoryReceiptInspectionId");
            this.Property(t => t.intQAPropertyId).HasColumnName("intQAPropertyId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.ysnSelected).HasColumnName("ysnSelected");
            this.Property(t => t.strPropertyName).HasColumnName("strPropertyName");

           /* this.HasOptional(t => t.tblMFQAProperty)
                .WithMany(t => t.tblICInventoryReceiptInspections)
                .HasForeignKey(t => t.intQAPropertyId);*/
        }
    }

    public class vyuICGetReceiptAddOrderMap : EntityTypeConfiguration<vyuICGetReceiptAddOrder>
    {
        public vyuICGetReceiptAddOrderMap()
        {
            // Primary Key
            this.HasKey(t => t.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetReceiptAddOrder");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
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
        }
    }

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
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
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
        }
    }

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
        }
    }

    public class vyuICGetReceiptAddTransferOrderMap : EntityTypeConfiguration<vyuICGetReceiptAddTransferOrder>
    {
        public vyuICGetReceiptAddTransferOrderMap()
        {
            // Primary Key
            this.HasKey(t => t.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetReceiptAddTransferOrder");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
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
        }
    }

    public class vyuICGetReceiptAddPurchaseContractMap : EntityTypeConfiguration<vyuICGetReceiptAddPurchaseContract>
    {
        public vyuICGetReceiptAddPurchaseContractMap()
        {
            // Primary Key
            this.HasKey(t => t.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetReceiptAddPurchaseContract");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
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
        }
    }

    public class vyuICGetReceiptAddLGInboundShipmentMap : EntityTypeConfiguration<vyuICGetReceiptAddLGInboundShipment>
    {
        public vyuICGetReceiptAddLGInboundShipmentMap()
        {
            // Primary Key
            this.HasKey(t => t.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetReceiptAddLGInboundShipment");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
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
        }
    }

    public class tblICInventoryReceiptChargeTaxMap : EntityTypeConfiguration<tblICInventoryReceiptChargeTax>
    {
        public tblICInventoryReceiptChargeTaxMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptChargeTaxId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryReceiptChargeTax");
            this.Property(t => t.intInventoryReceiptChargeTaxId).HasColumnName("intInventoryReceiptChargeTaxId");
            this.Property(t => t.intInventoryReceiptChargeId).HasColumnName("intInventoryReceiptChargeId");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.strTaxableByOtherTaxes).HasColumnName("strTaxableByOtherTaxes");
            this.Property(t => t.strCalculationMethod).HasColumnName("strCalculationMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.dblTax).HasColumnName("dblTax").HasPrecision(18, 6);
            this.Property(t => t.dblAdjustedTax).HasColumnName("dblAdjustedTax").HasPrecision(18, 6);
            this.Property(t => t.intTaxAccountId).HasColumnName("intTaxAccountId");
            this.Property(t => t.ysnTaxAdjusted).HasColumnName("ysnTaxAdjusted");
            this.Property(t => t.ysnCheckoffTax).HasColumnName("ysnCheckoffTax");
            this.Property(t => t.strTaxCode).HasColumnName("strTaxCode");
            this.Property(t => t.intSort).HasColumnName("intSort");
                
        }
    }

    public class vyuICGetInventoryReceiptChargeTaxMap : EntityTypeConfiguration<vyuICGetInventoryReceiptChargeTax>
    {
        public vyuICGetInventoryReceiptChargeTaxMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptChargeTaxId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryReceiptChargeTax");
            this.Property(t => t.intInventoryReceiptChargeTaxId).HasColumnName("intInventoryReceiptChargeTaxId");
            this.Property(t => t.intInventoryReceiptChargeId).HasColumnName("intInventoryReceiptChargeId");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intChargeId).HasColumnName("intChargeId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.strTaxGroup).HasColumnName("strTaxGroup");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.strTaxClass).HasColumnName("strTaxClass");
            this.Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            this.Property(t => t.strTaxCode).HasColumnName("strTaxCode");
            this.Property(t => t.strTaxableByOtherTaxes).HasColumnName("strTaxableByOtherTaxes");
            this.Property(t => t.strCalculationMethod).HasColumnName("strCalculationMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.dblTax).HasColumnName("dblTax").HasPrecision(18, 6);
            this.Property(t => t.dblAdjustedTax).HasColumnName("dblAdjustedTax").HasPrecision(18, 6);
            this.Property(t => t.intTaxAccountId).HasColumnName("intTaxAccountId");
            this.Property(t => t.ysnTaxAdjusted).HasColumnName("ysnTaxAdjusted");
            this.Property(t => t.ysnCheckoffTax).HasColumnName("ysnCheckoffTax");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }

    public class vyuICGetChargeTaxDetailsMap : EntityTypeConfiguration<vyuICGetChargeTaxDetails>
    {
        public vyuICGetChargeTaxDetailsMap()
        {
            // Primary Key
            this.HasKey(t => t.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetChargeTaxDetails");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intInventoryReceiptChargeTaxId).HasColumnName("intInventoryReceiptChargeTaxId");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intChargeId).HasColumnName("intChargeId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strTaxGroup).HasColumnName("strTaxGroup");
            this.Property(t => t.strTaxCode).HasColumnName("strTaxCode");
            this.Property(t => t.strCalculationMethod).HasColumnName("strCalculationMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate");
            this.Property(t => t.dblTax).HasColumnName("dblTax");
        }
    }

}
