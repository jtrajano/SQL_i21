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
            this.Property(t => t.dblAccumulatedAmount).HasColumnName("dblAccumulatedAmount");
            this.Property(t => t.dblAccumulatedQty).HasColumnName("dblAccumulatedQty");
            this.Property(t => t.dblDiscount).HasColumnName("dblDiscount");
            this.Property(t => t.dblUnit).HasColumnName("dblUnit");
            this.Property(t => t.dblUnitAfterDiscount).HasColumnName("dblUnitAfterDiscount");
            this.Property(t => t.dtmBeginDate).HasColumnName("dtmBeginDate");
            this.Property(t => t.dtmEndDate).HasColumnName("dtmEndDate");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemSpecialPricingId).HasColumnName("intItemSpecialPricingId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strDiscountBy).HasColumnName("strDiscountBy");
            this.Property(t => t.strPromotionType).HasColumnName("strPromotionType");

            this.HasOptional(p => p.tblICItemLocation)
                .WithMany(p => p.tblICItemSpecialPricings)
                .HasForeignKey(p => p.intLocationId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICItemSpecialPricings)
                .HasForeignKey(p => p.intUnitMeasureId);
        }
    }
}
