using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetCompactItem
    {
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public string strManufacturer { get; set; }
        public string strBrandCode { get; set; }
        public string strBrandName { get; set; }
        public string strStatus { get; set; }
        public string strModelNo { get; set; }
        public string strTracking { get; set; }
        public string strLotTracking { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodity { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public bool? ysnAccrue { get; set; }
        public bool? ysnMTM { get; set; }
        public int? intM2MComputationId { get; set; }
        public string strM2MComputation { get; set; }
        public bool? ysnPrice { get; set; }
        public string strCostMethod { get; set; }
        public int? intOnCostTypeId { get; set; }
        public string strOnCostType { get; set; }
        public decimal? dblAmount { get; set; }
        public int? intCostUOMId { get; set; }
        public string strCostUOM { get; set; }
        public int? intOriginId { get; set; }
        public string strOriginName { get; set; }
        public string strCostType { get; set; }
        public string strShortName { get; set; }
        public string strRequired { get; set; }
        public bool? ysnBasisContract { get; set; }
        public int? intTonnageTaxUOMId { get; set; }
        public string strTonnageTaxUOM { get; set; }
        public string strSecondaryStatus { get; set; }
        public string strFuelCategory { get; set; }
        public string strPhysicalItem { get; set; }
        public string strPatronageCategory { get; set; }
        public string strPatronageDirect { get; set; }
        public string strGrade { get; set; }
        public string strOrigin { get; set; }
        public string strProductType { get; set; }
        public string strRegion { get; set; }
        public string strSeason { get; set; }
        public string strClass { get; set; }
        public string strProductLine { get; set; }
        public bool? ysnUseWeighScales { get; set; }
        public string strBundleType { get; set; }
        public string strDimensionUOM { get; set; }
        public string strWeightUOM { get; set; }
        public bool? ysnLotWeightsRequired { get; set; }
        public string strMedicationTag { get; set; }
        public string strIngredientTag { get; set; }
        public string strHazmatTag { get; set; }
        public string strMedicationMessage { get; set; }
        public string strIngredientMessage { get; set; }
        public string strHazmatMessage { get; set; }
        public string strMaterialPackUOM { get; set; }
        public int? intMaterialPackTypeId { get; set; }

        public tblICItem tblICItem { get; set; }        
    }
}
