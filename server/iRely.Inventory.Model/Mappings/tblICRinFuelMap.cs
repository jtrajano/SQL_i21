using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICRinFuelMap : EntityTypeConfiguration<tblICRinFuel>
    {
        public tblICRinFuelMap()
        {
            // Primary Key
            this.HasKey(t => t.intRinFuelId);

            // Table & Column Mappings
            this.ToTable("tblICRinFuel");
            this.Property(t => t.intRinFuelId).HasColumnName("intRinFuelId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strRinFuelCode).HasColumnName("strRinFuelCode");
        }
    }
}
