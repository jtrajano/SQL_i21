using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemPOSMap : EntityTypeConfiguration<tblICItemPOS>
    {
        public tblICItemPOSMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemId);

            // Table & Column Mappings
            this.ToTable("tblICItemPOS");
            this.Property(t => t.dblCaseQty).HasColumnName("dblCaseQty");
            this.Property(t => t.dblTaxExempt).HasColumnName("dblTaxExempt");
            this.Property(t => t.dtmDateShip).HasColumnName("dtmDateShip");
            this.Property(t => t.intAGCategory).HasColumnName("intAGCategory");
            this.Property(t => t.intCaseUOM).HasColumnName("intCaseUOM");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strCountCode).HasColumnName("strCountCode");
            this.Property(t => t.strKeywords).HasColumnName("strKeywords");
            this.Property(t => t.strLeadTime).HasColumnName("strLeadTime");
            this.Property(t => t.strNACSCategory).HasColumnName("strNACSCategory");
            this.Property(t => t.strSpecialCommission).HasColumnName("strSpecialCommission");
            this.Property(t => t.strUPCNo).HasColumnName("strUPCNo");
            this.Property(t => t.strWICCode).HasColumnName("strWICCode");
            this.Property(t => t.ysnCommisionable).HasColumnName("ysnCommisionable");
            this.Property(t => t.ysnDropShip).HasColumnName("ysnDropShip");
            this.Property(t => t.ysnLandedCost).HasColumnName("ysnLandedCost");
            this.Property(t => t.ysnReceiptCommentRequired).HasColumnName("ysnReceiptCommentRequired");
            this.Property(t => t.ysnTaxable).HasColumnName("ysnTaxable");

            this.HasMany(p => p.tblICItemPOSCategories)
                .WithRequired(p => p.tblICItemPOS)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemPOSSLAs)
                .WithRequired(p => p.tblICItemPOS)
                .HasForeignKey(p => p.intItemId);
        }
    }

    public class tblICItemPOSCategoryMap : EntityTypeConfiguration<tblICItemPOSCategory>
    {
        public tblICItemPOSCategoryMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemPOSCategoryId);

            // Table & Column Mappings
            this.ToTable("tblICItemPOSCategory");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemPOSCategoryId).HasColumnName("intItemPOSCategoryId");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }

    public class tblICItemPOSSLAMap : EntityTypeConfiguration<tblICItemPOSSLA>
    {
        public tblICItemPOSSLAMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemPOSSLAId);

            // Table & Column Mappings
            this.ToTable("tblICItemPOSSLA");
            this.Property(t => t.dblContractPrice).HasColumnName("dblContractPrice");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemPOSSLAId).HasColumnName("intItemPOSSLAId");
            this.Property(t => t.strSLAContract).HasColumnName("strSLAContract");
            this.Property(t => t.ysnServiceWarranty).HasColumnName("ysnServiceWarranty");
        }
    }
}
