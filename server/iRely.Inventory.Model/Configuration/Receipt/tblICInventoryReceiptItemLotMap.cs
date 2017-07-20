﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;
using System.ComponentModel.DataAnnotations.Schema;

namespace iRely.Inventory.Model
{
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
}
