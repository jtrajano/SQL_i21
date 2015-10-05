using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemMotorFuelTaxMap : EntityTypeConfiguration<tblICItemMotorFuelTax>
    {
        public tblICItemMotorFuelTaxMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemMotorFuelTaxId);

            // Table & Column Mappings
            this.ToTable("tblICItemMotorFuelTax");
            this.Property(t => t.intItemMotorFuelTaxId).HasColumnName("intItemMotorFuelTaxId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intTaxAuthorityId).HasColumnName("intTaxAuthorityId");
            this.Property(t => t.intProductCodeId).HasColumnName("intProductCodeId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.vyuICGetItemMotorFuelTax)
                .WithRequired(p => p.tblICItemMotorFuelTax);
        }
    }

    public class vyuICGetItemMotorFuelTaxMap : EntityTypeConfiguration<vyuICGetItemMotorFuelTax>
    {
        public vyuICGetItemMotorFuelTaxMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemMotorFuelTaxId);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemMotorFuelTax");
            this.Property(t => t.intItemMotorFuelTaxId).HasColumnName("intItemMotorFuelTaxId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intTaxAuthorityId).HasColumnName("intTaxAuthorityId");
            this.Property(t => t.strTaxAuthorityCode).HasColumnName("strTaxAuthorityCode");
            this.Property(t => t.strTaxAuthorityDescription).HasColumnName("strTaxAuthorityDescription");
            this.Property(t => t.intProductCodeId).HasColumnName("intProductCodeId");
            this.Property(t => t.strProductCode).HasColumnName("strProductCode");
            this.Property(t => t.strProductDescription).HasColumnName("strProductDescription");
            this.Property(t => t.strProductCodeGroup).HasColumnName("strProductCodeGroup");
        }
    }
}
