using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCertificationMap : EntityTypeConfiguration<tblICCertification>
    {
        public tblICCertificationMap()
        {
            // Primary Key
            this.HasKey(t => t.intCertificationId);

            // Table & Column Mappings
            this.ToTable("tblICCertification");
            this.Property(t => t.intCertificationId).HasColumnName("intCertificationId");
            this.Property(t => t.intCountryId).HasColumnName("intCountryId");
            this.Property(t => t.strCertificationIdName).HasColumnName("strCertificationIdName");
            this.Property(t => t.strCertificationName).HasColumnName("strCertificationName");
            this.Property(t => t.strIssuingOrganization).HasColumnName("strIssuingOrganization");
            this.Property(t => t.ysnGlobalCertification).HasColumnName("ysnGlobalCertification");

            this.HasMany(p => p.tblICCertificationCommodities)
                .WithRequired(p => p.tblICCertification)
                .HasForeignKey(p => p.intCertificationId);
        }
    }

    public class tblICCertificationCommodityMap : EntityTypeConfiguration<tblICCertificationCommodity>
    {
        public tblICCertificationCommodityMap()
        {
            // Primary Key
            this.HasKey(t => t.intCertificationCommodityId);

            // Table & Column Mappings
            this.ToTable("tblICCertificationCommodity");
            this.Property(t => t.dblCertificationPremium).HasColumnName("dblCertificationPremium");
            this.Property(t => t.dtmDateEffective).HasColumnName("dtmDateEffective");
            this.Property(t => t.intCertificationCommodityId).HasColumnName("intCertificationCommodityId");
            this.Property(t => t.intCertificationId).HasColumnName("intCertificationId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
        }
    }
}
