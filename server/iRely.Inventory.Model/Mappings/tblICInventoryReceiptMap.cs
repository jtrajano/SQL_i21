﻿using System.ComponentModel.DataAnnotations.Schema;
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
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.intTransferorId).HasColumnName("intTransferorId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strReceiptNumber).HasColumnName("strReceiptNumber");
            this.Property(t => t.dtmReceiptDate).HasColumnName("dtmReceiptDate");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.intBlanketRelease).HasColumnName("intBlanketRelease");
            this.Property(t => t.strVendorRefNo).HasColumnName("strVendorRefNo");
            this.Property(t => t.strBillOfLading).HasColumnName("strBillOfLading");
            this.Property(t => t.intShipViaId).HasColumnName("intShipViaId");
            this.Property(t => t.intShipFromId).HasColumnName("intShipFromId");
            this.Property(t => t.intReceiverId).HasColumnName("intReceiverId");
            this.Property(t => t.strVessel).HasColumnName("strVessel");
            this.Property(t => t.intFreightTermId).HasColumnName("intFreightTermId");
            this.Property(t => t.strAllocateFreight).HasColumnName("strAllocateFreight");
            this.Property(t => t.intShiftNumber).HasColumnName("intShiftNumber");
            this.Property(t => t.strCalculationBasis).HasColumnName("strCalculationBasis");
            this.Property(t => t.dblUnitWeightMile).HasColumnName("dblUnitWeightMile").HasPrecision(18, 6);
            this.Property(t => t.dblFreightRate).HasColumnName("dblFreightRate").HasPrecision(18, 6);
            this.Property(t => t.dblFuelSurcharge).HasColumnName("dblFuelSurcharge").HasPrecision(18, 6);
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
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intCreatedUserId).HasColumnName("intCreatedUserId");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");

            this.HasOptional(p => p.vyuAPVendor)
                .WithMany(p => p.tblICInventoryReceipts)
                .HasForeignKey(p => p.intEntityVendorId);
            this.HasOptional(p => p.tblSMFreightTerm)
                .WithMany(p => p.tblICInventoryReceipts)
                .HasForeignKey(p => p.intFreightTermId);
            this.HasOptional(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICInventoryReceipts)
                .HasForeignKey(p => p.intLocationId);
            this.HasMany(p => p.tblICInventoryReceiptItems)
                .WithRequired(p => p.tblICInventoryReceipt)
                .HasForeignKey(p => p.intInventoryReceiptId);
                
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
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.dblOrderQty).HasColumnName("dblOrderQty").HasPrecision(18, 6);
            this.Property(t => t.dblOpenReceive).HasColumnName("dblOpenReceive").HasPrecision(18, 6);
            this.Property(t => t.dblReceived).HasColumnName("dblReceived").HasPrecision(18, 6);
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.dblUnitCost).HasColumnName("dblUnitCost").HasPrecision(18, 6);
            this.Property(t => t.dblUnitRetail).HasColumnName("dblUnitRetail").HasPrecision(18, 6);
            this.Property(t => t.dblLineTotal).HasColumnName("dblLineTotal").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICItem)
                .WithMany(p => p.tblICInventoryReceiptItems)
                .HasForeignKey(p => p.intItemId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICInventoryReceiptItems)
                .HasForeignKey(p => p.intUnitMeasureId);
            this.HasOptional(p => p.vyuICGetReceiptItemSource)
                .WithRequired(p => p.tblICInventoryReceiptItem);
            this.HasOptional(p => p.tblSMCompanyLocationSubLocation)
                .WithMany(p => p.tblICInventoryReceiptItems)
                .HasForeignKey(p => p.intSubLocationId);
            this.HasOptional(p => p.WeightUOM)
                .WithMany(p => p.WeightUOMs)
                .HasForeignKey(p => p.intWeightUOMId);
            this.HasMany(p => p.tblICInventoryReceiptItemLots)
                .WithRequired(p => p.tblICInventoryReceiptItem)
                .HasForeignKey(p => p.intInventoryReceiptItemId);
        }
    }

    public class vyuICGetReceiptItemSourceMap : EntityTypeConfiguration<vyuICGetReceiptItemSource>
    {
        public vyuICGetReceiptItemSourceMap()
        {
            // Primary Key
            this.HasKey(p => p.intInventoryReceiptItemId);

            // Table & Column Mappings
            this.ToTable("vyuICGetReceiptItemSource");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.strSourceId).HasColumnName("strSourceId");
            this.Property(t => t.dtmDate).HasColumnName("dtmDate");
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
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.dblGrossWeight).HasColumnName("dblGrossWeight").HasPrecision(18, 6);
            this.Property(t => t.dblTareWeight).HasColumnName("dblTareWeight").HasPrecision(18, 6);
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(18, 6);
            this.Property(t => t.intUnitPallet).HasColumnName("intUnitPallet");
            this.Property(t => t.dblStatedGrossPerUnit).HasColumnName("dblStatedGrossPerUnit").HasPrecision(18, 6);
            this.Property(t => t.dblStatedTarePerUnit).HasColumnName("dblStatedTarePerUnit").HasPrecision(18, 6);
            this.Property(t => t.strContainerNo).HasColumnName("strContainerNo");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.intVendorLocationId).HasColumnName("intVendorLocationId");
            this.Property(t => t.strVendorLocation).HasColumnName("strVendorLocation");
            this.Property(t => t.strMarkings).HasColumnName("strMarkings");
            this.Property(t => t.strGrade).HasColumnName("strGrade");
            this.Property(t => t.intOriginId).HasColumnName("intOriginId");
            this.Property(t => t.intSeasonCropYear).HasColumnName("intSeasonCropYear");
            this.Property(t => t.strVendorLotId).HasColumnName("strVendorLotId");
            this.Property(t => t.dtmManufacturedDate).HasColumnName("dtmManufacturedDate");
            this.Property(t => t.strRemarks).HasColumnName("strRemarks");
            this.Property(t => t.strCondition).HasColumnName("strCondition");
            this.Property(t => t.dtmCertified).HasColumnName("dtmCertified");
            this.Property(t => t.dtmExpiryDate).HasColumnName("dtmExpiryDate");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICLot)
                .WithRequired(p => p.tblICInventoryReceiptItemLot)
                .WillCascadeOnDelete(false);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICInventoryReceiptItemLots)
                .HasForeignKey(p => p.intItemUnitMeasureId);
            this.HasOptional(p => p.tblICStorageLocation)
                .WithMany(p => p.tblICInventoryReceiptItemLots)
                .HasForeignKey(p => p.intStorageLocationId);
            
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
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.intInventoryReceiptItemTaxId).HasColumnName("intInventoryReceiptItemTaxId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            this.Property(t => t.ysnSelected).HasColumnName("ysnSelected");
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

            this.HasOptional(t => t.tblMFQAProperty)
                .WithMany(t => t.tblICInventoryReceiptInspections)
                .HasForeignKey(t => t.intQAPropertyId);
        }
    }
}
