using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICManufacturingCellMap: EntityTypeConfiguration<tblICManufacturingCell>
    {
        public tblICManufacturingCellMap()
        {
            // Primary Key
            this.HasKey(t => t.intManufacturingCellId);

            // Table & Column Mappings
            this.ToTable("tblICManufacturingCell");
            this.Property(t => t.dblStdCapacity).HasColumnName("dblStdCapacity").HasPrecision(18, 6);
            this.Property(t => t.dblStdLineEfficiency).HasColumnName("dblStdLineEfficiency").HasPrecision(18, 6);
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intManufacturingCellId).HasColumnName("intManufacturingCellId");
            this.Property(t => t.intStdCapacityRateId).HasColumnName("intStdCapacityRateId");
            this.Property(t => t.intStdUnitMeasureId).HasColumnName("intStdUnitMeasureId");
            this.Property(t => t.strCellName).HasColumnName("strCellName");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.ysnActive).HasColumnName("ysnActive");
            this.Property(t => t.ysnIncludeSchedule).HasColumnName("ysnIncludeSchedule");

            this.HasMany(p => p.tblICManufacturingCellPackTypes)
                .WithRequired(p => p.tblICManufacturingCell)
                .HasForeignKey(p => p.intManufacturingCellId);
            this.HasOptional(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICManufacturingCells)
                .HasForeignKey(p => p.intLocationId);
            this.HasOptional(p => p.CapacityUnitMeasure)
                .WithMany(p => p.CapacityManufacturingCells)
                .HasForeignKey(p => p.intStdUnitMeasureId);
            this.HasOptional(p => p.CapacityRateUnitMeasure)
                .WithMany(p => p.CapacityRateManufacturingCells)
                .HasForeignKey(p => p.intStdCapacityRateId);
        }
    }

    public class tblICManufacturingCellPackTypeMap : EntityTypeConfiguration<tblICManufacturingCellPackType>
    {
        public tblICManufacturingCellPackTypeMap()
        {
            // Primary Key
            this.HasKey(t => t.intManufacturingCellPackTypeId);

            // Table & Column Mappings
            this.ToTable("tblICManufacturingCellPackType");
            this.Property(t => t.dblLineCapacity).HasColumnName("dblLineCapacity").HasPrecision(18, 6);
            this.Property(t => t.dblLineEfficiencyRate).HasColumnName("dblLineEfficiencyRate").HasPrecision(18, 6);
            this.Property(t => t.intLineCapacityRateUnitMeasureId).HasColumnName("intLineCapacityRateUnitMeasureId");
            this.Property(t => t.intLineCapacityUnitMeasureId).HasColumnName("intLineCapacityUnitMeasureId");
            this.Property(t => t.intManufacturingCellId).HasColumnName("intManufacturingCellId");
            this.Property(t => t.intManufacturingCellPackTypeId).HasColumnName("intManufacturingCellPackTypeId");
            this.Property(t => t.intPackTypeId).HasColumnName("intPackTypeId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICPackType)
                .WithMany(p => p.tblICManufacturingCellPackTypes)
                .HasForeignKey(p => p.intPackTypeId);
            this.HasOptional(p => p.CapacityUnitMeasure)
                .WithMany(p => p.CapacityManufacturingCellPackTypes)
                .HasForeignKey(p => p.intLineCapacityUnitMeasureId);
            this.HasOptional(p => p.CapacityRateUnitMeasure)
                .WithMany(p => p.CapacityRateManufacturingCellPackTypes)
                .HasForeignKey(p => p.intLineCapacityRateUnitMeasureId);
        }
    }
}
