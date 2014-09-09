using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCategory : BaseEntity
    {
        public int intCategoryId { get; set; }
        public int strCategoryCode { get; set; }
        public int strDescription { get; set; }
        public int strLineBusiness { get; set; }
        public int intCatalogGroupId { get; set; }
        public int strCostingMethod { get; set; }
        public int strInventoryTracking { get; set; }
        public double dblStandardQty { get; set; }
        public int intUOMId { get; set; }
        public int strGLDivisionNumber { get; set; }
        public bool ysnSalesAnalysisByTon { get; set; }
        public int strMaterialFee { get; set; }
        public int intMaterialItemId { get; set; }
        public bool ysnAutoCalculateFreight { get; set; }
        public int intFreightItemId { get; set; }
        public bool ysnNonRetailUseDepartment { get; set; }
        public bool ysnReportNetGross { get; set; }
        public bool ysnDepartmentPumps { get; set; }
        public int intConvertPaidOutId { get; set; }
        public bool ysnDeleteRegister { get; set; }
        public bool ysnDepartmentKeyTaxed { get; set; }
        public int intProductCodeId { get; set; }
        public int intFamilyId { get; set; }
        public int intClassId { get; set; }
        public bool ysnFoodStampable { get; set; }
        public bool ysnReturnable { get; set; }
        public bool ysnSaleable { get; set; }
        public bool ysnPrepriced { get; set; }
        public bool ysnIdRequiredLiquor { get; set; }
        public bool ysnIdRequiredCigarette { get; set; }
        public int intMinimumAge { get; set; }
        public int strERPItemClass { get; set; }
        public double dblfeTime { get; set; }
        public double dblBOMItemShrinkage { get; set; }
        public double dblBOMItemUpperTolerance { get; set; }
        public double dblBOMItemLowerTolerance { get; set; }
        public bool ysnScaled { get; set; }
        public bool ysnOutputItemMandatory { get; set; }
        public int strConsumptionMethod { get; set; }
        public int strBOMItemType { get; set; }
        public int strShortName { get; set; }
        public byte[] imgReceiptImage { get; set; }
        public byte[] imgWIPImage { get; set; }
        public byte[] imgFGImage { get; set; }
        public byte[] imgShipImage { get; set; }
        public double dblLaborCost { get; set; }
        public double dblOverHead { get; set; }
        public double dblPercentage { get; set; }
        public int strCostDistributionMethod { get; set; }
        public bool ysnSellable { get; set; }
        public bool ysnYieldAdjustment { get; set; }
    }
}
