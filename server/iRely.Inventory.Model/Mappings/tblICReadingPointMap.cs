using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICReadingPointMap : EntityTypeConfiguration<tblICReadingPoint>
    {
        public tblICReadingPointMap()
        {
            // Primary Key
            this.HasKey(t => t.intReadingPointId);

            // Table & Column Mappings
            this.ToTable("tblICReadingPoint");
            this.Property(t => t.intReadingPointId).HasColumnName("intReadingPointId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strReadingPoint).HasColumnName("strReadingPoint");
        }
    }
}
