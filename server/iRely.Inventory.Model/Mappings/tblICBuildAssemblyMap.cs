using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICBuildAssemblyMap : EntityTypeConfiguration<tblICBuildAssembly>
    {
        public tblICBuildAssemblyMap()
        {
            // Primary Key
            this.HasKey(t => t.intBuildAssemblyId);

            // Table & Column Mappings
            this.ToTable("tblICBuildAssembly");
            this.Property(t => t.intBuildAssemblyId).HasColumnName("intBuildAssemblyId");
            this.Property(t => t.dtmBuildDate).HasColumnName("dtmBuildDate");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strBuildNo).HasColumnName("strBuildNo");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.dblBuildQuantity).HasColumnName("dblBuildQuantity").HasPrecision(18, 6);
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(18, 6);
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.ysnPosted).HasColumnName("ysnPosted");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.intCreatedUserId).HasColumnName("intCreatedUserId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasMany(p => p.tblICBuildAssemblyDetails)
                .WithRequired(p => p.tblICBuildAssembly)
                .HasForeignKey(p => p.intBuildAssemblyId);
            this.HasOptional(p => p.tblICItem)
                .WithMany(p => p.tblICBuildAssemblies)
                .HasForeignKey(p => p.intItemId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICBuildAssemblies)
                .HasForeignKey(p => p.intItemUOMId);
            this.HasOptional(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICBuildAssemblies)
                .HasForeignKey(p => p.intLocationId);
            this.HasOptional(p => p.tblSMCompanyLocationSubLocation)
                .WithMany(p => p.tblICBuildAssemblies)
                .HasForeignKey(p => p.intSubLocationId);
        }
    }

    public class tblICBuildAssemblyDetailMap : EntityTypeConfiguration<tblICBuildAssemblyDetail>
    {
        public tblICBuildAssemblyDetailMap()
        {
            // Primary Key
            this.HasKey(t => t.intBuildAssemblyDetailId);

            // Table & Column Mappings
            this.ToTable("tblICBuildAssemblyDetail");
            this.Property(t => t.intBuildAssemblyDetailId).HasColumnName("intBuildAssemblyDetailId");
            this.Property(t => t.intBuildAssemblyId).HasColumnName("intBuildAssemblyId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICItem)
                .WithMany(p => p.tblICBuildAssemblyDetails)
                .HasForeignKey(p => p.intItemId);
            this.HasOptional(p => p.tblSMCompanyLocationSubLocation)
                .WithMany(p => p.tblICBuildAssemblyDetails)
                .HasForeignKey(p => p.intSubLocationId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICBuildAssemblyDetails)
                .HasForeignKey(p => p.intItemUOMId);
        }
    }
}
