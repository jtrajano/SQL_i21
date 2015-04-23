using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
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
            this.Property(t => t.strItemUOM).HasColumnName("strItemUOM");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.dblQty).HasColumnName("dblQty");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight");
            this.Property(t => t.dblWeightPerQty).HasColumnName("dblWeightPerQty");
            this.Property(t => t.dblCost).HasColumnName("dblCost");
            this.Property(t => t.dtmExpiryDate).HasColumnName("dtmExpiryDate");
            this.Property(t => t.intLotStatusId).HasColumnName("intLotStatusId");
            this.Property(t => t.strLotStatus).HasColumnName("strLotStatus");
            this.Property(t => t.strLotPrimaryStatus).HasColumnName("strLotPrimaryStatus");
        }
    }
}

