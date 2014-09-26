using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemCustomerXrefMap : EntityTypeConfiguration<tblICItemCustomerXref>
    {
        public tblICItemCustomerXrefMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemCustomerXrefId);

            // Table & Column Mappings
            this.ToTable("tblICItemCustomerXref");
            this.Property(t => t.intCustomerId).HasColumnName("intCustomerId");
            this.Property(t => t.intItemCustomerXrefId).HasColumnName("intItemCustomerXrefId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strCustomerProduct).HasColumnName("strCustomerProduct");
            this.Property(t => t.strPickTicketNotes).HasColumnName("strPickTicketNotes");
            this.Property(t => t.strProductDescription).HasColumnName("strProductDescription");
            this.Property(t => t.strStoreName).HasColumnName("strStoreName");
        }
    }
}
