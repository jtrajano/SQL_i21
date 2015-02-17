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
            this.Property(t => t.intDecimalCalculation).HasColumnName("intDecimalCalculation");
            this.Property(t => t.intDecimalDisplay).HasColumnName("intDecimalDisplay");

            this.HasMany(p => p.tblICUnitMeasureConversions)
                .WithRequired(p => p.tblICUnitMeasure)
                .HasForeignKey(p => p.intUnitMeasureId);
            this.HasMany(p => p.ConversionFactors)
               .WithRequired(p => p.ConversionTo)
               .HasForeignKey(p => p.intStockUnitMeasureId);
        }
    }

    public class tblICUnitMeasureConversionMap : EntityTypeConfiguration<tblICUnitMeasureConversion>
    {
        public tblICUnitMeasureConversionMap()
        {
            // Primary Key
            this.HasKey(t => t.intUnitMeasureConversionId);

            // Table & Column Mappings
            this.ToTable("tblICUnitMeasureConversion");
            this.Property(t => t.intUnitMeasureConversionId).HasColumnName("intUnitMeasureConversionId");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.intStockUnitMeasureId).HasColumnName("intStockUnitMeasureId");
            this.Property(t => t.dblConversionToStock).HasColumnName("dblConversionToStock");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasRequired(p => p.StockUnitMeasure)
                .WithMany(p => p.StockUnitMeasureConversions)
                .HasForeignKey(p => p.intStockUnitMeasureId);
        }
    }

    public class vyuICGetPackedUOMMap : EntityTypeConfiguration<vyuICGetPackedUOM>
    {
        public vyuICGetPackedUOMMap()
        {
            // Primary Key
            this.HasKey(p => p.intUnitMeasureConversionId);

            // Table & Column Mappings
            this.ToTable("vyuICGetPackedUOM");
            this.Property(t => t.intUnitMeasureConversionId).HasColumnName("intUnitMeasureConversionId");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.strSymbol).HasColumnName("strSymbol");
            this.Property(t => t.intStockUnitMeasureId).HasColumnName("intStockUnitMeasureId");
            this.Property(t => t.strConversionUOM).HasColumnName("strConversionUOM");
            this.Property(t => t.dblConversionToStock).HasColumnName("dblConversionToStock");
        }
    }
}
