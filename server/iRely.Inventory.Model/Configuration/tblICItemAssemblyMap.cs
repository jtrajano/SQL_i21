﻿using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemAssemblyMap : EntityTypeConfiguration<tblICItemAssembly>
    {
        public tblICItemAssemblyMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemAssemblyId);

            // Table & Column Mappings
            this.ToTable("tblICItemAssembly");
            this.Property(t => t.intItemAssemblyId).HasColumnName("intItemAssemblyId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intAssemblyItemId).HasColumnName("intAssemblyItemId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.dblUnit).HasColumnName("dblUnit").HasPrecision(18, 6);
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.vyuICGetAssemblyItem)
                .WithRequired(p => p.tblICItemAssembly);
        }
    }

    public class vyuICGetAssemblyItemMap : EntityTypeConfiguration<vyuICGetAssemblyItem>
    {
        public vyuICGetAssemblyItemMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemAssemblyId);

            // Table & Column Mappings
            this.ToTable("vyuICGetAssemblyItem");
            this.Property(t => t.intItemAssemblyId).HasColumnName("intItemAssemblyId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intAssemblyItemId).HasColumnName("intAssemblyItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strComponentItem).HasColumnName("strComponentItem");
            this.Property(t => t.strComponentDescription).HasColumnName("strComponentDescription");
            this.Property(t => t.strComponentType).HasColumnName("strComponentType");
            this.Property(t => t.strComponentLotTracking).HasColumnName("strComponentLotTracking");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.strComponentUOM).HasColumnName("strComponentUOM");
            this.Property(t => t.dblComponentUOMCF).HasColumnName("dblComponentUOMCF").HasPrecision(18, 6);
            this.Property(t => t.dblUnit).HasColumnName("dblUnit").HasPrecision(18, 6);
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(18, 6);
            this.Property(t => t.dblUnitLastCost).HasColumnName("dblUnitLastCost").HasPrecision(18, 6);
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(18, 6);
        }
    }
}
