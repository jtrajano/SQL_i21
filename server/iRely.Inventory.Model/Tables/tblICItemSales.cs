using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemSales : BaseEntity
    {
        public int intItemSalesId { get; set; }
        public int intItemId { get; set; }
        public int intPatronageCategoryId { get; set; }
        public int intTaxClassId { get; set; }
        public bool ysnStockedItem { get; set; }
        public bool ysnDyedFuel { get; set; }
        public string strBarcodePrint { get; set; }
        public bool ysnMSDSRequired { get; set; }
        public string strEPANumber { get; set; }
        public bool ysnInboundTax { get; set; }
        public bool ysnOutboundTax { get; set; }
        public bool ysnRestrictedChemical { get; set; }
        public bool ysnTankRequired { get; set; }
        public bool ysnAvailableTM { get; set; }
        public double dblDefaultFull { get; set; }
        public string strFuelInspectFee { get; set; }
        public string strRINRequired { get; set; }
        public int intRINFuelTypeId { get; set; }
        public double dblDenaturantPercent { get; set; }
        public bool ysnTonnageTax { get; set; }
        public bool ysnLoadTracking { get; set; }
        public double dblMixOrder { get; set; }
        public bool ysnHandAddIngredient { get; set; }
        public int intMedicationTag { get; set; }
        public int intIngredientTag { get; set; }
        public string strVolumeRebateGroup { get; set; }
        public int intPhysicalItem { get; set; }
        public bool ysnExtendPickTicket { get; set; }
        public bool ysnExportEDI { get; set; }
        public bool ysnHazardMaterial { get; set; }
        public bool ysnMaterialFee { get; set; }

        public tblICItem tblICItem { get; set; }
    }
}
