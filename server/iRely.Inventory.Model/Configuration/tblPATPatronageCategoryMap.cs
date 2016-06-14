using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblPATPatronageCategoryMap : EntityTypeConfiguration<tblPATPatronageCategory>
    {
        public tblPATPatronageCategoryMap()
        {
            this.HasKey(t => t.intPatronageCategoryId);
            this.ToTable("tblPATPatronageCategory");
            this.Property(t => t.intPatronageCategoryId).HasColumnName("intPatronageCategoryId");
            this.Property(t => t.strCategoryCode).HasColumnName("strCategoryCode");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strPurchaseSale).HasColumnName("strPurchaseSale");
            this.Property(t => t.strUnitAmount).HasColumnName("strUnitAmount");
        }
    }
}
