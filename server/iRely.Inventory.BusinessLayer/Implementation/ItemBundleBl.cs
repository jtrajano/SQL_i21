using iRely.Common;
using System.Data.Entity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using System.Data.SqlClient;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemBundleBl : BusinessLayer<tblICItemBundle>, IItemBundleBl 
    {
        #region Constructor
        public ItemBundleBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion


        #region Custom Get Methods
        //public async Task<GetObjectResult> GetBundleComponents(GetParameter param, int intBundleItemId, int intLocationId)
        //{
        //    var query = _db.GetQuery<vyuICGetBundleItemStock>().Filter(param, true).Where(w => w.intBundleItemId == intBundleItemId && w.intLocationId == intLocationId);
        //    var key = Methods.GetPrimaryKey<vyuICGetBundleItemStock>(_db.ContextManager);

        //    return new GetObjectResult()
        //    {
        //        data = await query.Execute(param, key, "DESC").ToListAsync(param.cancellationToken).ConfigureAwait(false),
        //        total = await query.CountAsync(param.cancellationToken)
        //    };
        //}


        public async Task<GetObjectResult> GetBundleComponents(int intItemId, int intItemUOMId, int intLocationId, decimal? dblQuantity)
        {

            SqlParameter[] param = {
                new SqlParameter("@intItemId", intItemId),
                new SqlParameter("@intItemUOMId", intItemUOMId),
                new SqlParameter("@intLocationId", intLocationId),
                new SqlParameter("@dblQuantity", dblQuantity)
            };

            var sqlSP = "uspICGetBundleComponents @intItemId, @intItemUOMId, @intLocationId, @dblQuantity";
            IEnumerable<uspICGetBundleComponentsDTO> data = await _db.ContextManager.Database.SqlQuery<uspICGetBundleComponentsDTO>(sqlSP, param).ToListAsync();

            return new GetObjectResult()
            {
                data = data,
                total = data.Count()
            };
        }

        #endregion

        #region Data Transfer Objects
        public class uspICGetBundleComponentsDTO
        {
            public int intItemBundleId { get; set; }
            public int? intBundleItemId { get; set; }
            public string strBundleItemNo { get; set; }
            public string strBundleItemDesc { get; set; }
            public string strBundleType { get; set; }
            public int? intBundleItemUOMId { get; set; }
            public string strBundleUOM { get; set; }
            public string strBundleUOMType { get; set; }
            public decimal? dblBundleUOMConvFactor { get; set; }
            public decimal? dblBundleQty { get; set; }

            public decimal? dblMarkUpOrDown { get; set; }
            public DateTime? dtmBeginDate { get; set; }
            public DateTime? dtmEndDate { get; set; }

            public int? intComponentItemId { get; set; }
            public string strComponentItemNo { get; set; }
            public string strComponentType { get; set; }
            public string strComponentDescription { get; set; }
            public decimal? dblComponentQuantity { get; set; }
            public decimal? dblBundleComponentQty { get; set; }
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
            public bool? ysnListBundleSeparately { get; set; }
            public string strRequired { get; set; }
            public int? intTonnageTaxUOMId { get; set; }
            public int? intModuleId { get; set; }
            public bool? ysnUseWeighScales { get; set; }
            public bool? ysnLotWeightsRequired { get; set; }
        }

        #endregion
    }
}
