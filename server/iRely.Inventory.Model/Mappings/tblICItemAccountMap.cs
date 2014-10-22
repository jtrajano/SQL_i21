using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemAccountMap : EntityTypeConfiguration<tblICItemAccount>
    {
        public tblICItemAccountMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemAccountId);

            // Table & Column Mappings
            this.ToTable("tblICItemAccount");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.intItemAccountId).HasColumnName("intItemAccountId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intProfitCenterId).HasColumnName("intProfitCenterId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strAccountDescription).HasColumnName("strAccountDescription");

            this.HasOptional(p => p.tblGLAccount)
                .WithMany(p => p.tblICItemAccounts)
                .HasForeignKey(p => p.intAccountId);
            this.HasOptional(p => p.ProfitCenter)
                .WithMany(p => p.tblICItemAccountProfitCenters)
                .HasForeignKey(p => p.intProfitCenterId);
            this.HasOptional(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICItemAccounts)
                .HasForeignKey(p => p.intLocationId);
        }
    }
}
