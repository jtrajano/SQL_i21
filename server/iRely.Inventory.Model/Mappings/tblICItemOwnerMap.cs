using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemOwnerMap : EntityTypeConfiguration<tblICItemOwner>
    {
        public tblICItemOwnerMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemOwnerId);

            // Table & Column Mappings
            this.ToTable("tblICItemOwner");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemOwnerId).HasColumnName("intItemOwnerId");
            this.Property(t => t.intOwnerId).HasColumnName("intOwnerId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.ysnActive).HasColumnName("ysnActive");

            this.HasRequired(p => p.tblARCustomer)
                .WithMany(p => p.tblICItemOwners)
                .HasForeignKey(p => p.intOwnerId);
        }
    }
}
