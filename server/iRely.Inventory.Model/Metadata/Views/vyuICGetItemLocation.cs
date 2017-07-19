using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetItemLocation
    {
        public int intItemLocationId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public string strDescription { get; set; }
        public int? intCostingMethod { get; set; }
        public string strCostingMethod { get; set; }
        public int? intAllowNegativeInventory { get; set; }
        public string strAllowNegativeInventory { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intIssueUOMId { get; set; }
        public string strIssueUOM { get; set; }
        public int? intReceiveUOMId { get; set; }
        public int? intGrossUOMId { get; set; }
        public string strGrossUOM { get; set; }
        public string strReceiveUOM { get; set; }
        public int? intFamilyId { get; set; }
        public string strFamily { get; set; }
        public int? intClassId { get; set; }
        public string strClass { get; set; }
        public int? intProductCodeId { get; set; }
        public string strPassportFuelId1 { get; set; }
        public string strPassportFuelId2 { get; set; }
        public string strPassportFuelId3 { get; set; }
        public bool? ysnTaxFlag1 { get; set; }
        public bool? ysnTaxFlag2 { get; set; }
        public bool? ysnTaxFlag3 { get; set; }
        public bool? ysnTaxFlag4 { get; set; }
        public bool? ysnPromotionalItem { get; set; }
        public int? intMixMatchId { get; set; }
        public string strPromoItemListId { get; set; }
        public bool? ysnDepositRequired { get; set; }
        public int? intDepositPLUId { get; set; }
        public string strDepositPLU { get; set; }
        public int? intBottleDepositNo { get; set; }
        public bool? ysnSaleable { get; set; }
        public bool? ysnQuantityRequired { get; set; }
        public bool? ysnScaleItem { get; set; }
        public bool? ysnFoodStampable { get; set; }
        public bool? ysnReturnable { get; set; }
        public bool? ysnPrePriced { get; set; }
        public bool? ysnOpenPricePLU { get; set; }
        public bool? ysnLinkedItem { get; set; }
        public string strVendorCategory { get; set; }
        public bool? ysnCountBySINo { get; set; }
        public string strSerialNoBegin { get; set; }
        public string strSerialNoEnd { get; set; }
        public bool? ysnIdRequiredLiquor { get; set; }
        public bool? ysnIdRequiredCigarette { get; set; }
        public int? intMinimumAge { get; set; }
        public bool? ysnApplyBlueLaw1 { get; set; }
        public bool? ysnApplyBlueLaw2 { get; set; }
        public bool? ysnCarWash { get; set; }
        public int? intItemTypeCode { get; set; }
        public string strItemTypeCode { get; set; }
        public int? intItemTypeSubCode { get; set; }
        public bool? ysnAutoCalculateFreight { get; set; }
        public int? intFreightMethodId { get; set; }
        public string strFreightTerm { get; set; }
        public decimal? dblFreightRate { get; set; }
        public int? intShipViaId { get; set; }
        public string strShipVia { get; set; }
        public decimal? dblReorderPoint { get; set; }
        public decimal? dblMinOrder { get; set; }
        public decimal? dblSuggestedQty { get; set; }
        public decimal? dblLeadTime { get; set; }
        public string strCounted { get; set; }
        public int? intCountGroupId { get; set; }
        public string strCountGroup { get; set; }
        public bool? ysnCountedDaily { get; set; }
        public bool? ysnLockedInventory { get; set; }
        public int? intSort { get; set; }
        public string strProductCode { get; set; }

        public tblICItemLocation tblICItemLocation { get; set; }
        public tblSTSubcategoryRegProd tblSTSubcategoryRegProd { get; set; }
    }
}
