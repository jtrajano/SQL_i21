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
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strName).HasColumnName("strName");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.intStorageUnitTypeId).HasColumnName("intStorageUnitTypeId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intParentStorageLocationId).HasColumnName("intParentStorageLocationId");
            this.Property(t => t.ysnAllowConsume).HasColumnName("ysnAllowConsume");
            this.Property(t => t.ysnAllowMultipleItem).HasColumnName("ysnAllowMultipleItem");
            this.Property(t => t.ysnAllowMultipleLot).HasColumnName("ysnAllowMultipleLot");
            this.Property(t => t.ysnMergeOnMove).HasColumnName("ysnMergeOnMove");
            this.Property(t => t.ysnCycleCounted).HasColumnName("ysnCycleCounted");
            this.Property(t => t.ysnDefaultWHStagingUnit).HasColumnName("ysnDefaultWHStagingUnit");
            this.Property(t => t.intRestrictionId).HasColumnName("intRestrictionId");
            this.Property(t => t.strUnitGroup).HasColumnName("strUnitGroup");
            this.Property(t => t.dblMinBatchSize).HasColumnName("dblMinBatchSize").HasPrecision(18, 6);
            this.Property(t => t.dblBatchSize).HasColumnName("dblBatchSize").HasPrecision(18, 6);
            this.Property(t => t.intBatchSizeUOMId).HasColumnName("intBatchSizeUOMId");
            this.Property(t => t.intSequence).HasColumnName("intSequence");
            this.Property(t => t.ysnActive).HasColumnName("ysnActive");
            this.Property(t => t.intRelativeX).HasColumnName("intRelativeX");
            this.Property(t => t.intRelativeY).HasColumnName("intRelativeY");
            this.Property(t => t.intRelativeZ).HasColumnName("intRelativeZ");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.dblPackFactor).HasColumnName("dblPackFactor").HasPrecision(18, 6);
            this.Property(t => t.dblEffectiveDepth).HasColumnName("dblEffectiveDepth").HasPrecision(18, 6);
            this.Property(t => t.dblUnitPerFoot).HasColumnName("dblUnitPerFoot").HasPrecision(18, 6);
            this.Property(t => t.dblResidualUnit).HasColumnName("dblResidualUnit").HasPrecision(18, 6);

            this.HasMany(p => p.tblICStorageLocationCategories)
                .WithRequired(p => p.tblICStorageLocation)
                .HasForeignKey(p => p.intStorageLocationId);
            this.HasMany(p => p.tblICStorageLocationMeasurements)
                .WithRequired(p => p.tblICStorageLocation)
                .HasForeignKey(p => p.intStorageLocationId);
            this.HasOptional(p => p.tblSMCompanyLocationSubLocation)
                .WithMany(p => p.tblICStorageLocations)
                .HasForeignKey(p => p.intSubLocationId);
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

            this.HasRequired(p => p.tblICCategory)
                .WithMany(p => p.tblICStorageLocationCategories)
                .HasForeignKey(p => p.intCategoryId);
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

            this.HasRequired(p => p.tblICMeasurement)
                .WithMany(p => p.tblICStorageLocationMeasurements)
                .HasForeignKey(p => p.intMeasurementId);
            this.HasRequired(p => p.tblICReadingPoint)
                .WithMany(p => p.tblICStorageLocationMeasurements)
                .HasForeignKey(p => p.intReadingPointId);
        }
    }

    public class tblICStorageLocationSkuMap : EntityTypeConfiguration<tblICStorageLocationSku>
    {
        public tblICStorageLocationSkuMap()
        {
            // Primary Key
            this.HasKey(t => t.intStorageLocationSkuId);

            // Table & Column Mappings
            this.ToTable("tblICStorageLocationSku");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.intContainerId).HasColumnName("intContainerId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLotCodeId).HasColumnName("intLotCodeId");
            this.Property(t => t.intLotStatusId).HasColumnName("intLotStatusId");
            this.Property(t => t.intOwnerId).HasColumnName("intOwnerId");
            this.Property(t => t.intSkuId).HasColumnName("intSkuId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intStorageLocationSkuId).HasColumnName("intStorageLocationSkuId");

            this.HasRequired(p => p.tblICItem)
                .WithMany(p => p.tblICStorageLocationSkus)
                .HasForeignKey(p => p.intItemId);
            this.HasRequired(p => p.tblICSku)
                .WithMany(p => p.tblICStorageLocationSkus)
                .HasForeignKey(p => p.intSkuId);
            this.HasOptional(p => p.tblICContainer)
                .WithMany(p => p.tblICStorageLocationSkus)
                .HasForeignKey(p => p.intContainerId);
            this.HasOptional(p => p.tblICLotStatus)
                .WithMany(p => p.tblICStorageLocationSkus)
                .HasForeignKey(p => p.intLotStatusId);
        }
    }

    public class tblICStorageLocationContainerMap : EntityTypeConfiguration<tblICStorageLocationContainer>
    {
        public tblICStorageLocationContainerMap()
        {
            // Primary Key
            this.HasKey(t => t.intStorageLocationContainerId);

            // Table & Column Mappings
            this.ToTable("tblICStorageLocationContainer");
            this.Property(t => t.dtmLastUpdatedOn).HasColumnName("dtmLastUpdatedOn");
            this.Property(t => t.intContainerId).HasColumnName("intContainerId");
            this.Property(t => t.intContainerTypeId).HasColumnName("intContainerTypeId");
            this.Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intStorageLocationContainerId).HasColumnName("intStorageLocationContainerId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strLastUpdatedBy).HasColumnName("strLastUpdatedBy");

            this.HasRequired(p => p.tblICContainer)
                .WithMany(p => p.tblICStorageLocationContainers)
                .HasForeignKey(p => p.intContainerId);
            this.HasOptional(p => p.tblICContainerType)
                .WithMany(p => p.tblICStorageLocationContainers)
                .HasForeignKey(p => p.intContainerTypeId);
        }
    }

    class vyuICGetSubLocationBinsMap : EntityTypeConfiguration<vyuICGetSubLocationBins>
    {
        public vyuICGetSubLocationBinsMap()
        {
            this.HasKey(p => p.intSubLocationId);
            this.ToTable("vyuICGetSubLocationBins");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
            this.Property(t => t.strLocation).HasColumnName("strLocation");
            this.Property(t => t.strSubLocation).HasColumnName("strSubLocation");
            this.Property(t => t.dblAvailable).HasColumnName("dblAvailable");
            this.Property(t => t.dblCapacity).HasColumnName("dblCapacity");
            this.Property(t => t.dblEffectiveDepth).HasColumnName("dblEffectiveDepth");
            this.Property(t => t.dblPackFactor).HasColumnName("dblPackFactor");
            this.Property(t => t.dblStock).HasColumnName("dblStock");
            this.Property(t => t.dblUnitPerFoot).HasColumnName("dblUnitPerFoot");
        }
    }

    class vyuICGetSubLocationBinDetailsMap : EntityTypeConfiguration<vyuICGetSubLocationBinDetails>
    {
        public vyuICGetSubLocationBinDetailsMap()
        {
            // Primary Key
            this.HasKey(p => p.intItemLocationId);

            // Table & Column Mappings
            this.ToTable("vyuICGetSubLocationBinDetails");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
            this.Property(t => t.strStorageLocation).HasColumnName("strStorageLocation");
            this.Property(t => t.strUOM).HasColumnName("strUOM");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLocation).HasColumnName("strLocation");
            this.Property(t => t.strDiscountCode).HasColumnName("strDiscountCode");
            this.Property(t => t.strCommodityCode).HasColumnName("strCommodityCode");
            this.Property(t => t.strDiscountDescription).HasColumnName("strDiscountDescription");
            this.Property(t => t.dtmReadingDate).HasColumnName("dtmReadingDate");
            this.Property(t => t.dblCapacity).HasColumnName("dblCapacity").HasPrecision(18, 6);
            this.Property(t => t.dblAirSpaceReading).HasColumnName("dblAirSpaceReading").HasPrecision(18, 6);
            this.Property(t => t.dblPhysicalReading).HasColumnName("dblPhysicalReading").HasPrecision(18, 6);
            this.Property(t => t.dblStockVariance).HasColumnName("dblStockVariance").HasPrecision(18, 6);
            this.Property(t => t.dblAvailable).HasColumnName("dblAvailable").HasPrecision(18, 6);
            this.Property(t => t.dblStock).HasColumnName("dblStock").HasPrecision(18, 6);
            this.Property(t => t.dblEffectiveDepth).HasColumnName("dblEffectiveDepth").HasPrecision(18, 6);
            this.Property(t => t.dblPackFactor).HasColumnName("dblPackFactor").HasPrecision(18, 6);
            this.Property(t => t.dblUnitPerFoot).HasColumnName("dblUnitPerFoot").HasPrecision(18, 6);
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
        }
    }

    class vyuICGetStorageBinsMap : EntityTypeConfiguration<vyuICGetStorageBins>
    {
        public vyuICGetStorageBinsMap()
        {
            // Primary Key
            this.HasKey(p => p.intStorageLocationId);

            // Table & Column Mappings
            this.ToTable("vyuICGetStorageBins");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
            this.Property(t => t.strStorageLocation).HasColumnName("strStorageLocation");
            this.Property(t => t.strLocation).HasColumnName("strLocation");
            this.Property(t => t.dblCapacity).HasColumnName("dblCapacity").HasPrecision(18, 6);
            this.Property(t => t.dblAvailable).HasColumnName("dblAvailable").HasPrecision(18, 6);
            this.Property(t => t.dblStock).HasColumnName("dblStock").HasPrecision(18, 6);
        }
    }

    class vyuICGetStorageBinDetailsMap : EntityTypeConfiguration<vyuICGetStorageBinDetails>
    {
        public vyuICGetStorageBinDetailsMap()
        {
            // Primary Key
            this.HasKey(p => p.intItemLocationId);

            // Table & Column Mappings
            this.ToTable("vyuICGetStorageBinDetails");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
            this.Property(t => t.strStorageLocation).HasColumnName("strStorageLocation");
            this.Property(t => t.strUOM).HasColumnName("strUOM");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLocation).HasColumnName("strLocation");
            this.Property(t => t.strDiscountCode).HasColumnName("strDiscountCode");
            this.Property(t => t.strCommodityCode).HasColumnName("strCommodityCode");
            this.Property(t => t.strDiscountDescription).HasColumnName("strDiscountDescription");
            this.Property(t => t.dtmReadingDate).HasColumnName("dtmReadingDate");
            this.Property(t => t.dblCapacity).HasColumnName("dblCapacity").HasPrecision(18, 6);
            this.Property(t => t.dblAirSpaceReading).HasColumnName("dblAirSpaceReading").HasPrecision(18, 6);
            this.Property(t => t.dblPhysicalReading).HasColumnName("dblPhysicalReading").HasPrecision(18, 6);
            this.Property(t => t.dblStockVariance).HasColumnName("dblStockVariance").HasPrecision(18, 6);
            this.Property(t => t.dblAvailable).HasColumnName("dblAvailable").HasPrecision(18, 6);
            this.Property(t => t.dblStock).HasColumnName("dblStock").HasPrecision(18, 6);
            this.Property(t => t.dblEffectiveDepth).HasColumnName("dblEffectiveDepth").HasPrecision(18, 6);
            this.Property(t => t.dblPackFactor).HasColumnName("dblPackFactor").HasPrecision(18, 6);
            this.Property(t => t.dblUnitPerFoot).HasColumnName("dblUnitPerFoot").HasPrecision(18, 6);
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
        }
    }

    class vyuICGetStorageBinMeasurementReadingMap : EntityTypeConfiguration<vyuICGetStorageBinMeasurementReading>
    {
        public vyuICGetStorageBinMeasurementReadingMap()
        {
            // Primary Key
            this.HasKey(p => p.intItemLocationId);

            // Table & Column Mappings
            this.ToTable("vyuICGetStorageBinMeasurementReading");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
            this.Property(t => t.intCompanyLocationSubLocationId).HasColumnName("intCompanyLocationSubLocationId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strStorageLocation).HasColumnName("strStorageLocation");
            this.Property(t => t.strSubLocation).HasColumnName("strSubLocation");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strLocation).HasColumnName("strLocation");
            this.Property(t => t.strCommodityCode).HasColumnName("strCommodityCode");
            this.Property(t => t.dblEffectiveDepth).HasColumnName("dblEffectiveDepth").HasPrecision(18, 6);
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
        }
    }

    class vyuICGetStorageLocationMap : EntityTypeConfiguration<vyuICGetStorageLocation>
    {
        public vyuICGetStorageLocationMap()
        {
            // Primary Key
            this.HasKey(p => p.intStorageLocationId);

            // Table & Column Mappings
            this.ToTable("vyuICGetStorageLocation");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strName).HasColumnName("strName");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.intStorageUnitTypeId).HasColumnName("intStorageUnitTypeId");
            this.Property(t => t.strStorageUnitType).HasColumnName("strStorageUnitType");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intParentStorageLocationId).HasColumnName("intParentStorageLocationId");
            this.Property(t => t.strParentStorageLocationName).HasColumnName("strParentStorageLocationName");
            this.Property(t => t.ysnAllowConsume).HasColumnName("ysnAllowConsume");
            this.Property(t => t.ysnAllowMultipleItem).HasColumnName("ysnAllowMultipleItem");
            this.Property(t => t.ysnAllowMultipleLot).HasColumnName("ysnAllowMultipleLot");
            this.Property(t => t.ysnMergeOnMove).HasColumnName("ysnMergeOnMove");
            this.Property(t => t.ysnCycleCounted).HasColumnName("ysnCycleCounted");
            this.Property(t => t.ysnDefaultWHStagingUnit).HasColumnName("ysnDefaultWHStagingUnit");
            this.Property(t => t.intRestrictionId).HasColumnName("intRestrictionId");
            this.Property(t => t.strRestrictionCode).HasColumnName("strRestrictionCode");
            this.Property(t => t.strRestrictionDesc).HasColumnName("strRestrictionDesc");
            this.Property(t => t.strUnitGroup).HasColumnName("strUnitGroup");
            this.Property(t => t.dblMinBatchSize).HasColumnName("dblMinBatchSize").HasPrecision(18, 6);
            this.Property(t => t.dblBatchSize).HasColumnName("dblBatchSize").HasPrecision(18, 6);
            this.Property(t => t.intBatchSizeUOMId).HasColumnName("intBatchSizeUOMId");
            this.Property(t => t.intSequence).HasColumnName("intSequence");
            this.Property(t => t.ysnActive).HasColumnName("ysnActive");
            this.Property(t => t.intRelativeX).HasColumnName("intRelativeX");
            this.Property(t => t.intRelativeY).HasColumnName("intRelativeY");
            this.Property(t => t.intRelativeZ).HasColumnName("intRelativeZ");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.dblPackFactor).HasColumnName("dblPackFactor").HasPrecision(18, 6);
            this.Property(t => t.dblEffectiveDepth).HasColumnName("dblEffectiveDepth").HasPrecision(18, 6);
            this.Property(t => t.dblUnitPerFoot).HasColumnName("dblUnitPerFoot").HasPrecision(18, 6);
            this.Property(t => t.dblResidualUnit).HasColumnName("dblResidualUnit").HasPrecision(18, 6);
            this.Property(t => t.dblUnitPerFoot).HasColumnName("dblUnitPerFoot").HasPrecision(18, 6);
        }
    }
}
