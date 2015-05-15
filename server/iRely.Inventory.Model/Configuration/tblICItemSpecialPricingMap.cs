using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemSpecialPricingMap : EntityTypeConfiguration<tblICItemSpecialPricing>
    {
        public tblICItemSpecialPricingMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemSpecialPricingId);

            // Table & Column Mappings
            this.ToTable("tblICItemSpecialPricing");
            this.Property(t => t.intItemSpecialPricingId).HasColumnName("intItemSpecialPricingId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strPromotionType).HasColumnName("strPromotionType");
            this.Property(t => t.dtmBeginDate).HasColumnName("dtmBeginDate");
            this.Property(t => t.dtmEndDate).HasColumnName("dtmEndDate");
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.dblUnit).HasColumnName("dblUnit").HasPrecision(18, 6);
            this.Property(t => t.strDiscountBy).HasColumnName("strDiscountBy");
            this.Property(t => t.dblDiscount).HasColumnName("dblDiscount").HasPrecision(18, 6);
            this.Property(t => t.dblUnitAfterDiscount).HasColumnName("dblUnitAfterDiscount").HasPrecision(18, 6);
            this.Property(t => t.dblDiscountThruQty).HasColumnName("dblDiscountThruQty").HasPrecision(18, 6);
            this.Property(t => t.dblDiscountThruAmount).HasColumnName("dblDiscountThruAmount").HasPrecision(18, 6);
            this.Property(t => t.dblAccumulatedQty).HasColumnName("dblAccumulatedQty").HasPrecision(18, 6);
            this.Property(t => t.dblAccumulatedAmount).HasColumnName("dblAccumulatedAmount").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICItemLocation)
                .WithMany(p => p.tblICItemSpecialPricings)
                .HasForeignKey(p => p.intItemLocationId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICItemSpecialPricings)
                .HasForeignKey(p => p.intItemLocationId);
        }
    }
}
