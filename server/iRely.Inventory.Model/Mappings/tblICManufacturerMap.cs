using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICManufacturerMap : EntityTypeConfiguration<tblICManufacturer>
    {
        public tblICManufacturerMap()
        {
            // Primary Key
            this.HasKey(t => t.intManufacturerId);

            // Table & Column Mappings
            this.ToTable("tblICManufacturer");
            this.Property(t => t.intManufacturerId).HasColumnName("intManufacturerId");
            this.Property(t => t.strAddress).HasColumnName("strAddress");
            this.Property(t => t.strCity).HasColumnName("strCity");
            this.Property(t => t.strContact).HasColumnName("strContact");
            this.Property(t => t.strCountry).HasColumnName("strCountry");
            this.Property(t => t.strEmail).HasColumnName("strEmail");
            this.Property(t => t.strFax).HasColumnName("strFax");
            this.Property(t => t.strManufacturer).HasColumnName("strManufacturer");
            this.Property(t => t.strNotes).HasColumnName("strNotes");
            this.Property(t => t.strPhone).HasColumnName("strPhone");
            this.Property(t => t.strState).HasColumnName("strState");
            this.Property(t => t.strWebsite).HasColumnName("strWebsite");
            this.Property(t => t.strZipCode).HasColumnName("strZipCode");
        }
    }
}
