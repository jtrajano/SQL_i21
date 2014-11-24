using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICRestrictionMap : EntityTypeConfiguration<tblICRestriction>
    {
        public tblICRestrictionMap()
        {
            // Primary Key
            this.HasKey(t => t.intRestrictionId);

            // Table & Column Mappings
            this.ToTable("tblICRestriction");
            this.Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            this.Property(t => t.intRestrictionId).HasColumnName("intRestrictionId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDisplayMember).HasColumnName("strDisplayMember");
            this.Property(t => t.strInternalCode).HasColumnName("strInternalCode");
            this.Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            this.Property(t => t.ysnLocked).HasColumnName("ysnLocked");
        }
    }
}
