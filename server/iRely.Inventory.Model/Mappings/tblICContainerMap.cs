using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICContainerMap : EntityTypeConfiguration<tblICContainer>
    {
        public tblICContainerMap()
        {
            // Primary Key
            this.HasKey(t => t.intContainerId);

            // Table & Column Mappings
            this.ToTable("tblICContainer");
            this.Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            this.Property(t => t.intContainerId).HasColumnName("intContainerId");
            this.Property(t => t.intContainerTypeId).HasColumnName("intContainerTypeId");
            this.Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strContainerId).HasColumnName("strContainerId");
            this.Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
        }
    }
}
