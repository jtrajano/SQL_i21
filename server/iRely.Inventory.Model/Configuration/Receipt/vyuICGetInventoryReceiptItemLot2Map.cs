using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
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
}
