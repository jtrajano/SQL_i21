using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICMeasurementMap : EntityTypeConfiguration<tblICMeasurement>
    {
        public tblICMeasurementMap()
        {
            // Primary Key
            this.HasKey(t => t.intMeasurementId);

            // Table & Column Mappings
            this.ToTable("tblICMeasurement");
            this.Property(t => t.intMeasurementId).HasColumnName("intMeasurementId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strMeasurementName).HasColumnName("strMeasurementName");
            this.Property(t => t.strMeasurementType).HasColumnName("strMeasurementType");
        }
    }
}
