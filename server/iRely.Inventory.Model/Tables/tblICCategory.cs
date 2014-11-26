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
        public tblICCategory()
        {
            this.tblICCategoryAccounts = new List<tblICCategoryAccount>();
            this.tblICCategoryLocations = new List<tblICCategoryLocation>();
            this.tblICCategoryVendors = new List<tblICCategoryVendor>();
        }

        public int intCategoryId { get; set; }
        public string strCategoryCode { get; set; }
        public string strDescription { get; set; }
        public int? intLineOfBusinessId { get; set; }
        public int? intCatalogGroupId { get; set; }
        public int? intCostingMethod { get; set; }
        public string strInventoryTracking { get; set; }
        public decimal? dblStandardQty { get; set; }
        public int? intUOMId { get; set; }
        public string strGLDivisionNumber { get; set; }
        public bool ysnSalesAnalysisByTon { get; set; }
        public string strMaterialFee { get; set; }
        public int? intMaterialItemId { get; set; }
        public bool ysnAutoCalculateFreight { get; set; }
        public int? intFreightItemId { get; set; }
        public string strERPItemClass { get; set; }
        public decimal? dblLifeTime { get; set; }
        public decimal? dblBOMItemShrinkage { get; set; }
        public decimal? dblBOMItemUpperTolerance { get; set; }
        public decimal? dblBOMItemLowerTolerance { get; set; }
        public bool ysnScaled { get; set; }
        public bool ysnOutputItemMandatory { get; set; }
        public string strConsumptionMethod { get; set; }
        public string strBOMItemType { get; set; }
        public string strShortName { get; set; }
        public byte[] imgReceiptImage { get; set; }
        public byte[] imgWIPImage { get; set; }
        public byte[] imgFGImage { get; set; }
        public byte[] imgShipImage { get; set; }
        public decimal? dblLaborCost { get; set; }
        public decimal? dblOverHead { get; set; }
        public decimal? dblPercentage { get; set; }
        public string strCostDistributionMethod { get; set; }
        public bool ysnSellable { get; set; }
        public bool ysnYieldAdjustment { get; set; }

        public ICollection<tblICCategoryAccount> tblICCategoryAccounts { get; set; }
        public ICollection<tblICCategoryLocation> tblICCategoryLocations { get; set; }
        public ICollection<tblICCategoryVendor> tblICCategoryVendors { get; set; }

        public tblICCatalog tblICCatalog { get; set; }
        public tblICUnitMeasure tblICUnitMeasure { get; set; }
        public ICollection<tblICItemLocation> tblICItemLocations { get; set; }
        public ICollection<tblICStorageLocationCategory> tblICStorageLocationCategories { get; set; }


    }
}
