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

            this.HasRequired(p => p.RinFuel)
                .WithMany(p => p.RinFuels)
                .HasForeignKey(p => p.intRinFuelId);

            this.HasRequired(p => p.RinFuelType)
                .WithMany(p => p.RinFuelTypes)
                .HasForeignKey(p => p.intRinFuelTypeId);

            this.HasRequired(p => p.RinProcess)
                .WithMany(p => p.RinProcesses)
                .HasForeignKey(p => p.intRinProcessId);

            this.HasRequired(p => p.RinFeedStock)
                .WithMany(p => p.RinFeedStocks)
                .HasForeignKey(p => p.intRinFeedStockId);

            this.HasRequired(p => p.RinFeedStockUOM)
                .WithMany(p => p.RinFeedStockUOMs)
                .HasForeignKey(p => p.intRinFeedStockUOMId);
        }
    }
}
