using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemCommodityCostMap: EntityTypeConfiguration<tblICItemCommodityCost>
    {
        public tblICItemCommodityCostMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemCommodityCostId);

            // Table & Column Mappings
            this.ToTable("tblICItemCommodityCost");
            this.Property(t => t.intItemCommodityCostId).HasColumnName("intItemCommodityCostId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(18, 6);
            this.Property(t => t.dblStandardCost).HasColumnName("dblStandardCost").HasPrecision(18, 6);
            this.Property(t => t.dblAverageCost).HasColumnName("dblAverageCost").HasPrecision(18, 6);
            this.Property(t => t.dblEOMCost).HasColumnName("dblEOMCost").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICItemLocation)
                .WithMany(p => p.tblICItemCommodityCosts)
                .HasForeignKey(p => p.intItemLocationId);
        }
    }
}
