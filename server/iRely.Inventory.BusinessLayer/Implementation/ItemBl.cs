using iRely.Common;

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemBl : BusinessLayer<tblICItem>, IItemBl 
    {
        #region Constructor
        public ItemBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<BusinessResult<tblICItem>> SaveAsync(bool continueOnConflict)
        {
            var result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);
            var msg = result.Exception.Message;

            if (result.HasError)
            {
                if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICItemAccount'"))
                {
                    msg = "Account Category must be unique.";
                }
                else if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICItem_strItemNo'"))
                {
                    msg = "Item No must be unique.";
                }
                else if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICItemPricing'"))
                {
                    msg = "Item Pricing must be unique per location.";
                }
                else if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICItemUOM'"))
                {
                    msg = "UOM must be unique per Item.";
                }
            }

            return new BusinessResult<tblICItem>()
            {
                success = !result.HasError,
                message = new MessageResult()
                {
                    statusText = msg,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            };
        }

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetCompactItem>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
            
        }

        /// <summary>
        /// Return compact version of Item and some of its details
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetCompactItems(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetCompactItem>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetAssemblyComponents(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetCompactItem>()
                .Where(p => p.strType == "Inventory" || p.strType == "Raw Material" || p.strType == "Finished Good")
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        /// <summary>
        /// Get Item Stock
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetItemStocks(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemStock>().Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        /// <summary>
        /// Get Stock Tracking Items
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetStockTrackingItems(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemStock>()
                .Where(
                        p => p.strType == "Inventory" ||
                        p.strType == "Assembly/Blend" || 
                        p.strType == "Manufacturing" || 
                        p.strType == "Raw Material" || 
                        p.strType == "Commodity" ||
                        p.strType == "Finished Good" 
                    )
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }


        /// <summary>
        /// Get Item Stock Details
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetItemStockDetails(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemStock>()
                .Include(p => p.tblICItemAccounts)
                .Include(p => p.tblICItemPricings).Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        /// <summary>
        /// Get Assembly Items
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetAssemblyItems(GetParameter param)
        {
            var query = _db.GetQuery<tblICItem>()
                    .Where(p => p.strType == "Assembly/Blend" && p.strLotTracking == "No")
                    .Filter(param, true);
            var data = await query.Execute(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        /// <summary>
        /// Get Assembly Items
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetOtherCharges(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetOtherCharges>()
                    .Filter(param, true);
            var data = await query.Execute(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        /// <summary>
        /// Get Item Commodities
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetItemCommodities(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemCommodity>()
                    .Filter(param, true);
            var data = await query.Execute(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        /// <summary>
        /// Get Item UPC Codes
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetItemUPCs(GetParameter param)
        {
            var query = _db.GetQuery<tblICItemUOM>()
                    .Include(p => p.tblICUnitMeasure)
                    .Where(p => string.IsNullOrEmpty(p.strUpcCode) == false)
                    .Filter(param, true);
            var data = await query.Execute(param, "intItemUOMId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        /// <summary>
        /// Duplicate Item
        /// </summary>
        /// <param name="intItemId">Specify the Item Id of the Item to duplicate</param>
        /// <returns>Returns the Item Id of the newly duplicated Item</returns>
        public int? DuplicateItem(int intItemId)
        {
            int? newItemId = null;

            using (SqlConnection conn = new SqlConnection(_db.ContextManager.Database.Connection.ConnectionString))
            {
                conn.Open();
                using (SqlCommand command = new SqlCommand("uspICDuplicateItem", conn))
                {
                    command.Parameters.Add(new SqlParameter("@ItemId", intItemId));
                    var outParam = new SqlParameter("@NewItemId", newItemId);
                    outParam.Direction = System.Data.ParameterDirection.Output;
                    outParam.DbType = System.Data.DbType.Int32;
                    outParam.SqlDbType = System.Data.SqlDbType.Int;
                    command.Parameters.Add(outParam);
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.ExecuteNonQuery();
                    newItemId = (int)outParam.Value;
                }
                conn.Close();
            }

            return newItemId;
        }
    }
}
