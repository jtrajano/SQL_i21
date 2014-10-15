using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemLocationStore : BaseEntity
    {
        public int intItemLocationStoreId { get; set; }
        public int intItemId { get; set; }
        public int intLocationId { get; set; }
        public int intStoreId { get; set; }
        public int intVendorId { get; set; }
        public string strPOSDescription { get; set; }
        public int intCostingMethod { get; set; }
        public int intCategoryId { get; set; }
        public string strRow { get; set; }
        public string strBin { get; set; }
        public int intDefaultUOMId { get; set; }
        public int intIssueUOMId { get; set; }
        public int intReceiveUOMId { get; set; }
        public int intFamilyId { get; set; }
        public int intClassId { get; set; }
        public int intFuelTankId { get; set; }
        public string strPassportFuelId1 { get; set; }
        public string strPassportFuelId2 { get; set; }
        public string strPassportFuelId3 { get; set; }
        public bool ysnTaxFlag1 { get; set; }
        public bool ysnTaxFlag2 { get; set; }
        public bool ysnTaxFlag3 { get; set; }
        public bool ysnTaxFlag4 { get; set; }
        public bool ysnPromotionalItem { get; set; }
        public int intMixMatchId { get; set; }
        public bool ysnDepositRequired { get; set; }
        public int intBottleDepositNo { get; set; }
        public bool ysnSaleable { get; set; }
        public bool ysnQuantityRequired { get; set; }
        public bool ysnScaleItem { get; set; }
        public bool ysnFoodStampable { get; set; }
        public bool ysnReturnable { get; set; }
        public bool ysnPrePriced { get; set; }
        public bool ysnOpenPricePLU { get; set; }
        public bool ysnLinkedItem { get; set; }
        public string strVendorCategory { get; set; }
        public bool ysnCountBySINo { get; set; }
        public string strSerialNoBegin { get; set; }
        public string strSerialNoEnd { get; set; }
        public bool ysnIdRequiredLiquor { get; set; }
        public bool ysnIdRequiredCigarette { get; set; }
        public int intMinimumAge { get; set; }
        public bool ysnApplyBlueLaw1 { get; set; }
        public bool ysnApplyBlueLaw2 { get; set; }
        public int intItemTypeCode { get; set; }
        public int intItemTypeSubCode { get; set; }
        public bool ysnAutoCalculateFreight { get; set; }
        public int intFreightMethodId { get; set; }
        public double dblFreightRate { get; set; }
        public int intFreightVendorId { get; set; }

        public tblICItem tblICItem { get; set; }
        
    }
}
