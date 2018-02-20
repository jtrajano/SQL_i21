using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using System.Data.SqlClient;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemAddOnBl : BusinessLayer<tblICItemAddOn>, IItemAddOnBl 
    {
        #region Constructor
        public ItemAddOnBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public async Task<GetObjectResult> GetItemAddOns(int intItemId, int intItemUOMId, int intLocationId, decimal? dblQuantity)
        {

            SqlParameter[] param = {
                new SqlParameter("@intItemId", intItemId),
                new SqlParameter("@intItemUOMId", intItemUOMId),
                new SqlParameter("@intLocationId", intLocationId),
                new SqlParameter("@dblQuantity", dblQuantity)
            };

            var sqlSP = "uspICGetItemAddOns @intItemId, @intItemUOMId, @intLocationId, @dblQuantity";
            IEnumerable<uspICGetItemAddOnsDTO> data = await _db.ContextManager.Database.SqlQuery<uspICGetItemAddOnsDTO>(sqlSP, param).ToListAsync();

            return new GetObjectResult()
            {
                data = data,
                total = data.Count()
            };
        }

        public class uspICGetItemAddOnsDTO
        {
            public int intItemAddOnId { get; set; }
            public int? intAddOnItemId { get; set; }
            public string strAddOnItemNo { get; set; }
            public string strAddOnItemDesc { get; set; }
            public string strAddOnType { get; set; }
            public int? intAddOnItemUOMId { get; set; }
            public string strAddOnUOM { get; set; }
            public string strAddOnUOMType { get; set; }
            public decimal? dblAddOnUOMConvFactor { get; set; }
            public decimal? dblItemAddQty { get; set; }

            public int? intComponentItemId { get; set; }
            public string strComponentItemNo { get; set; }
            public string strComponentType { get; set; }
            public string strComponentDescription { get; set; }
            public decimal? dblComponentQuantity { get; set; }
            public decimal? dblAddOnComponentQty { get; set; }
            public int? intComponentUOMId { get; set; }
            public decimal? dblComponentConvFactor { get; set; }
            public string strComponentUOM { get; set; }
            public string strComponentUOMType { get; set; }

            public int? intComponentStockUOMId { get; set; }
            public string strComponentStockUOM { get; set; }
            public string strComponentStockUOMType { get; set; }

            public string strLotTracking { get; set; }
            public string strInventoryTracking { get; set; }
            public string strStatus { get; set; }
            public int? intLocationId { get; set; }
            public int? intItemLocationId { get; set; }
            public int? intSubLocationId { get; set; }
            public int? intCategoryId { get; set; }
            public string strCategoryCode { get; set; }
            public int? intCommodityId { get; set; }
            public string strCommodityCode { get; set; }
            public string strStorageLocationName { get; set; }
            public string strSubLocationName { get; set; }
            public int? intStorageLocationId { get; set; }
            public string strLocationName { get; set; }
            public string strLocationType { get; set; }
            public int? intStockUOMId { get; set; }
            public string strStockUOM { get; set; }
            public string strStockUOMType { get; set; }
            public decimal? dblStockUnitQty { get; set; }
            public string strAllowNegativeInventory { get; set; }
            public int? intCostingMethod { get; set; }
            public string strCostingMethod { get; set; }
            public decimal? dblAmountPercent { get; set; }
            public decimal? dblSalePrice { get; set; }
            public decimal? dblMSRPPrice { get; set; }
            public string strPricingMethod { get; set; }
            public decimal? dblLastCost { get; set; }
            public decimal? dblStandardCost { get; set; }
            public decimal? dblAverageCost { get; set; }
            public decimal? dblEndMonthCost { get; set; }

            public int? intGrossUOMId { get; set; }
            public decimal? dblGrossUOMConvFactor { get; set; }
            public string strGrossUOMType { get; set; }
            public string strGrossUOM { get; set; }
            public string strGrossUPC { get; set; }
            public string strGrossLongUPC { get; set; }

            public decimal? dblDefaultFull { get; set; }
            public bool? ysnAvailableTM { get; set; }
            public decimal? dblMaintenanceRate { get; set; }
            public string strMaintenanceCalculationMethod { get; set; }
            public decimal? dblOverReceiveTolerance { get; set; }
            public decimal? dblWeightTolerance { get; set; }
            public int? intGradeId { get; set; }
            public string strGrade { get; set; }
            public int? intLifeTime { get; set; }
            public string strLifeTimeType { get; set; }
            public string strRequired { get; set; }
            public int? intTonnageTaxUOMId { get; set; }
            public int? intModuleId { get; set; }
            public bool? ysnUseWeighScales { get; set; }
            public bool? ysnLotWeightsRequired { get; set; }
        }
    }
}
