using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICParentLotMap : EntityTypeConfiguration<tblICParentLot>
    {
        public tblICParentLotMap()
        {
            // Primary Key
            this.HasKey(p => p.intParentLotId);

            // Table & Column Mappings
            this.ToTable("tblICParentLot");
            this.Property(t => t.intParentLotId).HasColumnName("intParentLotId");
            this.Property(t => t.strParentLotNumber).HasColumnName("strParentLotNumber");
            this.Property(t => t.strParentLotAlias).HasColumnName("strParentLotAlias");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.dtmExpiryDate).HasColumnName("dtmExpiryDate");
            this.Property(t => t.intLotStatusId).HasColumnName("intLotStatusId");
            this.Property(t => t.dtmDateCreated).HasColumnName("dtmDateCreated");
            this.Property(t => t.intCreatedUserId).HasColumnName("intCreatedUserId");
            this.Property(t => t.intCreatedEntityId).HasColumnName("intCreatedEntityId");
        }
    }
}
