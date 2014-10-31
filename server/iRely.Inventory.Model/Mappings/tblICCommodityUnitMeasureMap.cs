using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCommodityUnitMeasureMap : EntityTypeConfiguration<tblICCommodityUnitMeasure>
    {
        public tblICCommodityUnitMeasureMap()
        {
            // Primary Key
            this.HasKey(t => t.intCommodityUnitMeasureId);

            // Table & Column Mappings
            this.ToTable("tblICCommodityUnitMeasure");
            this.Property(t => t.dblWeightPerPack).HasColumnName("dblWeightPerPack");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intCommodityUnitMeasureId).HasColumnName("intCommodityUnitMeasureId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.ysnAllowPurchase).HasColumnName("ysnAllowPurchase");
            this.Property(t => t.ysnAllowSale).HasColumnName("ysnAllowSale");
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");

            this.HasOptional(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICCommodityUnitMeasures)
                .HasForeignKey(p => p.intUnitMeasureId);
        }
    }
}
