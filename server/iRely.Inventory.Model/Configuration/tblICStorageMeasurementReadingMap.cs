using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICStorageMeasurementReadingMap: EntityTypeConfiguration<tblICStorageMeasurementReading>
    {
        public tblICStorageMeasurementReadingMap()
        {
            // Primary Key
            this.HasKey(t => t.intStorageMeasurementReadingId);

            // Table & Column Mappings
            this.ToTable("tblICStorageMeasurementReading");
            this.Property(t => t.intStorageMeasurementReadingId).HasColumnName("intStorageMeasurementReadingId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.dtmDate).HasColumnName("dtmDate");
            this.Property(t => t.strReadingNo).HasColumnName("strReadingNo");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICStorageMeasurementReadings)
                .HasForeignKey(p => p.intLocationId);

            this.HasMany(p => p.tblICStorageMeasurementReadingConversions)
                .WithRequired(p => p.tblICStorageMeasurementReading)
                .HasForeignKey(p => p.intStorageMeasurementReadingId);
        }
    }

    public class tblICStorageMeasurementReadingConversionMap : EntityTypeConfiguration<tblICStorageMeasurementReadingConversion>
    {
        public tblICStorageMeasurementReadingConversionMap()
        {
            // Primary Key
            this.HasKey(t => t.intStorageMeasurementReadingConversionId);

            // Table & Column Mappings
            this.ToTable("tblICStorageMeasurementReadingConversion");
            this.Property(t => t.intStorageMeasurementReadingConversionId).HasColumnName("intStorageMeasurementReadingConversionId");
            this.Property(t => t.intStorageMeasurementReadingId).HasColumnName("intStorageMeasurementReadingId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.dblAirSpaceReading).HasColumnName("dblAirSpaceReading").HasPrecision(18, 6);
            this.Property(t => t.dblCashPrice).HasColumnName("dblCashPrice").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.vyuICGetStorageMeasurementReadingConversion)
                .WithRequired(p => p.tblICStorageMeasurementReadingConversion);
        }
    }

    public class vyuICGetStorageMeasurementReadingConversionMap : EntityTypeConfiguration<vyuICGetStorageMeasurementReadingConversion>
    {
        public vyuICGetStorageMeasurementReadingConversionMap()
        {
            // Primary Key
            this.HasKey(t => t.intStorageMeasurementReadingConversionId);

            // Table & Column Mappings
            this.ToTable("vyuICGetStorageMeasurementReadingConversion");
            this.Property(t => t.intStorageMeasurementReadingConversionId).HasColumnName("intStorageMeasurementReadingConversionId");
            this.Property(t => t.intStorageMeasurementReadingId).HasColumnName("intStorageMeasurementReadingId");
            this.Property(t => t.strReadingNo).HasColumnName("strReadingNo");
            this.Property(t => t.dtmDate).HasColumnName("dtmDate");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strCommodity).HasColumnName("strCommodity");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.dblEffectiveDepth).HasColumnName("dblEffectiveDepth").HasPrecision(18, 6);
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.dblAirSpaceReading).HasColumnName("dblAirSpaceReading").HasPrecision(18, 6);
            this.Property(t => t.dblCashPrice).HasColumnName("dblCashPrice").HasPrecision(18, 6);
        }
    }
}
