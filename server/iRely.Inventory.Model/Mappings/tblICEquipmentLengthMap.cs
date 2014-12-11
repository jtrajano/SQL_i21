using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICEquipmentLengthMap : EntityTypeConfiguration<tblICEquipmentLength>
    {
        public tblICEquipmentLengthMap()
        {
            // Primary Key
            this.HasKey(t => t.intEquipmentLengthId);

            // Table & Column Mappings
            this.ToTable("tblICEquipmentLength");
            this.Property(t => t.intEquipmentLengthId).HasColumnName("intEquipmentLengthId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strEquipmentLength).HasColumnName("strEquipmentLength");
        }
    }
}
