using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICFamilyMap : EntityTypeConfiguration<tblICFamily>
    {
        public tblICFamilyMap()
        {
            // Primary Key
            this.HasKey(t => t.intFamilyId);

            // Table & Column Mappings
            this.ToTable("tblICFamily");
            this.Property(t => t.intFamilyId).HasColumnName("intFamilyId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDesciption).HasColumnName("strDesciption");
            this.Property(t => t.strFamily).HasColumnName("strFamily");
        }
    }
}
