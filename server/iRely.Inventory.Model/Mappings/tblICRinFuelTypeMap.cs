using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICRinFuelTypeMap : EntityTypeConfiguration<tblICRinFuelType>
    {
        public tblICRinFuelTypeMap()
        {
            // Primary Key
            this.HasKey(t => t.intRinFuelTypeId);

            // Table & Column Mappings
            this.ToTable("tblICRinFuelType");
            this.Property(t => t.dblEquivalenceValue).HasColumnName("dblEquivalenceValue");
            this.Property(t => t.intRinFuelTypeId).HasColumnName("intRinFuelTypeId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strRinFuelTypeCode).HasColumnName("strRinFuelTypeCode");
        }
    }
}
