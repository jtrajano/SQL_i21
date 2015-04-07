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
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.dblQty).HasColumnName("dblQty").HasPrecision(18, 6);
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(18, 6);
            this.Property(t => t.dblWeightPerQty).HasColumnName("dblWeightPerQty").HasPrecision(18, 6);

            this.HasRequired(p => p.tblICItemLocation)
                .WithMany(p => p.tblICLots)
                .HasForeignKey(p => p.intItemLocationId);
            this.HasRequired(p => p.tblICItem)
                .WithMany(p => p.tblICLots)
                .HasForeignKey(p => p.intItemId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICLots)
                .HasForeignKey(p => p.intItemUOMId);
            this.HasOptional(p => p.WeightUOM)
                .WithMany(p => p.LotWeightUOMs)
                .HasForeignKey(p => p.intWeightUOMId);
        }
    }
}
