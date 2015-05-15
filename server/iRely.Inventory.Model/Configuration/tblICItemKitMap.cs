using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemKitMap : EntityTypeConfiguration<tblICItemKit>
    {
        public tblICItemKitMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemKitId);

            // Table & Column Mappings
            this.ToTable("tblICItemKit");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemKitId).HasColumnName("intItemKitId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strComponent).HasColumnName("strComponent");
            this.Property(t => t.strInputType).HasColumnName("strInputType");

            this.HasMany(p => p.tblICItemKitDetails)
                .WithRequired(p => p.tblICItemKit)
                .HasForeignKey(p => p.intItemKitId);
        }
    }
}
