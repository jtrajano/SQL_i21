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
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
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
            this.Property(t => t.dblUnitWeightMile).HasColumnName("dblUnitWeightMile");
            this.Property(t => t.dblFreightRate).HasColumnName("dblFreightRate");
            this.Property(t => t.dblFuelSurcharge).HasColumnName("dblFuelSurcharge");
            this.Property(t => t.dblInvoiceAmount).HasColumnName("dblInvoiceAmount");
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
            this.Property(t => t.dblActualTempReading).HasColumnName("dblActualTempReading");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intCreatedUserId).HasColumnName("intCreatedUserId");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");

            this.HasOptional(p => p.vyuAPVendor)
                .WithMany(p => p.tblICInventoryReceipts)
                .HasForeignKey(p => p.intVendorId);
            this.HasOptional(p => p.tblSMFreightTerm)
                .WithMany(p => p.tblICInventoryReceipts)
                .HasForeignKey(p => p.intFreightTermId);
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
            this.Property(t => t.dblOrderQty).HasColumnName("dblOrderQty");
            this.Property(t => t.dblOpenReceive).HasColumnName("dblOpenReceive");
            this.Property(t => t.dblReceived).HasColumnName("dblReceived");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.intNoPackages).HasColumnName("intNoPackages");
            this.Property(t => t.intPackTypeId).HasColumnName("intPackTypeId");
            this.Property(t => t.dblExpPackageWeight).HasColumnName("dblExpPackageWeight");
            this.Property(t => t.dblUnitCost).HasColumnName("dblUnitCost");
            this.Property(t => t.dblLineTotal).HasColumnName("dblLineTotal");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICItem)
                .WithMany(p => p.tblICInventoryReceiptItems)
                .HasForeignKey(p => p.intItemId);
            this.HasOptional(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICInventoryReceiptItems)
                .HasForeignKey(p => p.intUnitMeasureId);
            this.HasOptional(p => p.tblICPackType)
                .WithMany(p => p.tblICInventoryReceiptItems)
                .HasForeignKey(p => p.intPackTypeId);
            this.HasOptional(p => p.vyuICGetReceiptItemSource)
                .WithRequired(p => p.tblICInventoryReceiptItem);
                
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
            this.Property(t => t.dblGrossWeight).HasColumnName("dblGrossWeight");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity");
            this.Property(t => t.dblStatedGrossPerUnit).HasColumnName("dblStatedGrossPerUnit");
            this.Property(t => t.dblStatedTarePerUnit).HasColumnName("dblStatedTarePerUnit");
            this.Property(t => t.dblTareWeight).HasColumnName("dblTareWeight");
            this.Property(t => t.dtmManufacturedDate).HasColumnName("dtmManufacturedDate");
            this.Property(t => t.intGarden).HasColumnName("intGarden");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.intInventoryReceiptItemLotId).HasColumnName("intInventoryReceiptItemLotId");
            this.Property(t => t.intOriginId).HasColumnName("intOriginId");
            this.Property(t => t.intSeasonCropYear).HasColumnName("intSeasonCropYear");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intStorageBinId).HasColumnName("intStorageBinId");
            this.Property(t => t.intUnitPallet).HasColumnName("intUnitPallet");
            this.Property(t => t.intUnits).HasColumnName("intUnits");
            this.Property(t => t.intUnitUOMId).HasColumnName("intUnitUOMId");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strContainerNo).HasColumnName("strContainerNo");
            this.Property(t => t.strGrade).HasColumnName("strGrade");
            this.Property(t => t.strLotId).HasColumnName("strLotId");
            this.Property(t => t.strParentLotId).HasColumnName("strParentLotId");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.intParentLotId).HasColumnName("intParentLotId");
            this.Property(t => t.strRemarks).HasColumnName("strRemarks");
            this.Property(t => t.strVendorLotId).HasColumnName("strVendorLotId");

            this.HasOptional(p => p.tblICLot)
                .WithRequired(p => p.tblICInventoryReceiptItemLot)
                .WillCascadeOnDelete(false);
                
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
