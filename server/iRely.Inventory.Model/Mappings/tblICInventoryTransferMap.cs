using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICInventoryTransferMap : EntityTypeConfiguration<tblICInventoryTransfer>
    {
        public tblICInventoryTransferMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryTransferId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryTransfer");
            this.Property(t => t.intInventoryTransferId).HasColumnName("intInventoryTransferId");
            this.Property(t => t.strTransferNo).HasColumnName("strTransferNo");
            this.Property(t => t.dtmTransferDate).HasColumnName("dtmTransferDate");
            this.Property(t => t.strTransferType).HasColumnName("strTransferType");
            this.Property(t => t.intTransferredById).HasColumnName("intTransferredById");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.intFromLocationId).HasColumnName("intFromLocationId");
            this.Property(t => t.intToLocationId).HasColumnName("intToLocationId");
            this.Property(t => t.ysnShipmentRequired).HasColumnName("ysnShipmentRequired");
            this.Property(t => t.intShipViaId).HasColumnName("intShipViaId");
            this.Property(t => t.intFreightUOMId).HasColumnName("intFreightUOMId");
            this.Property(t => t.intAccountCategoryId).HasColumnName("intAccountCategoryId");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasMany(p => p.tblICInventoryTransferDetails)
                .WithRequired(p => p.tblICInventoryTransfer)
                .HasForeignKey(p => p.intInventoryTransferId);
            this.HasMany(p => p.tblICInventoryTransferNotes)
                .WithRequired(p => p.tblICInventoryTransfer)
                .HasForeignKey(p => p.intInventoryTransferId);
            this.HasOptional(p => p.FromLocation)
                .WithMany(p => p.FromInventoryTransfers)
                .HasForeignKey(p => p.intFromLocationId);
            this.HasOptional(p => p.ToLocation)
                .WithMany(p => p.ToInventoryTransfers)
                .HasForeignKey(p => p.intToLocationId);
        }
    }

    public class tblICInventoryTransferDetailMap : EntityTypeConfiguration<tblICInventoryTransferDetail>
    {
        public tblICInventoryTransferDetailMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryTransferDetailId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryTransferDetail");
            this.Property(t => t.intInventoryTransferDetailId).HasColumnName("intInventoryTransferDetailId");
            this.Property(t => t.intInventoryTransferId).HasColumnName("intInventoryTransferId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.intFromSubLocationId).HasColumnName("intFromSubLocationId");
            this.Property(t => t.intToSubLocationId).HasColumnName("intToSubLocationId");
            this.Property(t => t.intFromStorageLocationId).HasColumnName("intFromStorageLocationId");
            this.Property(t => t.intToStorageLocationId).HasColumnName("intToStorageLocationId");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intItemWeightUOMId).HasColumnName("intItemWeightUOMId");
            this.Property(t => t.dblGrossWeight).HasColumnName("dblGrossWeight").HasPrecision(18, 6);
            this.Property(t => t.dblTareWeight).HasColumnName("dblTareWeight").HasPrecision(18, 6);
            this.Property(t => t.dblNetWeight).HasColumnName("dblNetWeight").HasPrecision(18, 6);
            this.Property(t => t.intNewLotId).HasColumnName("intNewLotId");
            this.Property(t => t.strNewLotId).HasColumnName("strNewLotId");
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(18, 6);
            this.Property(t => t.intCreditAccountId).HasColumnName("intCreditAccountId");
            this.Property(t => t.intDebitAccountId).HasColumnName("intDebitAccountId");
            this.Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            this.Property(t => t.dblFreightRate).HasColumnName("dblFreightRate").HasPrecision(18, 6);
            this.Property(t => t.dblFreightAmount).HasColumnName("dblFreightAmount").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICItem)
                .WithMany(p => p.tblICInventoryTransferDetails)
                .HasForeignKey(p => p.intItemId);
            this.HasOptional(p => p.tblICLot)
                .WithMany(p => p.tblICInventoryTransferDetails)
                .HasForeignKey(p => p.intLotId);
            this.HasOptional(p => p.NewLot)
                .WithMany(p => p.NewTransferDetails)
                .HasForeignKey(p => p.intNewLotId);
            this.HasOptional(p => p.FromSubLocation)
                .WithMany(p => p.FromTransferDetails)
                .HasForeignKey(p => p.intFromSubLocationId);
            this.HasOptional(p => p.ToSubLocation)
                .WithMany(p => p.ToTransferDetails)
                .HasForeignKey(p => p.intToSubLocationId);
            this.HasOptional(p => p.FromStorageLocation)
                .WithMany(p => p.FromTransferDetails)
                .HasForeignKey(p => p.intFromStorageLocationId);
            this.HasOptional(p => p.ToStorageLocation)
                .WithMany(p => p.ToTransferDetails)
                .HasForeignKey(p => p.intToStorageLocationId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICInventoryTransferDetails)
                .HasForeignKey(p => p.intItemUOMId);
            this.HasOptional(p => p.WeightUOM)
                .WithMany(p => p.WeightTransferDetails)
                .HasForeignKey(p => p.intItemWeightUOMId);
            this.HasOptional(p => p.CreditAccount)
                .WithMany(p => p.CreditTransferDetails)
                .HasForeignKey(p => p.intCreditAccountId);
            this.HasOptional(p => p.DebitAccount)
                .WithMany(p => p.DebitTransferDetails)
                .HasForeignKey(p => p.intDebitAccountId);
            this.HasOptional(p => p.tblSMTaxCode)
                .WithMany(p => p.tblICInventoryTransferDetails)
                .HasForeignKey(p => p.intTaxCodeId);
        }
    }

    public class tblICInventoryTransferNoteMap : EntityTypeConfiguration<tblICInventoryTransferNote>
    {
        public tblICInventoryTransferNoteMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryTransferNoteId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryTransferNote");
            this.Property(t => t.intInventoryTransferNoteId).HasColumnName("intInventoryTransferNoteId");
            this.Property(t => t.intInventoryTransferId).HasColumnName("intInventoryTransferId");
            this.Property(t => t.strNoteType).HasColumnName("strNoteType");
            this.Property(t => t.strNotes).HasColumnName("strNotes");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }
}
