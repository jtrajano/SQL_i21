using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICDocumentMap : EntityTypeConfiguration<tblICDocument>
    {
        public tblICDocumentMap()
        {
            // Primary Key
            this.HasKey(t => t.intDocumentId);

            // Table & Column Mappings
            this.ToTable("tblICDocument");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intDocumentId).HasColumnName("intDocumentId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strDocumentName).HasColumnName("strDocumentName");
            this.Property(t => t.intDocumentType).HasColumnName("intDocumentType");
            this.Property(t => t.ysnStandard).HasColumnName("ysnStandard");

            this.HasOptional(p => p.tblICCommodity)
                .WithMany(p => p.tblICDocuments)
                .HasForeignKey(p => p.intCommodityId);
        }
    }
}
