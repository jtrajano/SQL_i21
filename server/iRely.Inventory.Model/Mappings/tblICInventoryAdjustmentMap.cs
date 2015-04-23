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

            this.HasOptional(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICInventoryAdjustments)
                .HasForeignKey(p => p.intLocationId);
            this.HasMany(p => p.tblICInventoryAdjustmentDetails)
                .WithRequired(p => p.tblICInventoryAdjustment)
                .HasForeignKey(p => p.intInventoryAdjustmentId);
            this.HasMany(p => p.tblICInventoryAdjustmentNotes)
                .WithRequired(p => p.tblICInventoryAdjustment)
                .HasForeignKey(p => p.intInventoryAdjustmentId);
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

            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.dblNewQuantity).HasColumnName("dblNewQuantity").HasPrecision(18, 6);

            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intNewItemUOMId).HasColumnName("intNewItemUOMId");

            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.intNewWeightUOMId).HasColumnName("intNewWeightUOMId");            

            this.Property(t => t.dblWeight).HasColumnName("dblWeight").HasPrecision(18, 6);
            this.Property(t => t.dblNewWeight).HasColumnName("dblNewWeight").HasPrecision(18, 6);

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
            
            this.HasOptional(p => p.tblSMCompanyLocationSubLocation)
                .WithMany(p => p.tblICInventoryAdjustmentDetails)
                .HasForeignKey(p => p.intSubLocationId);

            this.HasOptional(p => p.tblICStorageLocation)
                .WithMany(p => p.tblICInventoryAdjustmentDetails)
                .HasForeignKey(p => p.intStorageLocationId);

            this.HasOptional(p => p.Item)
                .WithMany(p => p.tblICInventoryAdjustmentDetails)
                .HasForeignKey(p => p.intItemId);
            this.HasOptional(p => p.NewItem)
                .WithMany(p => p.NewAdjustmentDetails)
                .HasForeignKey(p => p.intNewItemId);            
            
            this.HasOptional(p => p.Lot)
                .WithMany(p => p.tblICInventoryAdjustmentDetails)
                .HasForeignKey(p => p.intLotId);
            this.HasOptional(p => p.NewLot)
                .WithMany(p => p.NewAdjustmentDetails)
                .HasForeignKey(p => p.intNewLotId);

            this.HasOptional(p => p.ItemUOM)
                .WithMany(p => p.OldItemUOMAdjustmentDetails)
                .HasForeignKey(p => p.intItemUOMId);

            this.HasOptional(p => p.NewItemUOM)
                .WithMany(p => p.NewItemUOMAdjustmentDetails)
                .HasForeignKey(p => p.intNewItemUOMId);

            this.HasOptional(p => p.WeightUOM)
                .WithMany(p => p.OldWeightUOMAdjustmentDetails)
                .HasForeignKey(p => p.intWeightUOMId);
            this.HasOptional(p => p.NewWeightUOM)
                .WithMany(p => p.NewWeightUOMAdjustmentDetails)
                .HasForeignKey(p => p.intNewWeightUOMId);

            this.HasOptional(p => p.NewLotStatus)
                .WithMany(p => p.NewLotStatusAdjustmentDetails)
                .HasForeignKey(p => p.intNewLotStatusId);
        }
    }

    public class tblICInventoryAdjustmentNoteMap : EntityTypeConfiguration<tblICInventoryAdjustmentNote>
    {
        public tblICInventoryAdjustmentNoteMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryAdjustmentNoteId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryAdjustmentNote");
            this.Property(t => t.intInventoryAdjustmentNoteId).HasColumnName("intInventoryAdjustmentNoteId");
            this.Property(t => t.intInventoryAdjustmentId).HasColumnName("intInventoryAdjustmentId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strNotes).HasColumnName("strNotes");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }
}

