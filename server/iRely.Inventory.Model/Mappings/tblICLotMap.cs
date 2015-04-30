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
            this.Property(t => t.dblItemUOMConv).HasColumnName("dblItemUOMConv").HasPrecision(18, 6);
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocation).HasColumnName("strStorageLocation");
            this.Property(t => t.dblQty).HasColumnName("dblQty").HasPrecision(18, 6);
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(18, 6);
            this.Property(t => t.dtmExpiryDate).HasColumnName("dtmExpiryDate");
            this.Property(t => t.strLotAlias).HasColumnName("strLotAlias");
            this.Property(t => t.intLotStatusId).HasColumnName("intLotStatusId");
            this.Property(t => t.strLotStatus).HasColumnName("strLotStatus");
            this.Property(t => t.strLotStatusType).HasColumnName("strLotStatusType");
            this.Property(t => t.intParentLotId).HasColumnName("intParentLotId");
            this.Property(t => t.intSplitFromLotId).HasColumnName("intSplitFromLotId");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight").HasPrecision(18, 6);
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.dblWeightUOMConv).HasColumnName("dblWeightUOMConv").HasPrecision(18, 6);
            this.Property(t => t.dblWeightPerQty).HasColumnName("dblWeightPerQty").HasPrecision(18, 6);
            this.Property(t => t.intOriginId).HasColumnName("intOriginId");
            this.Property(t => t.strBOLNo).HasColumnName("strBOLNo");
            this.Property(t => t.strVessel).HasColumnName("strVessel");
            this.Property(t => t.strReceiptNumber).HasColumnName("strReceiptNumber");
            this.Property(t => t.strMarkings).HasColumnName("strMarkings");
            this.Property(t => t.strNotes).HasColumnName("strNotes");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.strVendorLotNo).HasColumnName("strVendorLotNo");
            this.Property(t => t.intVendorLocationId).HasColumnName("intVendorLocationId");
            this.Property(t => t.strVendorLocation).HasColumnName("strVendorLocation");
            this.Property(t => t.strContractNo).HasColumnName("strContractNo");
            this.Property(t => t.dtmManufacturedDate).HasColumnName("dtmManufacturedDate");
            this.Property(t => t.ysnReleasedToWarehouse).HasColumnName("ysnReleasedToWarehouse");
            this.Property(t => t.ysnProduced).HasColumnName("ysnProduced");
            this.Property(t => t.dtmDateCreated).HasColumnName("dtmDateCreated");
            this.Property(t => t.intCreatedUserId).HasColumnName("intCreatedUserId");
        }
    }
}
