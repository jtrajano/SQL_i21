using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICClassMap : EntityTypeConfiguration<tblICClass>
    {
        public tblICClassMap()
        {
            // Primary Key
            this.HasKey(t => t.intClassId);

            // Table & Column Mappings
            this.ToTable("tblICClass");
            this.Property(t => t.intClassId).HasColumnName("intClassId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strClass).HasColumnName("strClass");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
        }
    }
}
