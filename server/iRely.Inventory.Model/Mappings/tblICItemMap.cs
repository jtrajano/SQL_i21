﻿using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemMap : EntityTypeConfiguration<tblICItem>
    {
        public tblICItemMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemId);

            // Table & Column Mappings
            this.ToTable("tblICItem");
            this.Property(t => t.intBrandId).HasColumnName("intBrandId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intManufacturerId).HasColumnName("intManufacturerId");
            this.Property(t => t.intTrackingId).HasColumnName("intTrackingId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.strModelNo).HasColumnName("strModelNo");
            this.Property(t => t.strStatus).HasColumnName("strStatus");
            this.Property(t => t.strType).HasColumnName("strType");

            this.HasMany(p => p.tblICItemUOMs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemLocationStores)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasOptional(p => p.tblICItemSales)
                .WithRequired(p => p.tblICItem)
                .WillCascadeOnDelete();
            this.HasOptional(p => p.tblICItemPOS)
                .WithRequired(p => p.tblICItem)
                .WillCascadeOnDelete();
            this.HasOptional(p => p.tblICItemManufacturing)
                .WithRequired(p => p.tblICItem)
                .WillCascadeOnDelete();
            this.HasMany(p => p.tblICItemCertifications)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemContracts)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemCustomerXrefs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemVendorXrefs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemUPCs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);

            this.HasMany(p => p.tblICItemPricings)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemPricingLevels)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemSpecialPricings)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemStocks)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemAccounts)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemNotes)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
        }
    }
}
