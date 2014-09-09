using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICUnitMeasureMap : EntityTypeConfiguration<tblICUnitMeasure>
    {
        public tblICUnitMeasureMap()
        {
            // Primary Key
            this.HasKey(t => t.intUnitMeasureId);

            // Table & Column Mappings
            this.ToTable("tblICUnitMeasure");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strSymbol).HasColumnName("strSymbol");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");
        }
    }
}
