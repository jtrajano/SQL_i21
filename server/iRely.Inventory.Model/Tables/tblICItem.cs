using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItem : BaseEntity
    {
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public int intItemTypeId { get; set; }
        public int intVendorId { get; set; }
        public string strDescription { get; set; }
        public string strPOSDescription { get; set; }
        public int intClassId { get; set; }
        public int intManufacturerId { get; set; }
        public int intBrandId { get; set; }
        public int intStatusId { get; set; }
        public string strModelNo { get; set; }
        public int intCostingMethodId { get; set; }
        public int intCategoryId { get; set; }
        public int intPatronageId { get; set; }
        public int intTaxClassId { get; set; }
        public bool ysnStockedItem { get; set; }
        public bool ysnDyedFuel { get; set; }
        public string strBarCodeIndicator { get; set; }
        public bool ysnMSDSRequired { get; set; }
        public string strEPANumber { get; set; }
        public bool ysnInboundTax { get; set; }
        public bool ysnOutboundTax { get; set; }
        public bool ysnRestrictedChemical { get; set; }
        public bool ysnTMTankRequired { get; set; }
        public bool ysnTMAvailable { get; set; }
        public double dblTMPercentFull { get; set; }
        public string strRINFuelInspectFee { get; set; }
        public string strRINRequired { get; set; }
        public int intRINFuelType { get; set; }
        public double dblRINDenaturantPercentage { get; set; }
        public bool ysnFeedTonnageTax { get; set; }
        public string strFeedLotTracking { get; set; }
        public bool ysnFeedLoadTracking { get; set; }
        public int intFeedMixOrder { get; set; }
        public bool ysnFeedHandAddIngredients { get; set; }
        public int intFeedMedicationTag { get; set; }
        public int intFeedIngredientTag { get; set; }
        public string strFeedRebateGroup { get; set; }
        public int intPhysicalItem { get; set; }
        public bool ysnExtendOnPickTicket { get; set; }
        public bool ysnExportEDI { get; set; }
        public bool ysnHazardMaterial { get; set; }
        public bool ysnMaterialFee { get; set; }
        public bool ysnAutoCalculateFreight { get; set; }
        public int intFreightMethodId { get; set; }
        public double dblFreightRate { get; set; }
        public int intFreightVendorId { get; set; }

        public ICollection<tblICCategory> CategoryFrieghtItems { get; set; }
        public ICollection<tblICCategory> CategoryMaterialItems { get; set; }
    }
}
