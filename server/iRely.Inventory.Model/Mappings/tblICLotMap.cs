using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICLotMap: EntityTypeConfiguration<tblICLot>
    {
        public tblICLotMap()
        {
            // Primary Key
            this.HasKey(t => t.intLotId);

            // Table & Column Mappings
            this.ToTable("tblICLot");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.strLotId).HasColumnName("strLotId");
        }
    }
}
