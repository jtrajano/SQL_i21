using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemSubstituteMap : EntityTypeConfiguration<tblICItemSubstitute>
    {
        public tblICItemSubstituteMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemSubstituteId);

            // Table & Column Mappings
            this.ToTable("tblICItemSubstitute");
            this.Property(t => t.intItemSubstituteId).HasColumnName("intItemSubstituteId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intSubstituteItemId).HasColumnName("intSubstituteItemId");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.dblMarkUpOrDown).HasColumnName("dblMarkUpOrDown").HasPrecision(38, 20);
            this.Property(t => t.dtmBeginDate).HasColumnName("dtmBeginDate");
            this.Property(t => t.dtmEndDate).HasColumnName("dtmEndDate");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");

            this.HasOptional(p => p.SubstituteItem)
                .WithMany(p => p.SubstituteItems)
                .HasForeignKey(p => p.intSubstituteItemId);

            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICItemSubstitutes)
                .HasForeignKey(p => p.intItemUOMId);
        }
    }

    public class vyuICGetSubstituteItemMap : EntityTypeConfiguration<vyuICGetSubstituteItem>
    {
        public vyuICGetSubstituteItemMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemSubstituteId);

            // Table & Column Mappings
            this.ToTable("vyuICGetSubstituteItem");
            this.Property(t => t.intItemSubstituteId).HasColumnName("intItemSubstituteId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.intSubstituteItemId).HasColumnName("intSubstituteItemId");
            this.Property(t => t.strSubstituteItemNo).HasColumnName("strSubstituteItemNo");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.dblMarkUpOrDown).HasColumnName("dblMarkUpOrDown").HasPrecision(38, 20);
            this.Property(t => t.dtmBeginDate).HasColumnName("dtmBeginDate");
            this.Property(t => t.dtmEndDate).HasColumnName("dtmEndDate");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");

        }
    }

    public class vyuICGetSubstituteComponentStockMap : EntityTypeConfiguration<vyuICGetSubstituteComponentStock>
    {
        public vyuICGetSubstituteComponentStockMap()
        {
            this.HasKey(t => t.intParentKey);

            this.ToTable("vyuICGetSubstituteComponentStock");
        }
    }
}
