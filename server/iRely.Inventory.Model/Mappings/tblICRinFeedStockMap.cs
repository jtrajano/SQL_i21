using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICRinFeedStockMap : EntityTypeConfiguration<tblICRinFeedStock>
    {
        public tblICRinFeedStockMap()
        {
            // Primary Key
            this.HasKey(t => t.intRinFeedStockId);

            // Table & Column Mappings
            this.ToTable("tblICRinFeedStock");
            this.Property(t => t.intRinFeedStockId).HasColumnName("intRinFeedStockId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strRinFeedStockCode).HasColumnName("strRinFeedStockCode");
        }
    }
}
