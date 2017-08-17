using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICInventoryCountItemStockLookupMap : EntityTypeConfiguration<vyuICInventoryCountItemStockLookup>
    {
        public vyuICInventoryCountItemStockLookupMap()
        {
            this.HasKey(t => t.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICInventoryCountItemStockLookup");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.dblOnHand).HasColumnName("dblOnHand");
            this.Property(t => t.intItemStockUOMId).HasColumnName("intItemStockUOMId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
        }
    }
}