using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemAssemblyMap : EntityTypeConfiguration<tblICItemAssembly>
    {
        public tblICItemAssemblyMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemAssemblyId);

            // Table & Column Mappings
            this.ToTable("tblICItemAssembly");
            this.Property(t => t.dblCost).HasColumnName("dblCost");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity");
            this.Property(t => t.dblUnit).HasColumnName("dblUnit");
            this.Property(t => t.intAssemblyItemId).HasColumnName("intAssemblyItemId");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intItemAssemblyId).HasColumnName("intItemAssemblyId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");

            this.HasOptional(p => p.AssemblyItem)
                .WithMany(p => p.tblICItemAssemblies)
                .HasForeignKey(p => p.intAssemblyItemId);
            this.HasOptional(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICItemAssemblies)
                .HasForeignKey(p => p.intUnitMeasureId);
        }
    }
}
