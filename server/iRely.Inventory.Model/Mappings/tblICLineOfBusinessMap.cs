using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICLineOfBusinessMap: EntityTypeConfiguration<tblICLineOfBusiness>
    {
        public tblICLineOfBusinessMap()
        {
            // Primary Key
            this.HasKey(t => t.intLineOfBusinessId);

            // Table & Column Mappings
            this.ToTable("tblICLineOfBusiness");
            this.Property(t => t.intLineOfBusinessId).HasColumnName("intLineOfBusinessId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strLineOfBusiness).HasColumnName("strLineOfBusiness");
        }
    }
}
