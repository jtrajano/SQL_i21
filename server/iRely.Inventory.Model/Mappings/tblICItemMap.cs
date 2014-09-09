using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemMap : EntityTypeConfiguration<tblICItem>
    {
        public tblICItemMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemId);

            // Table & Column Mappings
            this.ToTable("tblICItem");
            this.Property(t => t.dblFreightRate).HasColumnName("dblFreightRate");
            this.Property(t => t.dblRINDenaturantPercentage).HasColumnName("dblRINDenaturantPercentage");
            this.Property(t => t.dblTMPercentFull).HasColumnName("dblTMPercentFull");
            this.Property(t => t.intBrandId).HasColumnName("intBrandId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intClassId).HasColumnName("intClassId");
            this.Property(t => t.intCostingMethodId).HasColumnName("intCostingMethodId");
            this.Property(t => t.intFeedIngredientTag).HasColumnName("intFeedIngredientTag");
            this.Property(t => t.intFeedMedicationTag).HasColumnName("intFeedMedicationTag");
            this.Property(t => t.intFeedMixOrder).HasColumnName("intFeedMixOrder");
            this.Property(t => t.intFreightMethodId).HasColumnName("intFreightMethodId");
            this.Property(t => t.intFreightVendorId).HasColumnName("intFreightVendorId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemTypeId).HasColumnName("intItemTypeId");
            this.Property(t => t.intManufacturerId).HasColumnName("intManufacturerId");
            this.Property(t => t.intPatronageId).HasColumnName("intPatronageId");
            this.Property(t => t.intPhysicalItem).HasColumnName("intPhysicalItem");
            this.Property(t => t.intRINFuelType).HasColumnName("intRINFuelType");
            this.Property(t => t.intStatusId).HasColumnName("intStatusId");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
            this.Property(t => t.strBarCodeIndicator).HasColumnName("strBarCodeIndicator");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strEPANumber).HasColumnName("strEPANumber");
            this.Property(t => t.strFeedLotTracking).HasColumnName("strFeedLotTracking");
            this.Property(t => t.strFeedRebateGroup).HasColumnName("strFeedRebateGroup");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strModelNo).HasColumnName("strModelNo");
            this.Property(t => t.strPOSDescription).HasColumnName("strPOSDescription");
            this.Property(t => t.strRINFuelInspectFee).HasColumnName("strRINFuelInspectFee");
            this.Property(t => t.strRINRequired).HasColumnName("strRINRequired");
            this.Property(t => t.ysnAutoCalculateFreight).HasColumnName("ysnAutoCalculateFreight");
            this.Property(t => t.ysnDyedFuel).HasColumnName("ysnDyedFuel");
            this.Property(t => t.ysnExportEDI).HasColumnName("ysnExportEDI");
            this.Property(t => t.ysnExtendOnPickTicket).HasColumnName("ysnExtendOnPickTicket");
            this.Property(t => t.ysnFeedHandAddIngredients).HasColumnName("ysnFeedHandAddIngredients");
            this.Property(t => t.ysnFeedLoadTracking).HasColumnName("ysnFeedLoadTracking");
            this.Property(t => t.ysnFeedTonnageTax).HasColumnName("ysnFeedTonnageTax");
            this.Property(t => t.ysnHazardMaterial).HasColumnName("ysnHazardMaterial");
            this.Property(t => t.ysnInboundTax).HasColumnName("ysnInboundTax");
            this.Property(t => t.ysnMaterialFee).HasColumnName("ysnMaterialFee");
            this.Property(t => t.ysnMSDSRequired).HasColumnName("ysnMSDSRequired");
            this.Property(t => t.ysnOutboundTax).HasColumnName("ysnOutboundTax");
            this.Property(t => t.ysnRestrictedChemical).HasColumnName("ysnRestrictedChemical");
            this.Property(t => t.ysnStockedItem).HasColumnName("ysnStockedItem");
            this.Property(t => t.ysnTMAvailable).HasColumnName("ysnTMAvailable");
            this.Property(t => t.ysnTMTankRequired).HasColumnName("ysnTMTankRequired");
        }
    }
}
