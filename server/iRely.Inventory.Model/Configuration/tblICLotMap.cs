using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICLotMap : EntityTypeConfiguration<tblICLot>
    {
        public tblICLotMap()
        {
            // Primary Key
            this.HasKey(p => p.intLotId);

            // Table & Column Mappings
            this.ToTable("vyuICGetLot");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strItemUOM).HasColumnName("strItemUOM");
            this.Property(t => t.strItemUOMType).HasColumnName("strItemUOMType");
            this.Property(t => t.dblItemUOMConv).HasColumnName("dblItemUOMConv").HasPrecision(38, 20);
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.intOwnershipType).HasColumnName("intOwnershipType");
            this.Property(t => t.strOwnershipType).HasColumnName("strOwnershipType");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocation).HasColumnName("strStorageLocation");
            this.Property(t => t.dblQty).HasColumnName("dblQty").HasPrecision(38, 20);
            this.Property(t => t.dblReservedQty).HasColumnName("dblReservedQty").HasPrecision(38, 20);
            this.Property(t => t.dblAvailableQty).HasColumnName("dblAvailableQty").HasPrecision(38, 20);
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(38, 20);
            this.Property(t => t.dtmExpiryDate).HasColumnName("dtmExpiryDate");
            this.Property(t => t.strLotAlias).HasColumnName("strLotAlias");
            this.Property(t => t.intLotStatusId).HasColumnName("intLotStatusId");
            this.Property(t => t.strLotStatus).HasColumnName("strLotStatus");
            this.Property(t => t.strLotStatusType).HasColumnName("strLotStatusType");
            this.Property(t => t.intParentLotId).HasColumnName("intParentLotId");
            this.Property(t => t.intSplitFromLotId).HasColumnName("intSplitFromLotId");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight").HasPrecision(38, 20);
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.dblWeightUOMConv).HasColumnName("dblWeightUOMConv").HasPrecision(38, 20);
            this.Property(t => t.dblWeightPerQty).HasColumnName("dblWeightPerQty").HasPrecision(38, 20);
            this.Property(t => t.intOriginId).HasColumnName("intOriginId");
            this.Property(t => t.strBOLNo).HasColumnName("strBOLNo");
            this.Property(t => t.strVessel).HasColumnName("strVessel");
            this.Property(t => t.strReceiptNumber).HasColumnName("strReceiptNumber");
            this.Property(t => t.strMarkings).HasColumnName("strMarkings");
            this.Property(t => t.strNotes).HasColumnName("strNotes");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.strVendorLotNo).HasColumnName("strVendorLotNo");
            this.Property(t => t.strGarden).HasColumnName("strGarden");
            this.Property(t => t.strContractNo).HasColumnName("strContractNo");
            this.Property(t => t.dtmManufacturedDate).HasColumnName("dtmManufacturedDate");
            this.Property(t => t.ysnReleasedToWarehouse).HasColumnName("ysnReleasedToWarehouse");
            this.Property(t => t.ysnProduced).HasColumnName("ysnProduced");
            this.Property(t => t.ysnStorage).HasColumnName("ysnStorage");
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.strGrade).HasColumnName("strGrade");
            this.Property(t => t.dtmDateCreated).HasColumnName("dtmDateCreated");
            this.Property(t => t.intCreatedUserId).HasColumnName("intCreatedUserId");
        }
    }

    public class vyuICItemLotMap : EntityTypeConfiguration<vyuICItemLot>
    {
        public vyuICItemLotMap()
        {
            this.HasKey(p => p.intLotId);
            this.ToTable("vyuICItemLot");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strProductType).HasColumnName("strProductType");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.strStorageLocation).HasColumnName("strStorageLocation");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.dblQty).HasColumnName("dblQty");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight");
            this.Property(t => t.strItemUOM).HasColumnName("strItemUOM");
            this.Property(t => t.dblWeightPerQty).HasColumnName("dblWeightPerQty");
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
        }
    }

    public class vyuICGetPostedLotMap : EntityTypeConfiguration<vyuICGetPostedLot>
    {
        public vyuICGetPostedLotMap()
        {
            // Primary Key
            this.HasKey(p => p.intLotId);

            // Table & Column Mappings
            this.ToTable("vyuICGetPostedLot");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.strLotAlias).HasColumnName("strLotAlias");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.dblItemUOMUnitQty).HasColumnName("dblItemUOMUnitQty").HasPrecision(38, 20);
            this.Property(t => t.strItemUOM).HasColumnName("strItemUOM");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.dblQty).HasColumnName("dblQty").HasPrecision(38, 20);
            this.Property(t => t.dblWeight).HasColumnName("dblWeight").HasPrecision(38, 20);
            this.Property(t => t.dblWeightPerQty).HasColumnName("dblWeightPerQty").HasPrecision(38, 20);
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(38, 20);
            this.Property(t => t.dtmExpiryDate).HasColumnName("dtmExpiryDate");
            this.Property(t => t.intLotStatusId).HasColumnName("intLotStatusId");
            this.Property(t => t.strLotStatus).HasColumnName("strLotStatus");
            this.Property(t => t.strLotPrimaryStatus).HasColumnName("strLotPrimaryStatus");
            this.Property(t => t.strOwnerName).HasColumnName("strOwnerName");
            this.Property(t => t.intItemOwnerId).HasColumnName("intItemOwnerId");
        }
    }
}
