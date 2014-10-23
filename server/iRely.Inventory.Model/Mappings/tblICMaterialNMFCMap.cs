using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICMaterialNMFCMap : EntityTypeConfiguration<tblICMaterialNMFC>
    {
        public tblICMaterialNMFCMap()
        {
            // Primary Key
            this.HasKey(t => t.intMaterialNMFCId);

            // Table & Column Mappings
            this.ToTable("tblICMaterialNMFC");
            this.Property(t => t.dtmLastUpdateOn).HasColumnName("dtmLastUpdateOn");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intExternalSystemId).HasColumnName("intExternalSystemId");
            this.Property(t => t.intMaterialNMFCId).HasColumnName("intMaterialNMFCId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDisplayMember).HasColumnName("strDisplayMember");
            this.Property(t => t.strInternalCode).HasColumnName("strInternalCode");
            this.Property(t => t.strLastUpdateBy).HasColumnName("strLastUpdateBy");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            this.Property(t => t.ysnLocked).HasColumnName("ysnLocked");
        }
    }
}
