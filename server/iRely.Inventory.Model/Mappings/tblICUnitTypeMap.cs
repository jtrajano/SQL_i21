using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICUnitTypeMap : EntityTypeConfiguration<tblICUnitType>
    {
        public tblICUnitTypeMap()
        {
            // Primary Key
            this.HasKey(t => t.intUnitTypeId);

            // Table & Column Mappings
            this.ToTable("tblICUnitType");
            this.Property(t => t.dblDepth).HasColumnName("dblDepth");
            this.Property(t => t.dblHeight).HasColumnName("dblHeight");
            this.Property(t => t.dblMaxWeight).HasColumnName("dblMaxWeight");
            this.Property(t => t.dblWidth).HasColumnName("dblWidth");
            this.Property(t => t.intCapacityUnitMeasureId).HasColumnName("intCapacityUnitMeasureId");
            this.Property(t => t.intDimensionUnitMeasureId).HasColumnName("intDimensionUnitMeasureId");
            this.Property(t => t.intPalletColumn).HasColumnName("intPalletColumn");
            this.Property(t => t.intPalletRow).HasColumnName("intPalletRow");
            this.Property(t => t.intPalletStack).HasColumnName("intPalletStack");
            this.Property(t => t.intUnitTypeId).HasColumnName("intUnitTypeId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strInternalCode).HasColumnName("strInternalCode");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.ysnAllowPick).HasColumnName("ysnAllowPick");

            this.HasRequired(p => p.CapacityUnitMeasures)
                .WithMany(p => p.CapacityUnitTypes)
                .HasForeignKey(p => p.intCapacityUnitMeasureId);
            this.HasRequired(p => p.DimensionUnitMeasures)
                .WithMany(p => p.DimensionUnitTypes)
                .HasForeignKey(p => p.intDimensionUnitMeasureId);
        }
    }
}
