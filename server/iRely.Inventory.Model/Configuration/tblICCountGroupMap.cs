using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCountGroupMap : EntityTypeConfiguration<tblICCountGroup>
    {
        public tblICCountGroupMap()
        {
            // Primary Key
            this.HasKey(t => t.intCountGroupId);

            // Table & Column Mappings
            this.ToTable("tblICCountGroup");
            this.Property(t => t.intCountGroupId).HasColumnName("intCountGroupId");
            this.Property(t => t.strCountGroup).HasColumnName("strCountGroup");
            this.Property(t => t.intCountsPerYear).HasColumnName("intCountsPerYear");
            this.Property(t => t.ysnIncludeOnHand).HasColumnName("ysnIncludeOnHand");
            this.Property(t => t.intInventoryType).HasColumnName("intInventoryType");
            this.Property(t => t.ysnScannedCountEntry).HasColumnName("ysnScannedCountEntry");
            this.Property(t => t.ysnCountByLots).HasColumnName("ysnCountByLots");
            this.Property(t => t.ysnCountByPallets).HasColumnName("ysnCountByPallets");
            this.Property(t => t.ysnRecountMismatch).HasColumnName("ysnRecountMismatch");
            this.Property(t => t.ysnExternal).HasColumnName("ysnExternal");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }
}
