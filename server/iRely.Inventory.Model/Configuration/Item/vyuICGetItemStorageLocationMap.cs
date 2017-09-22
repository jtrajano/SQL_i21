using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemStorageLocationMap : EntityTypeConfiguration<vyuICGetItemStorageLocation>
    {
        public vyuICGetItemStorageLocationMap()
        {
            this.HasKey(p => p.intStorageLocationId);
            this.ToTable("vyuICGetItemStorageLocation");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.strStorageLocationDescription).HasColumnName("strStorageLocationDescription");
        }
    }
}
