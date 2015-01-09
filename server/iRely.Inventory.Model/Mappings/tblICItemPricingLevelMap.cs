using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemPricingLevelMap : EntityTypeConfiguration<tblICItemPricingLevel>
    {
        public tblICItemPricingLevelMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemPricingLevelId);

            // Table & Column Mappings
            this.ToTable("tblICItemPricingLevel");
            this.Property(t => t.dblCommissionRate).HasColumnName("dblCommissionRate");
            this.Property(t => t.dblMax).HasColumnName("dblMax");
            this.Property(t => t.dblMin).HasColumnName("dblMin");
            this.Property(t => t.dblUnit).HasColumnName("dblUnit");
            this.Property(t => t.dblUnitPrice).HasColumnName("dblUnitPrice");
            this.Property(t => t.dtmBeginDate).HasColumnName("dtmBeginDate");
            this.Property(t => t.dtmEndDate).HasColumnName("dtmEndDate");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemPricingLevelId).HasColumnName("intItemPricingLevelId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strCommissionOn).HasColumnName("strCommissionOn");
            this.Property(t => t.strPriceLevel).HasColumnName("strPriceLevel");
            this.Property(t => t.strPricingMethod).HasColumnName("strPricingMethod");

            this.HasOptional(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICItemPricingLevels)
                .HasForeignKey(p => p.intLocationId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICItemPricingLevels)
                .HasForeignKey(p => p.intUnitMeasureId);
        }
    }
}
