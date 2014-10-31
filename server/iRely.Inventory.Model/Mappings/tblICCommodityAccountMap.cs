using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCommodityAccountMap : EntityTypeConfiguration<tblICCommodityAccount>
    {
        public tblICCommodityAccountMap()
        {
            // Primary Key
            this.HasKey(t => t.intCommodityAccountId);

            // Table & Column Mappings
            this.ToTable("tblICCommodityAccount");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.intCommodityAccountId).HasColumnName("intCommodityAccountId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strAccountDescription).HasColumnName("strAccountDescription");

            this.HasOptional(p => p.tblGLAccount)
                .WithMany(p => p.tblICCommodityAccounts)
                .HasForeignKey(p => p.intAccountId);
            this.HasOptional(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICCommodityAccounts)
                .HasForeignKey(p => p.intLocationId);
        }
    }
}
