﻿using System.ComponentModel.DataAnnotations.Schema;
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
            this.Property(t => t.dblCaseQty).HasColumnName("dblCaseQty");
            this.Property(t => t.dblDefaultFull).HasColumnName("dblDefaultFull");
            this.Property(t => t.dblDenaturantPercent).HasColumnName("dblDenaturantPercent");
            this.Property(t => t.dblDepth).HasColumnName("dblDepth");
            this.Property(t => t.dblHeight).HasColumnName("dblHeight");
            this.Property(t => t.dblMixOrder).HasColumnName("dblMixOrder");
            this.Property(t => t.dblStandardPalletRatio).HasColumnName("dblStandardPalletRatio");
            this.Property(t => t.dblTaxExempt).HasColumnName("dblTaxExempt");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight");
            this.Property(t => t.dblWidth).HasColumnName("dblWidth");
            this.Property(t => t.dtmDateShip).HasColumnName("dtmDateShip");
            this.Property(t => t.intAGCategory).HasColumnName("intAGCategory");
            this.Property(t => t.intBrandId).HasColumnName("intBrandId");
            this.Property(t => t.intCaseUOM).HasColumnName("intCaseUOM");
            this.Property(t => t.intDimensionUOMId).HasColumnName("intDimensionUOMId");
            this.Property(t => t.intIngredientTag).HasColumnName("intIngredientTag");
            this.Property(t => t.intInnerUnits).HasColumnName("intInnerUnits");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLayerPerPallet).HasColumnName("intLayerPerPallet");
            this.Property(t => t.intLifeTime).HasColumnName("intLifeTime");
            this.Property(t => t.intManufacturerId).HasColumnName("intManufacturerId");
            this.Property(t => t.intMaterialPackTypeId).HasColumnName("intMaterialPackTypeId");
            this.Property(t => t.intMedicationTag).HasColumnName("intMedicationTag");
            this.Property(t => t.intNMFCId).HasColumnName("intNMFCId");
            this.Property(t => t.intPatronageCategoryId).HasColumnName("intPatronageCategoryId");
            this.Property(t => t.intPhysicalItem).HasColumnName("intPhysicalItem");
            this.Property(t => t.intReceiveLife).HasColumnName("intReceiveLife");
            this.Property(t => t.intRecipeId).HasColumnName("intRecipeId");
            this.Property(t => t.intRINFuelTypeId).HasColumnName("intRINFuelTypeId");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.intTrackingId).HasColumnName("intTrackingId");
            this.Property(t => t.intUnitPerLayer).HasColumnName("intUnitPerLayer");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strBarcodePrint).HasColumnName("strBarcodePrint");
            this.Property(t => t.strCountCode).HasColumnName("strCountCode");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strEPANumber).HasColumnName("strEPANumber");
            this.Property(t => t.strFuelInspectFee).HasColumnName("strFuelInspectFee");
            this.Property(t => t.strGTIN).HasColumnName("strGTIN");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strKeywords).HasColumnName("strKeywords");
            this.Property(t => t.strLeadTime).HasColumnName("strLeadTime");
            this.Property(t => t.strLifeTimeType).HasColumnName("strLifeTimeType");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.strMask1).HasColumnName("strMask1");
            this.Property(t => t.strMask2).HasColumnName("strMask2");
            this.Property(t => t.strMask3).HasColumnName("strMask3");
            this.Property(t => t.strMaterialSizeCode).HasColumnName("strMaterialSizeCode");
            this.Property(t => t.strModelNo).HasColumnName("strModelNo");
            this.Property(t => t.strNACSCategory).HasColumnName("strNACSCategory");
            this.Property(t => t.strRINRequired).HasColumnName("strRINRequired");
            this.Property(t => t.strRotationType).HasColumnName("strRotationType");
            this.Property(t => t.strSpecialCommission).HasColumnName("strSpecialCommission");
            this.Property(t => t.strStatus).HasColumnName("strStatus");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.strUPCNo).HasColumnName("strUPCNo");
            this.Property(t => t.strVolumeRebateGroup).HasColumnName("strVolumeRebateGroup");
            this.Property(t => t.strWICCode).HasColumnName("strWICCode");
            this.Property(t => t.ysnAvailableTM).HasColumnName("ysnAvailableTM");
            this.Property(t => t.ysnCommisionable).HasColumnName("ysnCommisionable");
            this.Property(t => t.ysnDropShip).HasColumnName("ysnDropShip");
            this.Property(t => t.ysnDyedFuel).HasColumnName("ysnDyedFuel");
            this.Property(t => t.ysnExportEDI).HasColumnName("ysnExportEDI");
            this.Property(t => t.ysnExtendPickTicket).HasColumnName("ysnExtendPickTicket");
            this.Property(t => t.ysnHandAddIngredient).HasColumnName("ysnHandAddIngredient");
            this.Property(t => t.ysnHazardMaterial).HasColumnName("ysnHazardMaterial");
            this.Property(t => t.ysnInboundTax).HasColumnName("ysnInboundTax");
            this.Property(t => t.ysnLandedCost).HasColumnName("ysnLandedCost");
            this.Property(t => t.ysnLoadTracking).HasColumnName("ysnLoadTracking");
            this.Property(t => t.ysnMaterialFee).HasColumnName("ysnMaterialFee");
            this.Property(t => t.ysnMSDSRequired).HasColumnName("ysnMSDSRequired");
            this.Property(t => t.ysnOutboundTax).HasColumnName("ysnOutboundTax");
            this.Property(t => t.ysnReceiptCommentRequired).HasColumnName("ysnReceiptCommentRequired");
            this.Property(t => t.ysnRequireCustomerApproval).HasColumnName("ysnRequireCustomerApproval");
            this.Property(t => t.ysnRestrictedChemical).HasColumnName("ysnRestrictedChemical");
            this.Property(t => t.ysnSanitationRequired).HasColumnName("ysnSanitationRequired");
            this.Property(t => t.ysnStockedItem).HasColumnName("ysnStockedItem");
            this.Property(t => t.ysnStrictFIFO).HasColumnName("ysnStrictFIFO");
            this.Property(t => t.ysnTankRequired).HasColumnName("ysnTankRequired");
            this.Property(t => t.ysnTaxable).HasColumnName("ysnTaxable");
            this.Property(t => t.ysnTonnageTax).HasColumnName("ysnTonnageTax");

            this.HasMany(p => p.tblICItemUOMs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemLocationStores)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            
            this.HasMany(p => p.tblICItemPOSCategories)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemPOSSLAs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemManufacturingUOMs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            
            this.HasMany(p => p.tblICItemCertifications)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemContracts)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemCustomerXrefs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemVendorXrefs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemUPCs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);

            this.HasMany(p => p.tblICItemPricings)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemPricingLevels)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemSpecialPricings)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemStocks)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemAccounts)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemNotes)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
        }
    }
}
