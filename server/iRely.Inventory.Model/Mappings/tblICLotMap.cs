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
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.dblQty).HasColumnName("dblQty").HasPrecision(18, 6);
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(18, 6);
            this.Property(t => t.dblWeightPerQty).HasColumnName("dblWeightPerQty").HasPrecision(18, 6);

            this.HasRequired(p => p.tblICItemLocation)
                .WithMany(p => p.tblICLots)
                .HasForeignKey(p => p.intItemLocationId);
        }
    }
}
