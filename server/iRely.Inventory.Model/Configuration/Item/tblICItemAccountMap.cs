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
            this.Property(t => t.intItemAccountId).HasColumnName("intItemAccountId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intAccountCategoryId).HasColumnName("intAccountCategoryId");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblGLAccount)
                .WithMany(p => p.tblICItemAccounts)
                .HasForeignKey(p => p.intAccountId);
            this.HasOptional(p => p.tblGLAccountCategory)
                .WithMany(p => p.tblICItemAccounts)
                .HasForeignKey(p => p.intAccountCategoryId);
        }
    }
}
