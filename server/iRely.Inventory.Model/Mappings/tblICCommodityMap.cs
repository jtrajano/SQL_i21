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
            this.Property(t => t.dblConsolidateFactor).HasColumnName("dblConsolidateFactor").HasPrecision(18, 6);
            this.Property(t => t.dblMaxOver).HasColumnName("dblMaxOver").HasPrecision(18, 6);
            this.Property(t => t.dblMaxUnder).HasColumnName("dblMaxUnder").HasPrecision(18, 6);
            this.Property(t => t.dblPriceCheckMax).HasColumnName("dblPriceCheckMax").HasPrecision(18, 6);
            this.Property(t => t.dblPriceCheckMin).HasColumnName("dblPriceCheckMin").HasPrecision(18, 6);
            this.Property(t => t.dtmCropEndDateCurrent).HasColumnName("dtmCropEndDateCurrent");
            this.Property(t => t.dtmCropEndDateNew).HasColumnName("dtmCropEndDateNew");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intDecimalDPR).HasColumnName("intDecimalDPR");
            this.Property(t => t.intPatronageCategoryDirectId).HasColumnName("intPatronageCategoryDirectId");
            this.Property(t => t.intPatronageCategoryId).HasColumnName("intPatronageCategoryId");
            this.Property(t => t.strAGItemNumber).HasColumnName("strAGItemNumber");
            this.Property(t => t.strCheckoffAllState).HasColumnName("strCheckoffAllState");
            this.Property(t => t.strCheckoffTaxDesc).HasColumnName("strCheckoffTaxDesc");
            this.Property(t => t.strCommodityCode).HasColumnName("strCommodityCode");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strEDICode).HasColumnName("strEDICode");
            this.Property(t => t.strInsuranceAllState).HasColumnName("strInsuranceAllState");
            this.Property(t => t.strInsuranceTaxDesc).HasColumnName("strInsuranceTaxDesc");
            this.Property(t => t.strScaleAutoDist).HasColumnName("strScaleAutoDist	");
            this.Property(t => t.strScheduleDiscount).HasColumnName("strScheduleDiscount");
            this.Property(t => t.strScheduleStore).HasColumnName("strScheduleStore");
            this.Property(t => t.strTextFees).HasColumnName("strTextFees");
            this.Property(t => t.strTextPurchase).HasColumnName("strTextPurchase");
            this.Property(t => t.strTextSales).HasColumnName("strTextSales");
            this.Property(t => t.ysnAllowLoadContracts).HasColumnName("ysnAllowLoadContracts");
            this.Property(t => t.ysnAllowVariety).HasColumnName("ysnAllowVariety");
            this.Property(t => t.ysnExchangeTraded).HasColumnName("ysnExchangeTraded");
            this.Property(t => t.ysnFXExposure).HasColumnName("ysnFXExposure");
            this.Property(t => t.ysnRequireLoadNumber).HasColumnName("ysnRequireLoadNumber");

            this.HasOptional(p => p.PatronageCategory)
                .WithMany(p => p.tblICCommodities)
                .HasForeignKey(p => p.intPatronageCategoryId);
            this.HasOptional(p => p.PatronageCategoryDirect)
                .WithMany(p => p.tblICCommoditiesDirect)
                .HasForeignKey(p => p.intPatronageCategoryDirectId);

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
        }
    }
}
