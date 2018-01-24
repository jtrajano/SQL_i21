﻿using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemBundleMap : EntityTypeConfiguration<tblICItemBundle>
    {
        public tblICItemBundleMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemBundleId);

            // Table & Column Mappings
            this.ToTable("tblICItemBundle");
            this.Property(t => t.intItemBundleId).HasColumnName("intItemBundleId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intBundleItemId).HasColumnName("intBundleItemId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.ysnAddOn).HasColumnName("ysnAddOn");
            this.Property(t => t.dblMarkUpOrDown).HasColumnName("dblMarkUpOrDown").HasPrecision(38, 20);
            this.Property(t => t.dtmBeginDate).HasColumnName("dtmBeginDate");
            this.Property(t => t.dtmEndDate).HasColumnName("dtmEndDate");

            this.HasOptional(p => p.BundleItem)
                .WithMany(p => p.BundleItems)
                .HasForeignKey(p => p.intBundleItemId);

            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICItemBundles)
                .HasForeignKey(p => p.intItemUnitMeasureId);
        }
    }

    public class vyuICGetBundleItemMap : EntityTypeConfiguration<vyuICGetBundleItem>
    {
        public vyuICGetBundleItemMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemBundleId);

            // Table & Column Mappings
            this.ToTable("vyuICGetBundleItem");
            this.Property(t => t.intItemBundleId).HasColumnName("intItemBundleId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.intBundleItemId).HasColumnName("intBundleItemId");
            this.Property(t => t.strComponentItemNo).HasColumnName("strComponentItemNo");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.dblMarkUpOrDown).HasColumnName("dblMarkUpOrDown").HasPrecision(38, 20);
            this.Property(t => t.dtmBeginDate).HasColumnName("dtmBeginDate");
            this.Property(t => t.dtmEndDate).HasColumnName("dtmEndDate");
        }
    }

    public class vyuICGetBundleItemStockMap : EntityTypeConfiguration<vyuICGetBundleItemStock>
    {
        public vyuICGetBundleItemStockMap()
        {
            // Primary Key
            this.HasKey(t => t.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetBundleItemStock");
        }
    }
}
