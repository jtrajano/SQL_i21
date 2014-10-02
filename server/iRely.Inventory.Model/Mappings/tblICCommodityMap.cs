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
            this.Property(t => t.dblConsolidateFactor).HasColumnName("dblConsolidateFactor");
            this.Property(t => t.dblMaxOver).HasColumnName("dblMaxOver");
            this.Property(t => t.dblMaxUnder).HasColumnName("dblMaxUnder");
            this.Property(t => t.dblPriceCheckMax).HasColumnName("dblPriceCheckMax");
            this.Property(t => t.dblPriceCheckMin).HasColumnName("dblPriceCheckMin");
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
        }
    }
}
