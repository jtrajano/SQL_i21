using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemCertificationMap : EntityTypeConfiguration<tblICItemCertification>
    {
        public tblICItemCertificationMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemCertificationId);

            // Table & Column Mappings
            this.ToTable("tblICItemCertification");
            this.Property(t => t.intCertificationId).HasColumnName("intCertificationId");
            this.Property(t => t.intItemCertificationId).HasColumnName("intItemCertificationId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasRequired(p => p.tblICCertification)
                .WithMany(p => p.tblICItemCertifications)
                .HasForeignKey(p => p.intCertificationId);
        }
    }
}
