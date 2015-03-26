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
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.intNewLotId).HasColumnName("intNewLotId");
            this.Property(t => t.dblNewQuantity).HasColumnName("dblNewQuantity").HasPrecision(18, 6);
            this.Property(t => t.intNewItemUOMId).HasColumnName("intNewItemUOMId");
            this.Property(t => t.intNewItemId).HasColumnName("intNewItemId");
            this.Property(t => t.dblNewPhysicalCount).HasColumnName("dblNewPhysicalCount").HasPrecision(18, 6);
            this.Property(t => t.dtmNewExpiryDate).HasColumnName("dtmNewExpiryDate");
            this.Property(t => t.intNewLotStatusId).HasColumnName("intNewLotStatusId");
            this.Property(t => t.intAccountCategoryId).HasColumnName("intAccountCategoryId");
            this.Property(t => t.intCreditAccountId).HasColumnName("intCreditAccountId");
            this.Property(t => t.intDebitAccountId).HasColumnName("intDebitAccountId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICItem)
                .WithMany(p => p.tblICInventoryAdjustmentDetails)
                .HasForeignKey(p => p.intItemId);
            this.HasOptional(p => p.NewItem)
                .WithMany(p => p.NewAdjustmentDetails)
                .HasForeignKey(p => p.intNewItemId);
            this.HasOptional(p => p.tblSMCompanyLocationSubLocation)
                .WithMany(p => p.tblICInventoryAdjustmentDetails)
                .HasForeignKey(p => p.intSubLocationId);
            this.HasOptional(p => p.tblICStorageLocation)
                .WithMany(p => p.tblICInventoryAdjustmentDetails)
                .HasForeignKey(p => p.intStorageLocationId);
            this.HasOptional(p => p.tblICLot)
                .WithMany(p => p.tblICInventoryAdjustmentDetails)
                .HasForeignKey(p => p.intLotId);
            this.HasOptional(p => p.NewLot)
                .WithMany(p => p.NewAdjustmentDetails)
                .HasForeignKey(p => p.intNewLotId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICInventoryAdjustmentDetails)
                .HasForeignKey(p => p.intNewItemUOMId);
            this.HasOptional(p => p.tblICLotStatus)
                .WithMany(p => p.tblICInventoryAdjustmentDetails)
                .HasForeignKey(p => p.intNewLotStatusId);
            this.HasOptional(p => p.tblGLAccountCategory)
                .WithMany(p => p.tblICInventoryAdjustmentDetails)
                .HasForeignKey(p => p.intAccountCategoryId);
            this.HasOptional(p => p.DebitAccount)
                .WithMany(p => p.DebitAdjustmentDetails)
                .HasForeignKey(p => p.intDebitAccountId);
            this.HasOptional(p => p.CreditAccount)
                .WithMany(p => p.CreditAdjustmentDetails)
                .HasForeignKey(p => p.intCreditAccountId);
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
