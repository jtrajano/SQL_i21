using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemSalesMap : EntityTypeConfiguration<tblICItemSales>
    {
        public tblICItemSalesMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemId);

            // Table & Column Mappings
            this.ToTable("tblICItemSales");
            this.Property(t => t.dblDefaultFull).HasColumnName("dblDefaultFull");
            this.Property(t => t.dblDenaturantPercent).HasColumnName("dblDenaturantPercent");
            this.Property(t => t.dblMixOrder).HasColumnName("dblMixOrder");
            this.Property(t => t.intIngredientTag).HasColumnName("intIngredientTag");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intMedicationTag).HasColumnName("intMedicationTag");
            this.Property(t => t.intPatronageCategoryId).HasColumnName("intPatronageCategoryId");
            this.Property(t => t.intPhysicalItem).HasColumnName("intPhysicalItem");
            this.Property(t => t.intRINFuelTypeId).HasColumnName("intRINFuelTypeId");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.strBarcodePrint).HasColumnName("strBarcodePrint");
            this.Property(t => t.strEPANumber).HasColumnName("strEPANumber");
            this.Property(t => t.strFuelInspectFee).HasColumnName("strFuelInspectFee");
            this.Property(t => t.strRINRequired).HasColumnName("strRINRequired");
            this.Property(t => t.strVolumeRebateGroup).HasColumnName("strVolumeRebateGroup");
            this.Property(t => t.ysnAvailableTM).HasColumnName("ysnAvailableTM");
            this.Property(t => t.ysnDyedFuel).HasColumnName("ysnDyedFuel");
            this.Property(t => t.ysnExportEDI).HasColumnName("ysnExportEDI");
            this.Property(t => t.ysnExtendPickTicket).HasColumnName("ysnExtendPickTicket");
            this.Property(t => t.ysnHandAddIngredient).HasColumnName("ysnHandAddIngredient");
            this.Property(t => t.ysnHazardMaterial).HasColumnName("ysnHazardMaterial");
            this.Property(t => t.ysnInboundTax).HasColumnName("ysnInboundTax");
            this.Property(t => t.ysnLoadTracking).HasColumnName("ysnLoadTracking");
            this.Property(t => t.ysnMaterialFee).HasColumnName("ysnMaterialFee");
            this.Property(t => t.ysnMSDSRequired).HasColumnName("ysnMSDSRequired");
            this.Property(t => t.ysnOutboundTax).HasColumnName("ysnOutboundTax");
            this.Property(t => t.ysnRestrictedChemical).HasColumnName("ysnRestrictedChemical");
            this.Property(t => t.ysnStockedItem).HasColumnName("ysnStockedItem");
            this.Property(t => t.ysnTankRequired).HasColumnName("ysnTankRequired");
            this.Property(t => t.ysnTonnageTax).HasColumnName("ysnTonnageTax");
        }
    }
}
