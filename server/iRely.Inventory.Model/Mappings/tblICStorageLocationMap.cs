using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICStorageLocationMap : EntityTypeConfiguration<tblICStorageLocation>
    {
        public tblICStorageLocationMap()
        {
            // Primary Key
            this.HasKey(t => t.intStorageLocationId);

            // Table & Column Mappings
            this.ToTable("tblICStorageLocation");
            this.Property(t => t.dblBatchSize).HasColumnName("dblBatchSize");
            this.Property(t => t.dblMinBatchSize).HasColumnName("dblMinBatchSize");
            this.Property(t => t.dblPackFactor).HasColumnName("dblPackFactor");
            this.Property(t => t.dblResidualUnit).HasColumnName("dblResidualUnit");
            this.Property(t => t.dblUnitPerFoot).HasColumnName("dblUnitPerFoot");
            this.Property(t => t.intBatchSizeUOMId).HasColumnName("intBatchSizeUOMId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intParentStorageLocationId).HasColumnName("intParentStorageLocationId");
            this.Property(t => t.intRelativeX).HasColumnName("intRelativeX");
            this.Property(t => t.intRelativeY).HasColumnName("intRelativeY");
            this.Property(t => t.intRelativeZ).HasColumnName("intRelativeZ");
            this.Property(t => t.intRestrictionId).HasColumnName("intRestrictionId");
            this.Property(t => t.intSequence).HasColumnName("intSequence");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intStorageUnitTypeId).HasColumnName("intStorageUnitTypeId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strName).HasColumnName("strName");
            this.Property(t => t.strUnitGroup).HasColumnName("strUnitGroup");
            this.Property(t => t.ysnActive).HasColumnName("ysnActive");
            this.Property(t => t.ysnAllowConsume).HasColumnName("ysnAllowConsume");
            this.Property(t => t.ysnAllowMultipleItem).HasColumnName("ysnAllowMultipleItem");
            this.Property(t => t.ysnAllowMultipleLot).HasColumnName("ysnAllowMultipleLot");
            this.Property(t => t.ysnCycleCounted).HasColumnName("ysnCycleCounted");
            this.Property(t => t.ysnDefaultWHStagingUnit).HasColumnName("ysnDefaultWHStagingUnit");
            this.Property(t => t.ysnMergeOnMove).HasColumnName("ysnMergeOnMove");
        }
    }

    public class tblICStorageLocationCategoryMap : EntityTypeConfiguration<tblICStorageLocationCategory>
    {
        public tblICStorageLocationCategoryMap()
        {
            // Primary Key
            this.HasKey(t => t.intStorageLocationCategoryId);

            // Table & Column Mappings
            this.ToTable("tblICStorageLocationCategory");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intStorageLocationCategoryId).HasColumnName("intStorageLocationCategoryId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
        }
    }

    public class tblICStorageLocationMeasurementMap : EntityTypeConfiguration<tblICStorageLocationMeasurement>
    {
        public tblICStorageLocationMeasurementMap()
        {
            // Primary Key
            this.HasKey(t => t.intStorageLocationMeasurementId);

            // Table & Column Mappings
            this.ToTable("tblICStorageLocationMeasurement");
            this.Property(t => t.intMeasurementId).HasColumnName("intMeasurementId");
            this.Property(t => t.intReadingPointId).HasColumnName("intReadingPointId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intStorageLocationMeasurementId).HasColumnName("intStorageLocationMeasurementId");
            this.Property(t => t.ysnActive).HasColumnName("ysnActive");
        }
    }
}
