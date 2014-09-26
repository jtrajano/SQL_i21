using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemContractDocumentMap : EntityTypeConfiguration<tblICItemContractDocument>
    {
        public tblICItemContractDocumentMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemContractDocumentId);

            // Table & Column Mappings
            this.ToTable("tblICItemContractDocument");
            this.Property(t => t.intDocumentId).HasColumnName("intDocumentId");
            this.Property(t => t.intItemContractDocumentId).HasColumnName("intItemContractDocumentId");
            this.Property(t => t.intItemContractId).HasColumnName("intItemContractId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasRequired(p => p.tblICDocument)
                .WithMany(p => p.tblICItemContractDocuments)
                .HasForeignKey(p => p.intDocumentId);
        }
    }
}
