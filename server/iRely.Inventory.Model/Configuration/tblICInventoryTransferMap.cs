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
            this.Property(t => t.intStatusId).HasColumnName("intStatusId");
            this.Property(t => t.intShipViaId).HasColumnName("intShipViaId");
            this.Property(t => t.intFreightUOMId).HasColumnName("intFreightUOMId");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.intCreatedUserId).HasColumnName("intCreatedUserId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasRequired(p => p.tblICStatus)
                .WithMany(p => p.tblICInventoryTransfers)
                .HasForeignKey(p => p.intStatusId);
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
            this.Property(t => t.intNewLotId).HasColumnName("intNewLotId");
            this.Property(t => t.strNewLotId).HasColumnName("strNewLotId");
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(18, 6);
            this.Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            this.Property(t => t.dblFreightRate).HasColumnName("dblFreightRate").HasPrecision(18, 6);
            this.Property(t => t.dblFreightAmount).HasColumnName("dblFreightAmount").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.vyuICGetInventoryTransferDetail)
                .WithRequired(p => p.tblICInventoryTransferDetail);
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

    public class vyuICGetInventoryTransferDetailMap : EntityTypeConfiguration<vyuICGetInventoryTransferDetail>
    {
        public vyuICGetInventoryTransferDetailMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryTransferDetailId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryTransferDetailStock");
            this.Property(t => t.intInventoryTransferDetailId).HasColumnName("intInventoryTransferDetailId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.strFromSubLocationName).HasColumnName("strFromSubLocationName");
            this.Property(t => t.strToSubLocationName).HasColumnName("strToSubLocationName");
            this.Property(t => t.strFromStorageLocationName).HasColumnName("strFromStorageLocationName");
            this.Property(t => t.strToStorageLocationName).HasColumnName("strToStorageLocationName");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strWeightUOM).HasColumnName("strWeightUOM");
            this.Property(t => t.strTaxCode).HasColumnName("strTaxCode");
            this.Property(t => t.strAvailableUOM).HasColumnName("strAvailableUOM");
            this.Property(t => t.dblOnHand).HasColumnName("dblOnHand").HasPrecision(18, 6);
            this.Property(t => t.dblOnOrder).HasColumnName("dblOnOrder").HasPrecision(18, 6);
            this.Property(t => t.dblReservedQty).HasColumnName("dblReservedQty").HasPrecision(18, 6);
            this.Property(t => t.dblAvailableQty).HasColumnName("dblAvailableQty").HasPrecision(18, 6);
        }
    }
}
