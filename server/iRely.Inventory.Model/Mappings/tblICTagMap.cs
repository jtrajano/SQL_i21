using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICTagMap : EntityTypeConfiguration<tblICTag>
    {
        public tblICTagMap()
        {
            // Primary Key
            this.HasKey(t => t.intTagId);

            // Table & Column Mappings
            this.ToTable("tblICTag");
            this.Property(t => t.intTagId).HasColumnName("intTagId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strMessage).HasColumnName("strMessage");
            this.Property(t => t.strTagNumber).HasColumnName("strTagNumber");
            this.Property(t => t.ysnHazMat).HasColumnName("ysnHazMat");
        }
    }
}
