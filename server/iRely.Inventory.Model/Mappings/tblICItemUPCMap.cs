using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemUPCMap : EntityTypeConfiguration<tblICItemUPC>
    {
        public tblICItemUPCMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemUPCId);

            // Table & Column Mappings
            this.ToTable("tblICItemUPC");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemUPCId).HasColumnName("intItemUPCId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strUPCCode).HasColumnName("strUPCCode");
        }
    }
}
