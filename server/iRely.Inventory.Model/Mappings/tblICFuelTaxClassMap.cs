using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICFuelTaxClassMap : EntityTypeConfiguration<tblICFuelTaxClass>
    {
        public tblICFuelTaxClassMap()
        {
            // Primary Key
            this.HasKey(t => t.intFuelTaxClassId);

            // Table & Column Mappings
            this.ToTable("tblICFuelTaxClass");
            this.Property(t => t.intFuelTaxClassId).HasColumnName("intFuelTaxClassId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strIRSTaxCode).HasColumnName("strIRSTaxCode");
            this.Property(t => t.strTaxClassCode).HasColumnName("strTaxClassCode");
        }
    }

    public class tblICFuelTaxClassProductCodeMap : EntityTypeConfiguration<tblICFuelTaxClassProductCode>
    {
        public tblICFuelTaxClassProductCodeMap()
        {
            // Primary Key
            this.HasKey(t => t.intFuelTaxClassProductCodeId);

            // Table & Column Mappings
            this.ToTable("tblICFuelTaxClassProductCode");
            this.Property(t => t.intFuelTaxClassId).HasColumnName("intFuelTaxClassId");
            this.Property(t => t.intFuelTaxClassProductCodeId).HasColumnName("intFuelTaxClassProductCodeId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strProductCode).HasColumnName("strProductCode");
            this.Property(t => t.strState).HasColumnName("strState");
        }
    }
}
