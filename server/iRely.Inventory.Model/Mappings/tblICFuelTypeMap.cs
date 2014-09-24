using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICFuelTypeMap : EntityTypeConfiguration<tblICFuelType>
    {
        public tblICFuelTypeMap()
        {
            // Primary Key
            this.HasKey(t => t.intFuelTypeId);

            // Table & Column Mappings
            this.ToTable("tblICFuelType");
            this.Property(t => t.dblFeedStockFactor).HasColumnName("dblFeedStockFactor");
            this.Property(t => t.dblPercentDenaturant).HasColumnName("dblPercentDenaturant");
            this.Property(t => t.intBatchNumber).HasColumnName("intBatchNumber");
            this.Property(t => t.intEndingRinGallons).HasColumnName("intEndingRinGallons");
            this.Property(t => t.intEquivalenceValue).HasColumnName("intEquivalenceValue");
            this.Property(t => t.intFuelTypeId).HasColumnName("intFuelTypeId");
            this.Property(t => t.intRinFeedStockId).HasColumnName("intRinFeedStockId");
            this.Property(t => t.intRinFeedStockUOMId).HasColumnName("intRinFeedStockUOMId");
            this.Property(t => t.intRinFuelId).HasColumnName("intRinFuelId");
            this.Property(t => t.intRinFuelTypeId).HasColumnName("intRinFuelTypeId");
            this.Property(t => t.intRinProcessId).HasColumnName("intRinProcessId");
            this.Property(t => t.ysnDeductDenaturant).HasColumnName("ysnDeductDenaturant");
            this.Property(t => t.ysnRenewableBiomass).HasColumnName("ysnRenewableBiomass");
        }
    }
}
