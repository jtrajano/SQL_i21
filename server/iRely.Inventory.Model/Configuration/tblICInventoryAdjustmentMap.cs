using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICInventoryAdjustmentMap : EntityTypeConfiguration<tblICInventoryAdjustment>
    {
        public tblICInventoryAdjustmentMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryAdjustmentId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryAdjustment");
            this.Property(t => t.intInventoryAdjustmentId).HasColumnName("intInventoryAdjustmentId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.dtmAdjustmentDate).HasColumnName("dtmAdjustmentDate");
            this.Property(t => t.intAdjustmentType).HasColumnName("intAdjustmentType");
            this.Property(t => t.strAdjustmentNo).HasColumnName("strAdjustmentNo");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.dtmPostedDate).HasColumnName("dtmPostedDate");
            this.Property(t => t.dtmUnpostedDate).HasColumnName("dtmUnpostedDate");
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.intSourceTransactionTypeId).HasColumnName("intSourceTransactionTypeId");

            this.HasMany(p => p.tblICInventoryAdjustmentDetails)
                .WithRequired(p => p.tblICInventoryAdjustment)
                .HasForeignKey(p => p.intInventoryAdjustmentId);
            this.HasOptional(p => p.vyuICGetInventoryAdjustment)
                .WithRequired(p => p.tblICInventoryAdjustment);
        }
    }

    public class vyuICGetInventoryAdjustmentMap : EntityTypeConfiguration<vyuICGetInventoryAdjustment>
    {
        public vyuICGetInventoryAdjustmentMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryAdjustmentId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryAdjustment");
            this.Property(t => t.intInventoryAdjustmentId).HasColumnName("intInventoryAdjustmentId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.dtmAdjustmentDate).HasColumnName("dtmAdjustmentDate");
            this.Property(t => t.intAdjustmentType).HasColumnName("intAdjustmentType");
            this.Property(t => t.strAdjustmentType).HasColumnName("strAdjustmentType");
            this.Property(t => t.strAdjustmentNo).HasColumnName("strAdjustmentNo");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.strUser).HasColumnName("strUser");
            this.Property(t => t.dtmPostedDate).HasColumnName("dtmPostedDate");
            this.Property(t => t.dtmUnpostedDate).HasColumnName("dtmUnpostedDate");
            this.Property(t => t.intSourceId).HasColumnName("intSourceId");
            this.Property(t => t.intSourceTransactionTypeId).HasColumnName("intSourceTransactionTypeId");
        }
    }

    public class tblICInventoryAdjustmentDetailMap : EntityTypeConfiguration<tblICInventoryAdjustmentDetail>
    {
        public tblICInventoryAdjustmentDetailMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryAdjustmentDetailId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryAdjustmentDetail");
            this.Property(t => t.intInventoryAdjustmentDetailId).HasColumnName("intInventoryAdjustmentDetailId");
            this.Property(t => t.intInventoryAdjustmentId).HasColumnName("intInventoryAdjustmentId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intNewItemId).HasColumnName("intNewItemId");

            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.intNewLotId).HasColumnName("intNewLotId");
            this.Property(t => t.strNewLotNumber).HasColumnName("strNewLotNumber");

            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.dblNewQuantity).HasColumnName("dblNewQuantity").HasPrecision(38, 20);
            this.Property(t => t.dblAdjustByQuantity).HasColumnName("dblAdjustByQuantity").HasPrecision(38, 20);
            this.Property(t => t.dblNewSplitLotQuantity).HasColumnName("dblNewSplitLotQuantity").HasPrecision(38, 20);

            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intNewItemUOMId).HasColumnName("intNewItemUOMId");

            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.intNewWeightUOMId).HasColumnName("intNewWeightUOMId");

            this.Property(t => t.dblWeight).HasColumnName("dblWeight").HasPrecision(38, 20);
            this.Property(t => t.dblNewWeight).HasColumnName("dblNewWeight").HasPrecision(38, 20);

            this.Property(t => t.dblWeightPerQty).HasColumnName("dblWeightPerQty").HasPrecision(38, 20);
            this.Property(t => t.dblNewWeightPerQty).HasColumnName("dblNewWeightPerQty").HasPrecision(38, 20);

            this.Property(t => t.dtmExpiryDate).HasColumnName("dtmExpiryDate");
            this.Property(t => t.dtmNewExpiryDate).HasColumnName("dtmNewExpiryDate");

            this.Property(t => t.intLotStatusId).HasColumnName("intLotStatusId");
            this.Property(t => t.intNewLotStatusId).HasColumnName("intNewLotStatusId");
            
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(38,20);
            this.Property(t => t.dblNewCost).HasColumnName("dblNewCost").HasPrecision(38, 20);

            this.Property(t => t.dblLineTotal).HasColumnName("dblLineTotal").HasPrecision(38,20);
            
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.Property(t => t.intNewLocationId).HasColumnName("intNewLocationId");
            this.Property(t => t.intNewSubLocationId).HasColumnName("intNewSubLocationId");
            this.Property(t => t.intNewStorageLocationId).HasColumnName("intNewStorageLocationId");

            this.Property(t => t.intItemOwnerId).HasColumnName("intItemOwnerId");
            this.Property(t => t.intNewItemOwnerId).HasColumnName("intNewItemOwnerId");

            this.HasOptional(p => p.vyuICGetInventoryAdjustmentDetail)
                .WithRequired(p => p.tblICInventoryAdjustmentDetail);
        }
    }

    class vyuICGetInventoryAdjustmentDetailMap : EntityTypeConfiguration<vyuICGetInventoryAdjustmentDetail>
    {
        public vyuICGetInventoryAdjustmentDetailMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryAdjustmentDetailId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryAdjustmentDetail");
            this.Property(t => t.intInventoryAdjustmentDetailId).HasColumnName("intInventoryAdjustmentDetailId");
            this.Property(t => t.intInventoryAdjustmentId).HasColumnName("intInventoryAdjustmentId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.dtmAdjustmentDate).HasColumnName("dtmAdjustmentDate");
            this.Property(t => t.intAdjustmentType).HasColumnName("intAdjustmentType");
            this.Property(t => t.strAdjustmentType).HasColumnName("strAdjustmentType");
            this.Property(t => t.strAdjustmentNo).HasColumnName("strAdjustmentNo");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.strUser).HasColumnName("strUser");
            this.Property(t => t.dtmPostedDate).HasColumnName("dtmPostedDate");
            this.Property(t => t.dtmUnpostedDate).HasColumnName("dtmUnpostedDate");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intNewItemId).HasColumnName("intNewItemId");
            this.Property(t => t.strNewItemNo).HasColumnName("strNewItemNo");
            this.Property(t => t.strNewItemDescription).HasColumnName("strNewItemDescription");
            this.Property(t => t.strNewLotTracking).HasColumnName("strNewLotTracking");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.dblLotQty).HasColumnName("dblLotQty").HasPrecision(18, 6);
            this.Property(t => t.dblLotUnitCost).HasColumnName("dblLotUnitCost").HasPrecision(18, 6);
            this.Property(t => t.dblLotWeightPerQty).HasColumnName("dblLotWeightPerQty").HasPrecision(18, 6);
            this.Property(t => t.intNewLotId).HasColumnName("intNewLotId");
            this.Property(t => t.strNewLotNumber).HasColumnName("strNewLotNumber");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.dblNewQuantity).HasColumnName("dblNewQuantity").HasPrecision(18, 6);
            this.Property(t => t.dblNewSplitLotQuantity).HasColumnName("dblNewSplitLotQuantity").HasPrecision(18, 6);
            this.Property(t => t.dblAdjustByQuantity).HasColumnName("dblAdjustByQuantity").HasPrecision(18, 6);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strItemUOM).HasColumnName("strItemUOM");
            this.Property(t => t.dblItemUOMUnitQty).HasColumnName("dblItemUOMUnitQty").HasPrecision(18, 6);
            this.Property(t => t.intNewItemUOMId).HasColumnName("intNewItemUOMId");
            this.Property(t => t.strNewItemUOM).HasColumnName("strNewItemUOM");
            this.Property(t => t.dblNewItemUOMUnitQty).HasColumnName("dblNewItemUOMUnitQty").HasPrecision(18, 6);
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.intNewWeightUOMId).HasColumnName("intNewWeightUOMId");
            this.Property(t => t.strNewWeightUOM).HasColumnName("strNewWeightUOM");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight").HasPrecision(18, 6);
            this.Property(t => t.dblNewWeight).HasColumnName("dblNewWeight").HasPrecision(18, 6);
            this.Property(t => t.dblWeightPerQty).HasColumnName("dblWeightPerQty").HasPrecision(18, 6);
            this.Property(t => t.dblNewWeightPerQty).HasColumnName("dblNewWeightPerQty").HasPrecision(18, 6);
            this.Property(t => t.dtmExpiryDate).HasColumnName("dtmExpiryDate");
            this.Property(t => t.dtmNewExpiryDate).HasColumnName("dtmNewExpiryDate");
            this.Property(t => t.intLotStatusId).HasColumnName("intLotStatusId");
            this.Property(t => t.strLotStatus).HasColumnName("strLotStatus");
            this.Property(t => t.intNewLotStatusId).HasColumnName("intNewLotStatusId");
            this.Property(t => t.strNewLotStatus).HasColumnName("strNewLotStatus");
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(18, 6);
            this.Property(t => t.dblNewCost).HasColumnName("dblNewCost").HasPrecision(18, 6);
            this.Property(t => t.intNewLocationId).HasColumnName("intNewLocationId");
            this.Property(t => t.strNewLocationName).HasColumnName("strNewLocationName");
            this.Property(t => t.intNewSubLocationId).HasColumnName("intNewSubLocationId");
            this.Property(t => t.strNewSubLocationName).HasColumnName("strNewSubLocationName");
            this.Property(t => t.intNewStorageLocationId).HasColumnName("intNewStorageLocationId");
            this.Property(t => t.strNewStorageLocationName).HasColumnName("strNewStorageLocationName");
            this.Property(t => t.dblLineTotal).HasColumnName("dblLineTotal").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strOwnerName).HasColumnName("strOwnerName");
            this.Property(t => t.strNewOwnerName).HasColumnName("strNewOwnerName");
        }
    }
}

