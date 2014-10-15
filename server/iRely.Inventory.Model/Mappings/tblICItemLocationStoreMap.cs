using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemLocationStoreMap : EntityTypeConfiguration<tblICItemLocationStore>
    {
        public tblICItemLocationStoreMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemLocationStoreId);

            // Table & Column Mappings
            this.ToTable("tblICItemLocationStore");
            this.Property(t => t.dblFreightRate).HasColumnName("dblFreightRate");
            this.Property(t => t.intBottleDepositNo).HasColumnName("intBottleDepositNo");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intClassId).HasColumnName("intClassId");
            this.Property(t => t.intDefaultUOMId).HasColumnName("intDefaultUOMId");
            this.Property(t => t.intFamilyId).HasColumnName("intFamilyId");
            this.Property(t => t.intFreightMethodId).HasColumnName("intFreightMethodId");
            this.Property(t => t.intFreightVendorId).HasColumnName("intFreightVendorId");
            this.Property(t => t.intFuelTankId).HasColumnName("intFuelTankId");
            this.Property(t => t.intIssueUOMId).HasColumnName("intIssueUOMId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationStoreId).HasColumnName("intItemLocationStoreId");
            this.Property(t => t.intItemTypeCode).HasColumnName("intItemTypeCode");
            this.Property(t => t.intItemTypeSubCode).HasColumnName("intItemTypeSubCode");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intMinimumAge).HasColumnName("intMinimumAge");
            this.Property(t => t.intMixMatchId).HasColumnName("intMixMatchId");
            this.Property(t => t.intReceiveUOMId).HasColumnName("intReceiveUOMId");
            this.Property(t => t.intStoreId).HasColumnName("intStoreId");
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
            this.Property(t => t.strBin).HasColumnName("strBin");
            this.Property(t => t.intCostingMethod).HasColumnName("intCostingMethod");
            this.Property(t => t.strPassportFuelId1).HasColumnName("strPassportFuelId1");
            this.Property(t => t.strPassportFuelId2).HasColumnName("strPassportFuelId2");
            this.Property(t => t.strPassportFuelId3).HasColumnName("strPassportFuelId3");
            this.Property(t => t.strPOSDescription).HasColumnName("strPOSDescription");
            this.Property(t => t.strRow).HasColumnName("strRow");
            this.Property(t => t.strSerialNoBegin).HasColumnName("strSerialNoBegin");
            this.Property(t => t.strSerialNoEnd).HasColumnName("strSerialNoEnd");
            this.Property(t => t.strVendorCategory).HasColumnName("strVendorCategory");
            this.Property(t => t.ysnApplyBlueLaw1).HasColumnName("ysnApplyBlueLaw1");
            this.Property(t => t.ysnApplyBlueLaw2).HasColumnName("ysnApplyBlueLaw2");
            this.Property(t => t.ysnAutoCalculateFreight).HasColumnName("ysnAutoCalculateFreight");
            this.Property(t => t.ysnCountBySINo).HasColumnName("ysnCountBySINo");
            this.Property(t => t.ysnDepositRequired).HasColumnName("ysnDepositRequired");
            this.Property(t => t.ysnFoodStampable).HasColumnName("ysnFoodStampable");
            this.Property(t => t.ysnIdRequiredCigarette).HasColumnName("ysnIdRequiredCigarette");
            this.Property(t => t.ysnIdRequiredLiquor).HasColumnName("ysnIdRequiredLiquor");
            this.Property(t => t.ysnLinkedItem).HasColumnName("ysnLinkedItem");
            this.Property(t => t.ysnOpenPricePLU).HasColumnName("ysnOpenPricePLU");
            this.Property(t => t.ysnPrePriced).HasColumnName("ysnPrePriced");
            this.Property(t => t.ysnPromotionalItem).HasColumnName("ysnPromotionalItem");
            this.Property(t => t.ysnQuantityRequired).HasColumnName("ysnQuantityRequired");
            this.Property(t => t.ysnReturnable).HasColumnName("ysnReturnable");
            this.Property(t => t.ysnSaleable).HasColumnName("ysnSaleable");
            this.Property(t => t.ysnScaleItem).HasColumnName("ysnScaleItem");
            this.Property(t => t.ysnTaxFlag1).HasColumnName("ysnTaxFlag1");
            this.Property(t => t.ysnTaxFlag2).HasColumnName("ysnTaxFlag2");
            this.Property(t => t.ysnTaxFlag3).HasColumnName("ysnTaxFlag3");
            this.Property(t => t.ysnTaxFlag4).HasColumnName("ysnTaxFlag4");
        }
    }
}
