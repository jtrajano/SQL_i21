﻿using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCategoryAccountMap : EntityTypeConfiguration<tblICCategoryAccount>
    {
        public tblICCategoryAccountMap()
        {
            // Primary Key
            this.HasKey(t => t.intCategoryAccountId);

            // Table & Column Mappings
            this.ToTable("tblICCategoryAccount");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.intCategoryAccountId).HasColumnName("intCategoryAccountId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intStoreId).HasColumnName("intStoreId");
            this.Property(t => t.strAccountDescription).HasColumnName("strAccountDescription");
        }
    }
}
