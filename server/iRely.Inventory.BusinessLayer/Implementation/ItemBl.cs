using iRely.Common;
using iRely.Inventory.Model;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

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

        private bool IsAccountExist(ICollection<tblICItemAccount> accounts, string accountCategory, string message, out string newMessage)
        {
            var msg = message;
            var category = accounts.FirstOrDefault(p=> p.strAccountCategory == accountCategory);
            if (category == null)
            {
                if (!string.IsNullOrEmpty(message))
                {
                    message += ", ";
                }
                message += accountCategory;

                newMessage = message;
                return false;
            }

            newMessage = message;
            return true;
        }

        public override BusinessResult<tblICItem> Validate(IEnumerable<tblICItem> entities, ValidateAction action)
        {
            var isValid = true;
            var msg = "";
            switch (action)
            {
                case ValidateAction.Post:
                    foreach (tblICItem item in entities)
                    {
                        if (item.intCategoryId == null && item.intCommodityId == null)
                        {
                            var accounts = item.tblICItemAccounts;
                            switch (item.strType)
                            {
                                case "Assembly/Blend":
                                case "Inventory":
                                    isValid = IsAccountExist(accounts, "AP Clearing", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Inventory", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Cost of Goods", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Sales Account", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Inventory In-Transit", msg, out msg);
                                    break;

                                case "Raw Material":
                                    isValid = IsAccountExist(accounts, "AP Clearing", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Inventory", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Cost of Goods", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Sales Account", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Inventory In-Transit", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Work In Progress", msg, out msg);
                                    break;

                                case "Finished Good":
                                    isValid = IsAccountExist(accounts, "Inventory", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Cost of Goods", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Sales Account", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Inventory In-Transit", msg, out msg);
                                    break;

                                case "Other Charge":
                                    isValid = IsAccountExist(accounts, "Other Charge Income", msg, out msg);
                                    isValid = IsAccountExist(accounts, "Other Charge Expense", msg, out msg);
                                    break;

                                case "Non-Inventory":
                                case "Service":
                                case "Software":
                                    isValid = IsAccountExist(accounts, "General", msg, out msg);
                                    break;

                            }
                            goto returnValidate;
                        }
                    }
                    break;
            }

        returnValidate:

            if (isValid)
            {
                msg = "Success";
            }
            else
            {
                msg += " accounts are required.";
            }
            return new BusinessResult<tblICItem>()
            {
                success = isValid,
                message = new MessageResult()
                {
                    statusText = msg,
                    button = "ok",
                    status = Error.OtherException
                }
            };
        }

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
