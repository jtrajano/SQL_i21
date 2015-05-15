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
            this.Property(t => t.intItemPricingLevelId).HasColumnName("intItemPricingLevelId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strPriceLevel).HasColumnName("strPriceLevel");
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.dblUnit).HasColumnName("dblUnit").HasPrecision(18, 6);
            this.Property(t => t.dblMin).HasColumnName("dblMin").HasPrecision(18, 6);
            this.Property(t => t.dblMax).HasColumnName("dblMax").HasPrecision(18, 6);
            this.Property(t => t.strPricingMethod).HasColumnName("strPricingMethod");
            this.Property(t => t.dblAmountRate).HasColumnName("dblAmountRate").HasPrecision(18, 6);
            this.Property(t => t.dblUnitPrice).HasColumnName("dblUnitPrice").HasPrecision(18, 6);
            this.Property(t => t.strCommissionOn).HasColumnName("strCommissionOn");
            this.Property(t => t.dblCommissionRate).HasColumnName("dblCommissionRate").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICItemLocation)
                .WithMany(p => p.tblICItemPricingLevels)
                .HasForeignKey(p => p.intItemLocationId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICItemPricingLevels)
                .HasForeignKey(p => p.intItemUnitMeasureId);
        }
    }
}
