using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class vyuICLotHistoryMap : EntityTypeConfiguration<vyuICLotHistory>
    {
        public vyuICLotHistoryMap()
        {
            // Primary Key
            this.HasKey(t => t.intLotId);


            // Table & Column Mappings
            this.ToTable("vyuICLotHistory");

            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.strParentLotNumber).HasColumnName("strParentLotNumber");
            this.Property(t => t.strLotUOM).HasColumnName("strLotUOM");
            this.Property(t => t.dblWeightPerQty).HasColumnName("dblWeightPerQty");
            this.Property(t => t.dtmExpiryDate).HasColumnName("dtmExpiryDate");
            this.Property(t => t.strEntityName).HasColumnName("strEntityName");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.strTransactionType).HasColumnName("strTransactionType");
            this.Property(t => t.intTransactionId).HasColumnName("intTransactionId");
            this.Property(t => t.strTransactionId).HasColumnName("strTransactionId");
            this.Property(t => t.dtmDate).HasColumnName("dtmDate");
            this.Property(t => t.dblQty).HasColumnName("dblQty").HasPrecision(38, 20); ;
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(38, 20); ;
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(38, 20); ;
            this.Property(t => t.dblWeight).HasColumnName("dblWeight").HasPrecision(38, 20); ;
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
        }
    }
}