using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemContractMap : EntityTypeConfiguration<tblICItemContract>
    {
        public tblICItemContractMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemContractId);

            // Table & Column Mappings
            this.ToTable("tblICItemContract");
            this.Property(t => t.dblFranchisePercent).HasColumnName("dblFranchisePercent");
            this.Property(t => t.dblTolerancePercent).HasColumnName("dblTolerancePercent");
            this.Property(t => t.dblYieldPercent).HasColumnName("dblYieldPercent");
            this.Property(t => t.intCountryId).HasColumnName("intCountryId");
            this.Property(t => t.intItemContractId).HasColumnName("intItemContractId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strContractItemName).HasColumnName("strContractItemName");
            this.Property(t => t.strGarden).HasColumnName("strGarden");
            this.Property(t => t.strGrade).HasColumnName("strGrade");
            this.Property(t => t.strGradeType).HasColumnName("strGradeType");
            this.Property(t => t.strStoreName).HasColumnName("strStoreName");

            this.HasOptional(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICItemContracts)
                .HasForeignKey(p => p.intLocationId);
            this.HasOptional(p => p.tblSMCountry)
                .WithMany(p => p.tblICItemContracts)
                .HasForeignKey(p => p.intCountryId);

            this.HasMany(p => p.tblICItemContractDocuments)
                .WithRequired(p => p.tblICItemContract)
                .HasForeignKey(p => p.intItemContractId);
        }
    }
}
