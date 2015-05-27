using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemSubstitutionMap : EntityTypeConfiguration<tblICItemSubstitution>
    {
        public tblICItemSubstitutionMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemSubstitutionId);

            // Table & Column Mappings
            this.ToTable("tblICItemSubstitution");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemSubstitutionId).HasColumnName("intItemSubstitutionId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strComment).HasColumnName("strComment");
            this.Property(t => t.strModification).HasColumnName("strModification");
        }
    }

    public class tblICItemSubstitutionDetailMap : EntityTypeConfiguration<tblICItemSubstitutionDetail>
    {
        public tblICItemSubstitutionDetailMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemSubstitutionDetailId);

            // Table & Column Mappings
            this.ToTable("tblICItemSubstitutionDetail");
            this.Property(t => t.dblPercent).HasColumnName("dblPercent").HasPrecision(18, 6);
            this.Property(t => t.dblRatio).HasColumnName("dblRatio").HasPrecision(18, 6);
            this.Property(t => t.dtmValidFrom).HasColumnName("dtmValidFrom");
            this.Property(t => t.dtmValidTo).HasColumnName("dtmValidTo");
            this.Property(t => t.intItemSubstitutionDetailId).HasColumnName("intItemSubstitutionDetailId");
            this.Property(t => t.intItemSubstitutionId).HasColumnName("intItemSubstitutionId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intSubstituteItemId).HasColumnName("intSubstituteItemId");
            this.Property(t => t.ysnYearValidationRequired).HasColumnName("ysnYearValidationRequired");
        }
    }
}
