using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemSubLocationMap : EntityTypeConfiguration<tblICItemSubLocation>
    {
        public tblICItemSubLocationMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemSubLocationId);

            // Table & Column Mappings
            this.ToTable("tblICItemSubLocation");
            this.Property(t => t.intItemSubLocationId).HasColumnName("intItemSubLocationId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");

            this.HasRequired(p => p.tblICItemLocation)
                .WithMany(p => p.tblICItemSubLocations)
                .HasForeignKey(p => p.intItemLocationId);
        }
    }
}
