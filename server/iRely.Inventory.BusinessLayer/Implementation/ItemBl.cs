using iRely.Common;
using iRely.GlobalComponentEngine.BusinessLayer;
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

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICItem>()
               .Include(p => p.tblICBrand)
               .Include(p => p.tblICManufacturer)
               .Select(p => new ItemVM
               {
                   intItemId = p.intItemId,
                   strItemNo = p.strItemNo,
                   strType = p.strType,
                   strDescription = p.strDescription,
                   strStatus = p.strStatus,
                   strModelNo = p.strModelNo,
                   strLotTracking = p.strLotTracking,
                   strBrand = p.tblICBrand.strBrandCode,
                   strManufacturer = p.tblICManufacturer.strManufacturer,
                   strTracking = p.strInventoryTracking
               })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param).ToListAsync();

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
            var query = _db.GetQuery<tblICItem>()
                .Include(p => p.tblICBrand)
                .Include(p => p.tblICManufacturer)
                .Select(p => new ItemVM {
                    intItemId = p.intItemId,
                    strItemNo = p.strItemNo,
                    strType = p.strType,
                    strDescription = p.strDescription,
                    strStatus = p.strStatus,
                    strModelNo = p.strModelNo,
                    strLotTracking = p.strLotTracking,
                    strBrand = p.tblICBrand.strBrandCode,
                    strManufacturer = p.tblICManufacturer.strManufacturer,
                    strTracking = p.strInventoryTracking
                })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param).ToListAsync();

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
            var data = await query.ExecuteProjection(param).ToListAsync();

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
            var data = await query.ExecuteProjection(param).ToListAsync();

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
                    .Include("tblICItemAssemblies.AssemblyItem")
                    .Include("tblICItemAssemblies.tblICItemUOM.tblICUnitMeasure")
                    .Where(p => p.strType == "Assembly/Blend" && p.strLotTracking == "No")
                .Filter(param, true);
            var data = await query.ExecuteProjection(param).ToListAsync();

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
