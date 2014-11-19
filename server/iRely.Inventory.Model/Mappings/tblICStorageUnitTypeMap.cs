using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICStorageUnitTypeMap : EntityTypeConfiguration<tblICStorageUnitType>
    {
        public tblICStorageUnitTypeMap()
        {
            // Primary Key
            this.HasKey(t => t.intStorageUnitTypeId);

            // Table & Column Mappings
            this.ToTable("tblICStorageUnitType");
            this.Property(t => t.dblDepth).HasColumnName("dblDepth");
            this.Property(t => t.dblHeight).HasColumnName("dblHeight");
            this.Property(t => t.dblMaxWeight).HasColumnName("dblMaxWeight");
            this.Property(t => t.dblWidth).HasColumnName("dblWidth");
            this.Property(t => t.intCapacityUnitMeasureId).HasColumnName("intCapacityUnitMeasureId");
            this.Property(t => t.intDimensionUnitMeasureId).HasColumnName("intDimensionUnitMeasureId");
            this.Property(t => t.intPalletColumn).HasColumnName("intPalletColumn");
            this.Property(t => t.intPalletRow).HasColumnName("intPalletRow");
            this.Property(t => t.intPalletStack).HasColumnName("intPalletStack");
            this.Property(t => t.intStorageUnitTypeId).HasColumnName("intStorageUnitTypeId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strInternalCode).HasColumnName("strInternalCode");
            this.Property(t => t.strStorageUnitType).HasColumnName("strStorageUnitType");
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
