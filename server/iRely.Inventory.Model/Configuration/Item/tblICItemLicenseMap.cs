using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICItemLicenseMap : EntityTypeConfiguration<tblICItemLicense>
    {
        public tblICItemLicenseMap()
        {
            //Primary Key
            this.HasKey(t => t.intItemLicenseId);

            //Table & Mappings
            this.ToTable("tblICItemLicense");
            this.Property(t => t.intItemLicenseId).HasColumnName("intItemLicenseId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLicenseTypeId).HasColumnName("intLicenseTypeId");

            this.HasRequired(t => t.tblICItem)
                .WithMany(t => t.tblICItemLicenses)
                .HasForeignKey(t => t.intItemId);

            this.HasRequired(t => t.tblSMLicenseType)
                .WithMany(t => t.tblICItemLicenses)
                .HasForeignKey(t => t.intLicenseTypeId);
        }
    }

    public class vyuICItemLicenseMap : EntityTypeConfiguration<vyuICItemLicense>
    {
        public vyuICItemLicenseMap()
        {
            this.HasKey(t => t.intItemLicenseId);
            this.ToTable("vyuICItemLicense");
        }
    }
}
