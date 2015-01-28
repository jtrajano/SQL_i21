using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemLocationMap : EntityTypeConfiguration<tblICItemLocation>
    {
        public tblICItemLocationMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemLocationId);

            // Table & Column Mappings
            this.ToTable("tblICItemLocation");
            this.Property(t => t.dblFreightRate).HasColumnName("dblFreightRate");
            this.Property(t => t.dblLeadTime).HasColumnName("dblLeadTime");
            this.Property(t => t.dblMinOrder).HasColumnName("dblMinOrder");
            this.Property(t => t.dblReorderPoint).HasColumnName("dblReorderPoint");
            this.Property(t => t.dblSuggestedQty).HasColumnName("dblSuggestedQty");
            this.Property(t => t.intAllowNegativeInventory).HasColumnName("intAllowNegativeInventory");
            this.Property(t => t.intBottleDepositNo).HasColumnName("intBottleDepositNo");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intClassId).HasColumnName("intClassId");
            this.Property(t => t.intCostingMethod).HasColumnName("intCostingMethod");
            this.Property(t => t.intCountGroupId).HasColumnName("intCountGroupId");
            this.Property(t => t.intFamilyId).HasColumnName("intFamilyId");
            this.Property(t => t.intFreightMethodId).HasColumnName("intFreightMethodId");
            this.Property(t => t.intShipViaId).HasColumnName("intShipViaId");
            this.Property(t => t.intIssueUOMId).HasColumnName("intIssueUOMId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intItemTypeCode).HasColumnName("intItemTypeCode");
            this.Property(t => t.intItemTypeSubCode).HasColumnName("intItemTypeSubCode");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intMinimumAge).HasColumnName("intMinimumAge");
            this.Property(t => t.intMixMatchId).HasColumnName("intMixMatchId");
            this.Property(t => t.intNegativeInventory).HasColumnName("intNegativeInventory");
            this.Property(t => t.intProductCodeId).HasColumnName("intProductCodeId");
            this.Property(t => t.intReceiveUOMId).HasColumnName("intReceiveUOMId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strCounted).HasColumnName("strCounted");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strPassportFuelId1).HasColumnName("strPassportFuelId1");
            this.Property(t => t.strPassportFuelId2).HasColumnName("strPassportFuelId2");
            this.Property(t => t.strPassportFuelId3).HasColumnName("strPassportFuelId3");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strSerialNoBegin).HasColumnName("strSerialNoBegin");
            this.Property(t => t.strSerialNoEnd).HasColumnName("strSerialNoEnd");
            this.Property(t => t.strVendorCategory).HasColumnName("strVendorCategory");
            this.Property(t => t.ysnApplyBlueLaw1).HasColumnName("ysnApplyBlueLaw1");
            this.Property(t => t.ysnApplyBlueLaw2).HasColumnName("ysnApplyBlueLaw2");
            this.Property(t => t.ysnAutoCalculateFreight).HasColumnName("ysnAutoCalculateFreight");
            this.Property(t => t.ysnCountBySINo).HasColumnName("ysnCountBySINo");
            this.Property(t => t.ysnCountedDaily).HasColumnName("ysnCountedDaily");
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

            this.HasOptional(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICItemLocations)
                .HasForeignKey(p => p.intLocationId);
            this.HasOptional(p => p.vyuAPVendor)
                .WithMany(p => p.tblICItemLocations)
                .HasForeignKey(p => p.intVendorId);
            this.HasOptional(p => p.tblICCategory)
                .WithMany(p => p.tblICItemLocations)
                .HasForeignKey(p => p.intCategoryId);
            this.HasOptional(p => p.tblICCountGroup)
                .WithMany(p => p.tblICItemLocations)
                .HasForeignKey(p => p.intCountGroupId);
        }
    }
}
