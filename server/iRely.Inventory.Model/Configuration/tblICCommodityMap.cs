using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCommodityMap : EntityTypeConfiguration<tblICCommodity>
    {
        public tblICCommodityMap()
        {
            // Primary Key
            this.HasKey(t => t.intCommodityId);

            // Table & Column Mappings
            this.ToTable("tblICCommodity");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strCommodityCode).HasColumnName("strCommodityCode");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.ysnExchangeTraded).HasColumnName("ysnExchangeTraded");
            this.Property(t => t.intFutureMarketId).HasColumnName("intFutureMarketId");
            this.Property(t => t.intDecimalDPR).HasColumnName("intDecimalDPR");
            this.Property(t => t.dblConsolidateFactor).HasColumnName("dblConsolidateFactor").HasPrecision(18, 6);
            this.Property(t => t.ysnFXExposure).HasColumnName("ysnFXExposure");
            this.Property(t => t.dblPriceCheckMin).HasColumnName("dblPriceCheckMin").HasPrecision(18, 6);
            this.Property(t => t.dblPriceCheckMax).HasColumnName("dblPriceCheckMax").HasPrecision(18, 6);
            this.Property(t => t.strCheckoffTaxDesc).HasColumnName("strCheckoffTaxDesc");
            this.Property(t => t.strCheckoffAllState).HasColumnName("strCheckoffAllState");
            this.Property(t => t.strInsuranceTaxDesc).HasColumnName("strInsuranceTaxDesc");
            this.Property(t => t.strInsuranceAllState).HasColumnName("strInsuranceAllState");
            this.Property(t => t.dtmCropEndDateCurrent).HasColumnName("dtmCropEndDateCurrent");
            this.Property(t => t.dtmCropEndDateNew).HasColumnName("dtmCropEndDateNew");
            this.Property(t => t.strEDICode).HasColumnName("strEDICode");
            this.Property(t => t.intScheduleStoreId).HasColumnName("intScheduleStoreId");
            this.Property(t => t.intScheduleDiscountId).HasColumnName("intScheduleDiscountId");
            this.Property(t => t.intScaleAutoDistId).HasColumnName("intScaleAutoDistId");
            this.Property(t => t.ysnAllowLoadContracts).HasColumnName("ysnAllowLoadContracts");
            this.Property(t => t.dblMaxUnder).HasColumnName("dblMaxUnder").HasPrecision(18, 6);
            this.Property(t => t.dblMaxOver).HasColumnName("dblMaxOver").HasPrecision(18, 6);
                                    
            this.HasMany(p => p.tblICCommodityAccounts)
                .WithRequired(p => p.tblICCommodity)
                .HasForeignKey(p => p.intCommodityId);
            this.HasMany(p => p.tblICCommodityGroups)
                .WithRequired(p => p.tblICCommodity)
                .HasForeignKey(p => p.intCommodityId);
            this.HasMany(p => p.tblICCommodityUnitMeasures)
                .WithRequired(p => p.tblICCommodity)
                .HasForeignKey(p => p.intCommodityId);

            this.HasMany(p => p.tblICCommodityClassVariants)
                .WithRequired(p => p.tblICCommodity)
                .HasForeignKey(p => p.intCommodityId);
            this.HasMany(p => p.tblICCommodityGrades)
                .WithRequired(p => p.tblICCommodity)
                .HasForeignKey(p => p.intCommodityId);
            this.HasMany(p => p.tblICCommodityOrigins)
                .WithRequired(p => p.tblICCommodity)
                .HasForeignKey(p => p.intCommodityId);
            this.HasMany(p => p.tblICCommodityProductLines)
                .WithRequired(p => p.tblICCommodity)
                .HasForeignKey(p => p.intCommodityId);
            this.HasMany(p => p.tblICCommodityProductTypes)
                .WithRequired(p => p.tblICCommodity)
                .HasForeignKey(p => p.intCommodityId);
            this.HasMany(p => p.tblICCommodityRegions)
                .WithRequired(p => p.tblICCommodity)
                .HasForeignKey(p => p.intCommodityId);
            this.HasMany(p => p.tblICCommoditySeasons)
                .WithRequired(p => p.tblICCommodity)
                .HasForeignKey(p => p.intCommodityId);

            this.HasOptional(p => p.vyuICCommodityLookUp)
               .WithRequired(p => p.tblICCommodity);
        }
    }

    public class tblICCommodityAccountMap : EntityTypeConfiguration<tblICCommodityAccount>
    {
        public tblICCommodityAccountMap()
        {
            // Primary Key
            this.HasKey(t => t.intCommodityAccountId);

            // Table & Column Mappings
            this.ToTable("tblICCommodityAccount");
            this.Property(t => t.intCommodityAccountId).HasColumnName("intCommodityAccountId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intAccountCategoryId).HasColumnName("intAccountCategoryId");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblGLAccount)
                .WithMany(p => p.tblICCommodityAccounts)
                .HasForeignKey(p => p.intAccountId);
            this.HasOptional(p => p.tblGLAccountCategory)
               .WithMany(p => p.tblICCommodityAccounts)
               .HasForeignKey(p => p.intAccountCategoryId);
        }
    }

    public class tblICCommodityAttributeMap : EntityTypeConfiguration<tblICCommodityAttribute>
    {
        public tblICCommodityAttributeMap()
        {
            // Primary Key
            this.HasKey(t => t.intCommodityAttributeId);

            // Table & Column Mappings
            this.ToTable("tblICCommodityAttribute");
            this.Property(t => t.intCommodityAttributeId).HasColumnName("intCommodityAttributeId");
            //this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            //this.Property(t => t.strType).HasColumnName("strType");
        }
    }

    public class tblSMPurchasingGroupMap: EntityTypeConfiguration<tblSMPurchasingGroup>
    {
        public tblSMPurchasingGroupMap()
        {
            this.HasKey(t => t.intPurchasingGroupId);

            this.ToTable("tblSMPurchasingGroup");
            this.Property(t => t.intPurchasingGroupId).HasColumnName("intPurchasingGroupId");
            this.Property(t => t.strName).HasColumnName("strName");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
        }
    }

    public class tblICCommodityClassVariantMap : EntityTypeConfiguration<tblICCommodityClassVariant>
    {
        public tblICCommodityClassVariantMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
        }
    }

    public class tblICCommodityGradeMap : EntityTypeConfiguration<tblICCommodityGrade>
    {
        public tblICCommodityGradeMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
        }
    }

    public class tblICCommodityOriginMap : EntityTypeConfiguration<tblICCommodityOrigin>
    {
        public tblICCommodityOriginMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intDefaultPackingUOMId).HasColumnName("intDefaultPackingUOMId");
            this.Property(t => t.intCountryID).HasColumnName("intCountryID");
            this.HasOptional(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICCommodityOrigins)
                .HasForeignKey(p => p.intDefaultPackingUOMId);
            this.HasOptional(p => p.tblSMPurchasingGroup)
                .WithMany(p => p.tblICCommodityOrigins)
                .HasForeignKey(p => p.intPurchasingGroupId);
        }
    }

    public class tblICCommodityProductLineMap : EntityTypeConfiguration<tblICCommodityProductLine>
    {
        public tblICCommodityProductLineMap()
        {
            // Primary Key
            this.HasKey(t => t.intCommodityProductLineId);

            // Table & Column Mappings
            this.ToTable("tblICCommodityProductLine");
            this.Property(t => t.intCommodityProductLineId).HasColumnName("intCommodityProductLineId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.ysnDeltaHedge).HasColumnName("ysnDeltaHedge");
            this.Property(t => t.dblDeltaPercent).HasColumnName("dblDeltaPercent").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }

    public class tblICCommodityProductTypeMap : EntityTypeConfiguration<tblICCommodityProductType>
    {
        public tblICCommodityProductTypeMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
        }
    }

    public class tblICCommodityRegionMap : EntityTypeConfiguration<tblICCommodityRegion>
    {
        public tblICCommodityRegionMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
        }
    }

    public class tblICCommoditySeasonMap : EntityTypeConfiguration<tblICCommoditySeason>
    {
        public tblICCommoditySeasonMap()
        {
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
        }
    }

    public class tblICCommodityGroupMap : EntityTypeConfiguration<tblICCommodityGroup>
    {
        public tblICCommodityGroupMap()
        {
            // Primary Key
            this.HasKey(t => t.intCommodityGroupId);

            // Table & Column Mappings
            this.ToTable("tblICCommodityGroup");
            this.Property(t => t.intCommodityGroupId).HasColumnName("intCommodityGroupId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intParentGroupId).HasColumnName("intParentGroupId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
        }
    }

    public class tblICCommodityUnitMeasureMap : EntityTypeConfiguration<tblICCommodityUnitMeasure>
    {
        public tblICCommodityUnitMeasureMap()
        {
            // Primary Key
            this.HasKey(t => t.intCommodityUnitMeasureId);

            // Table & Column Mappings
            this.ToTable("tblICCommodityUnitMeasure");
            this.Property(t => t.intCommodityUnitMeasureId).HasColumnName("intCommodityUnitMeasureId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty").HasPrecision(38, 20);
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICCommodityUnitMeasures)
                .HasForeignKey(p => p.intUnitMeasureId);
        }
    }

    public class vyuICCommodityLookUpMap : EntityTypeConfiguration<vyuICCommodityLookUp>
    {
        public vyuICCommodityLookUpMap()
        {
            // Primary Key
            this.HasKey(t => t.intCommodityId);

            // Table & Column Mappings
            this.ToTable("vyuICCommodityLookUp");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strFutMarketName).HasColumnName("strFutMarketName");
            this.Property(t => t.strScheduleId).HasColumnName("strScheduleId");
            this.Property(t => t.strDiscountId).HasColumnName("strDiscountId");
            this.Property(t => t.strStorageTypeCode).HasColumnName("strStorageTypeCode");
        }
    }

    public class vyuICGetCommodityGradeMap : EntityTypeConfiguration<vyuICGetCommodityGrade>
    {
        public vyuICGetCommodityGradeMap()
        {
            this.HasKey(t => t.intCommodityAttributeId);

            this.ToTable("vyuICGetCommodityGrades");

            this.Property(t => t.intCommodityAttributeId).HasColumnName("intCommodityAttributeId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strCommodityCode).HasColumnName("strCommodityCode");
            this.Property(t => t.strCommodityDescription).HasColumnName("strCommodityDescription");
            this.Property(t => t.strGrade).HasColumnName("strGrade");
        }
    }
}
