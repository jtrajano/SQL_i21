using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemPricingMap : EntityTypeConfiguration<tblICItemPricing>
    {
        public tblICItemPricingMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemPricingId);

            // Table & Column Mappings
            this.ToTable("tblICItemPricing");
            this.Property(t => t.intItemPricingId).HasColumnName("intItemPricingId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.dblRetailPrice).HasColumnName("dblRetailPrice");
            this.Property(t => t.dblWholesalePrice).HasColumnName("dblWholesalePrice");
            this.Property(t => t.dblLargeVolumePrice).HasColumnName("dblLargeVolumePrice");
            this.Property(t => t.dblAmountPercent).HasColumnName("dblAmountPercent");
            this.Property(t => t.dblSalePrice).HasColumnName("dblSalePrice");
            this.Property(t => t.dblMSRPPrice).HasColumnName("dblMSRPPrice");
            this.Property(t => t.strPricingMethod).HasColumnName("strPricingMethod");
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost");
            this.Property(t => t.dblStandardCost).HasColumnName("dblStandardCost");
            this.Property(t => t.dblMovingAverageCost).HasColumnName("dblMovingAverageCost");
            this.Property(t => t.dblEndMonthCost).HasColumnName("dblEndMonthCost");
            this.Property(t => t.dtmBeginDate).HasColumnName("dtmBeginDate");
            this.Property(t => t.dtmEndDate).HasColumnName("dtmEndDate");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICItemLocation)
                .WithMany(p => p.tblICItemPricings)
                .HasForeignKey(p => p.intItemLocationId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICItemPricings)
                .HasForeignKey(p => p.intItemUnitMeasureId);
        }
    }
}
