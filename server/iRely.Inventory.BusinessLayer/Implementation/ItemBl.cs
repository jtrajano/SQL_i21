﻿using iRely.Common;
using iRely.Inventory.Model;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using IdeaBlade.Linq;
using System;

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
                else if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICItemMotorFuelTax'"))
                {
                    msg = "Motor Fuel Taxes must be unique per Item.";
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
                .Where(p => p.strStatus != "Discontinued")
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
                .Include(p => p.tblICItemPricings).Filter(param, true)
                .Where(p => p.strStatus != "Discontinued");
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        /// <summary>
        /// Get Item Stock UOM Summary
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetItemStockUOMSummary(int? ItemId, int? LocationId, int? SubLocationId, int? StorageLocationId)
        {
            var query = _db.GetQuery<vyuICGetItemStockUOMSummary>()
                    .Where(p=> p.intItemId == ItemId && p.intLocationId == LocationId && p.intSubLocationId == SubLocationId && p.intStorageLocationId == StorageLocationId);
            var data = await query.ToListAsync();

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
        /// Get Bundle Items
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetBundleComponents(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetBundleItem>()
                    .Filter(param, true);
            var data = await query.Execute(param, "intItemBundleId").ToListAsync();

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

        ///// <summary>
        ///// Return Inventory Valuation of Item and some of its details
        ///// </summary>
        ///// <param name="param"></param>
        ///// <returns></returns>
        //public async Task<SearchResult> GetInventoryValuation(GetParameter param)
        //{
        //    var query = _db.GetQuery<vyuICGetInventoryValuation>()
        //        .Filter(param, true);

        //    var sorts = new List<SearchSort>();
        //    sorts.Add(new SearchSort() { property = "intItemId" });
        //    sorts.Add(new SearchSort() { property = "intItemLocationId" });
        //    sorts.Add(new SearchSort() { property = "dtmDate", direction = "DESC" });
        //    sorts.Add(new SearchSort() { property = "intInventoryTransactionId", direction = "ASC" });
        //    sorts.AddRange(param.sort.ToList());
        //    param.sort = sorts;
            
        //    var data = await query.ExecuteProjection(param, "intInventoryValuationKeyId").ToListAsync();

        //    return new SearchResult()
        //    {
        //        data = data.AsQueryable(),
        //        total = await query.CountAsync()
        //    };
        //}

        public async Task<SearchResult> GetInventoryValuation(GetParameter param)
        {
            // Setup the default sort. 
            List<SearchSort> addDefaultSortList = new List<SearchSort>();
            var defaultLocationSort = new SearchSort() { property = "strLocationName", direction = "ASC" }; 
            var defaultItemSort = new SearchSort() { property = "strItemNo", direction = "ASC" };
            var defaultInventoryTransactionId = new SearchSort() { property = "intInventoryTransactionId", direction = "ASC" };

            foreach (var ps in param.sort)
            {
                // Use the direction specified by the caller. 
                if (ps.property.ToLower() == "strlocationname")
                {
                    defaultLocationSort.direction = ps.direction;
                }

                // Use the direction specified by the caller. 
                else if (ps.property.ToLower() == "stritemno")
                {
                    defaultItemSort.direction = ps.direction;
                }

                // Add any additional sorting specified by the caller. 
                else
                {
                    addDefaultSortList.Add(
                        new SearchSort()
                        {
                            direction = ps.direction,
                            property = ps.property
                        }
                    );
                }                
            }

            // Make sure item, location and inv transaction id are the first in the sorting order.
            addDefaultSortList.Insert(0, defaultInventoryTransactionId);
            addDefaultSortList.Insert(0, defaultLocationSort);
            addDefaultSortList.Insert(0, defaultItemSort);
            
            IEnumerable<SearchSort> enDefaultSort = addDefaultSortList;
            var sort = ExpressionBuilder.GetSortSelector(enDefaultSort);
            param.sort = addDefaultSortList;
                              
            // Create a reverse sort
            List<SearchSort> reverseSortList = new List<SearchSort>();
            foreach (var x in enDefaultSort)
            {
                reverseSortList.Add(
                    new SearchSort() { 
                        direction = x.direction.ToLower() == "asc" ? "DESC" : "ASC", 
                        property = x.property
                    }
                ); 
            }
            IEnumerable<SearchSort> enReverseSort = reverseSortList;
            var reverseSort = ExpressionBuilder.GetSortSelector(enReverseSort); 
            var selector = string.IsNullOrEmpty(param.columns) ? ExpressionBuilder.GetSelector<vyuICGetInventoryValuation>() : ExpressionBuilder.GetSelector(param.columns);
            
            // Assemble the query. 
            var query = (
                from v in _db.GetQuery<vyuICGetInventoryValuation>()
                select v
            ).Filter(param, true);                     

            // Initialize the beginning and running balances.     
            decimal? dblBeginningBalance = 0;
            decimal? dblRunningBalance = 0;
            decimal? dblBeginningQty = 0;
            decimal? dblRunningQty = 0;
            string locationFromPreviousPage = ""; 

            // If it is not the starting page, retrieve the previous page data. 
            if (param.start > 0)
            {
                // Get the last location used from the previous page. 
                var previousPage = query.OrderBySelector(sort).Skip(0).Take(param.start.Value).OrderBySelector(reverseSort).FirstOrDefault(); 
                locationFromPreviousPage = previousPage.strLocationName;

                // Get the beginning qty and balances
                dblBeginningBalance += query.OrderBySelector(sort).Skip(0).Take(param.start.Value).Where(w => w.strLocationName == locationFromPreviousPage).Sum(s => s.dblValue);
                dblBeginningQty += query.OrderBySelector(sort).Skip(0).Take(param.start.Value).Where(w => w.strLocationName == locationFromPreviousPage).Sum(s => s.dblQuantity);
            }

            // Get the page. Convert it into a list for the loop below. 
            var paged_data = await query.PagingBySelector(param).ToListAsync();

            // Loop thru the List, calculate, and assign the running qty and balance for each record. 
            string currentLocation = locationFromPreviousPage;
            string lastLocation = locationFromPreviousPage; 
            foreach (var row in paged_data)
            {
                if (row.intInventoryTransactionId != 0)
                {
                    // Check if we need to rest the beginning qty and balance. It will reset if the location changed. 
                    currentLocation = row.strLocationName;
                    if (lastLocation != currentLocation)
                    {
                        // Reset the qty and balances back to zero. 
                        dblBeginningBalance = 0;
                        dblBeginningQty = 0;
                        lastLocation = currentLocation;
                    }

                    // Calculate beginning and running balance
                    row.dblBeginningBalance = dblBeginningBalance;
                    dblRunningBalance = dblBeginningBalance + row.dblValue;
                    row.dblRunningBalance = Convert.ToDecimal(Math.Round(Convert.ToDouble(dblRunningBalance), 2));
                    dblBeginningBalance = dblRunningBalance;

                    // Calculate the beginning and running quantity
                    row.dblBeginningQtyBalance = dblBeginningQty;
                    dblRunningQty = dblBeginningQty + row.dblQuantity;
                    row.dblRunningQtyBalance = dblRunningQty;
                    dblBeginningQty = dblRunningQty;                
                }
            }
            
            return new SearchResult()
            {
                data = paged_data.AsQueryable().Select(selector),
                total = await query.CountAsync()
            };
        }


        /// <summary>
        /// Return Inventory Valuation of Item and some of its details
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetInventoryValuationSummary(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryValuationSummary>()
                        .Filter(param, true);                              

            var sorts = new List<SearchSort>();
            sorts.Add(new SearchSort() { property = "intItemId" });
            sorts.Add(new SearchSort() { property = "intItemLocationId" });
            sorts.AddRange(param.sort.ToList());
            param.sort = sorts;

            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

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
