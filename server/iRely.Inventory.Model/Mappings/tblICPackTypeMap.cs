using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICPackTypeMap: EntityTypeConfiguration<tblICPackType>
    {
        public tblICPackTypeMap()
        {
            // Primary Key
            this.HasKey(t => t.intPackTypeId);

            // Table & Column Mappings
            this.ToTable("tblICPackType");
            this.Property(t => t.intPackTypeId).HasColumnName("intPackTypeId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strPackName).HasColumnName("strPackName");

            this.HasMany(p => p.tblICPackTypeDetails)
                .WithRequired(p => p.tblICPackType)
                .HasForeignKey(p => p.intPackTypeId);
        }
    }

    public class tblICPackTypeDetailMap : EntityTypeConfiguration<tblICPackTypeDetail>
    {
        public tblICPackTypeDetailMap()
        {
            // Primary Key
            this.HasKey(t => t.intPackTypeDetailId);

            // Table & Column Mappings
            this.ToTable("tblICPackTypeDetail");
            this.Property(t => t.dblConversionFactor).HasColumnName("dblConversionFactor");
            this.Property(t => t.intPackTypeDetailId).HasColumnName("intPackTypeDetailId");
            this.Property(t => t.intPackTypeId).HasColumnName("intPackTypeId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intSourceUnitMeasureId).HasColumnName("intSourceUnitMeasureId");
            this.Property(t => t.intTargetUnitMeasureId).HasColumnName("intTargetUnitMeasureId");

            this.HasRequired(p => p.SourceUnitMeasure)
                .WithMany(p => p.SourcePackTypeDetails)
                .HasForeignKey(p => p.intSourceUnitMeasureId);
            this.HasRequired(p => p.TargetUnitMeasure)
                .WithMany(p => p.TargetPackTypeDetails)
                .HasForeignKey(p => p.intTargetUnitMeasureId);
        }
    }
}
