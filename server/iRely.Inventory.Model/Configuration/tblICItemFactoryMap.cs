using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemFactoryMap : EntityTypeConfiguration<tblICItemFactory>
    {
        public tblICItemFactoryMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemFactoryId);

            // Table & Column Mappings
            this.ToTable("tblICItemFactory");
            this.Property(t => t.intFactoryId).HasColumnName("intFactoryId");
            this.Property(t => t.intItemFactoryId).HasColumnName("intItemFactoryId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");

            this.HasRequired(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICItemFactories)
                .HasForeignKey(p => p.intFactoryId);
            this.HasMany(p => p.tblICItemFactoryManufacturingCells)
                .WithRequired(p => p.tblICItemFactory)
                .HasForeignKey(p => p.intItemFactoryId);
        }
    }

    public class tblICItemFactoryManufacturingCellMap : EntityTypeConfiguration<tblICItemFactoryManufacturingCell>
    {
        public tblICItemFactoryManufacturingCellMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemFactoryManufacturingCellId);

            // Table & Column Mappings
            this.ToTable("tblICItemFactoryManufacturingCell");
            this.Property(t => t.intItemFactoryId).HasColumnName("intItemFactoryId");
            this.Property(t => t.intItemFactoryManufacturingCellId).HasColumnName("intItemFactoryManufacturingCellId");
            this.Property(t => t.intManufacturingCellId).HasColumnName("intManufacturingCellId");
            this.Property(t => t.intPreference).HasColumnName("intPreference");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");

            this.HasOptional(p => p.vyuICGetItemFactoryManufacturingCell)
                .WithRequired(p => p.tblICItemFactoryManufacturingCell);
        }
    }

    public class vyuICGetItemFactoryManufacturingCellMap : EntityTypeConfiguration<vyuICGetItemFactoryManufacturingCell>
    {
        public vyuICGetItemFactoryManufacturingCellMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemFactoryManufacturingCellId);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemFactoryManufacturingCell");
            this.Property(t => t.intItemFactoryManufacturingCellId).HasColumnName("intItemFactoryManufacturingCellId");
            this.Property(t => t.intItemFactoryId).HasColumnName("intItemFactoryId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.intFactoryId).HasColumnName("intFactoryId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intManufacturingCellId).HasColumnName("intManufacturingCellId");
            this.Property(t => t.strCellName).HasColumnName("strCellName");
            this.Property(t => t.strManufacturingCellDescription).HasColumnName("strManufacturingCellDescription");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            this.Property(t => t.intPreference).HasColumnName("intPreference");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }
}
