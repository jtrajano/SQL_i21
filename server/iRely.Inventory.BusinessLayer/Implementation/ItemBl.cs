using iRely.Common;
using iRely.Inventory.Model;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using IdeaBlade.Linq;
using System;
using System.ComponentModel.DataAnnotations;

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
                else if (result.BaseException.Message.Contains("The DELETE statement conflicted with the REFERENCE constraint \"FK_tblICItemLocation_tblICUnitMeasure_Issue\""))
                {
                    msg = "UOMs that are used as default Sale UOM in this Item's location(s) cannot be removed. To remove the UOMs, clear the Sale UOMs that were assigned to the Item's location(s).";
                }
                else if (result.BaseException.Message.Contains("The DELETE statement conflicted with the REFERENCE constraint \"FK_tblICItemLocation_tblICUnitMeasure_Receive\""))
                {
                    msg = "UOMs that are used as default Purchase UOM in this Item's location(s) cannot be removed. To remove the UOMs, clear the Purchase UOMs that were assigned to the Item's location(s).";
                }
                else if (result.BaseException.Message.Contains("The DELETE statement conflicted with the REFERENCE constraint \"FK_tblICItemPricing_tblICItemLocation\""))
                {
                    msg = "The location(s) you are trying to remove are being used in Pricing tab.";
                }
                else if (result.BaseException.Message.Contains("The DELETE statement conflicted with the REFERENCE constraint \"FK_tblICInventoryReceiptItem_tblICItemUOM\"."))
                {
                    msg = "Cannot delete this item because it's already used in a receipt.";
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
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
            
        }

        /// <summary>
        /// Return compact version of Item and some of its details
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchCompactItems(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetCompactItem>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchAssemblyComponents(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetCompactItem>()
                .Where(p => p.strType == "Inventory" || p.strType == "Raw Material" || p.strType == "Finished Good")
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// Get Item Stock
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchItemStocks(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemStock>()
                .Where(
                    p => (p.strType == "Inventory" ||
                    p.strType == "Finished Good" ||
                    p.strType == "Raw Material") && p.intLocationId != null
                )
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// Get Stock Tracking Items
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchStockTrackingItems(GetParameter param)
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
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }


        /// <summary>
        /// Get Item Stock Details
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchItemStockDetails(GetParameter param)
        {
            bool excludePhasedOutZeroStockItem = false;
            var el = param.filter.Where(p => p.c == "excludePhasedOutZeroStockItem").Select(p => p.v);
            if (el != null)
            {
                if(el.Count() > 0)
                    bool.TryParse(el.First(), out excludePhasedOutZeroStockItem);
            }

            if (excludePhasedOutZeroStockItem)
            {
                var query = 
                        _db.GetQuery<vyuICGetItemStock>()
                        .Include(p => p.tblICItemAccounts)
                        .Include(p => p.tblICItemPricings).Filter(param, true)
                        .Where(p => 
                            // Use ternary operators. It is translated as CASE WHEN statements in SQL: 
                            true ==
                                (p.strStatus == "Phased Out" && p.dblAvailable <= 0) ? false :
                                (p.strStatus == "Discontinued") ? false : 
                                true
                        );

                var data = await query.ExecuteProjection(param, "strItemNo").ToListAsync();

                return new SearchResult()
                {
                    data = data.AsQueryable(),
                    total = await query.CountAsync(),
					summaryData = await query.ToAggregateAsync(param.aggregates)
                };
            }
            else {
                var query = _db.GetQuery<vyuICGetItemStock>()
                .Include(p => p.tblICItemAccounts)
                .Include(p => p.tblICItemPricings).Filter(param, true)
                .Where(p => p.strStatus != "Discontinued");

                var data = await query.ExecuteProjection(param, "strItemNo").ToListAsync();

            	return new SearchResult()
	            {
    	            data = data.AsQueryable(),
        	        total = await query.CountAsync(),
            	    summaryData = await query.ToAggregateAsync(param.aggregates)
	            };
            }
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
        public async Task<SearchResult> SearchAssemblyItems(GetParameter param)
        {
            var query = _db.GetQuery<tblICItem>()
                    .Where(p => p.strType == "Assembly/Blend" && p.strLotTracking == "No")
                    .Filter(param, true);
            var data = await query.Execute(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// Get Bundle Items
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchBundleComponents(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetBundleItem>()
                    .Filter(param, true);
            var data = await query.Execute(param, "intItemBundleId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// Get Assembly Items
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchOtherCharges(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetOtherCharges>()
                    .Filter(param, true);
            var data = await query.Execute(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// Get Item Commodities
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchItemCommodities(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemCommodity>()
                    .Filter(param, true);
            var data = await query.Execute(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// Get Item UPC Codes
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchItemUPCs(GetParameter param)
        {
            var query = _db.GetQuery<tblICItemUOM>()
                    .Include(p => p.tblICUnitMeasure)
                    .Where(p => string.IsNullOrEmpty(p.strUpcCode) == false)
                    .Filter(param, true);
            var data = await query.Execute(param, "intItemUOMId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<object> GetItemUOMsByType(int? intItemId, string strUnitType)
        {
            var query = @"SELECT DISTINCT um.intUnitMeasureId, um.strUnitMeasure, um.strUnitType, um.strSymbol
                 FROM tblICUnitMeasure um
                  INNER JOIN tblICItemUOM uom ON uom.intUnitMeasureId = um.intUnitMeasureId
                 WHERE uom.intItemId = @intItemId
                  AND um.strUnitType = @strUnitType";

            var param = new  SqlParameter("@intItemId", intItemId);
            var param2 = new SqlParameter("@strUnitType", strUnitType);
            param.DbType = System.Data.DbType.Int32;
            param2.DbType = System.Data.DbType.String;

            var dbSet = _db.ContextManager.Database.SqlQuery<UnitOfMeasure>(query, param, param2);
            var list = await dbSet.ToListAsync();
            return new {
                data = list,
                total = list.Count()
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

        // TODO: Remove as soon the change for IC-2421 is stable enough. 
        //public async Task<SearchResult> GetInventoryValuation(GetParameter param)
        //{
        //    // Setup the default sort. 
        //    List<SearchSort> addDefaultSortList = new List<SearchSort>();
        //    var defaultLocationSort = new SearchSort() { property = "strLocationName", direction = "ASC" }; 
        //    var defaultItemSort = new SearchSort() { property = "strItemNo", direction = "ASC" };
        //    var defaultInventoryTransactionId = new SearchSort() { property = "intInventoryTransactionId", direction = "ASC" };

        //    foreach (var ps in param.sort)
        //    {
        //        // Use the direction specified by the caller. 
        //        if (ps.property.ToLower() == "strlocationname")
        //        {
        //            defaultLocationSort.direction = ps.direction;
        //        }

        //        // Use the direction specified by the caller. 
        //        else if (ps.property.ToLower() == "stritemno")
        //        {
        //            defaultItemSort.direction = ps.direction;
        //        }

        //        // Add any additional sorting specified by the caller. 
        //        else
        //        {
        //            addDefaultSortList.Add(
        //                new SearchSort()
        //                {
        //                    direction = ps.direction,
        //                    property = ps.property
        //                }
        //            );
        //        }                
        //    }

        //    // Make sure item, location and inv transaction id are the first in the sorting order.
        //    addDefaultSortList.Insert(0, defaultInventoryTransactionId);
        //    addDefaultSortList.Insert(0, defaultLocationSort);
        //    addDefaultSortList.Insert(0, defaultItemSort);
            
        //    IEnumerable<SearchSort> enDefaultSort = addDefaultSortList;
        //    var sort = ExpressionBuilder.GetSortSelector(enDefaultSort);
        //    param.sort = addDefaultSortList;
                              
        //    // Create a reverse sort
        //    List<SearchSort> reverseSortList = new List<SearchSort>();
        //    foreach (var x in enDefaultSort)
        //    {
        //        reverseSortList.Add(
        //            new SearchSort() { 
        //                direction = x.direction.ToLower() == "asc" ? "DESC" : "ASC", 
        //                property = x.property
        //            }
        //        ); 
        //    }
        //    IEnumerable<SearchSort> enReverseSort = reverseSortList;
        //    var reverseSort = ExpressionBuilder.GetSortSelector(enReverseSort); 
        //    var selector = string.IsNullOrEmpty(param.columns) ? ExpressionBuilder.GetSelector<vyuICGetInventoryValuation>() : ExpressionBuilder.GetSelector(param.columns);
            
        //    // Assemble the query. 
        //    var query = (
        //        from v in _db.GetQuery<vyuICGetInventoryValuation>()
        //        select v
        //    ).Filter(param, true);                     

        //    // Initialize the beginning and running balances.     
        //    decimal? dblBeginningBalance = 0;
        //    decimal? dblRunningBalance = 0;
        //    decimal? dblBeginningQty = 0;
        //    decimal? dblRunningQty = 0;
        //    string locationFromPreviousPage = ""; 

        //    // If it is not the starting page, retrieve the previous page data. 
        //    if (param.start > 0)
        //    {
        //        // Get the last location used from the previous page. 
        //        var previousPage = query.OrderBySelector(sort).Skip(0).Take(param.start.Value).OrderBySelector(reverseSort).FirstOrDefault(); 
        //        locationFromPreviousPage = previousPage.strLocationName;

        //        // Get the beginning qty and balances
        //        dblBeginningBalance += query.OrderBySelector(sort).Skip(0).Take(param.start.Value).Where(w => w.strLocationName == locationFromPreviousPage).Sum(s => s.dblValue);
        //        dblBeginningQty += query.OrderBySelector(sort).Skip(0).Take(param.start.Value).Where(w => w.strLocationName == locationFromPreviousPage).Sum(s => s.dblQuantity);
        //    }

        //    // Get the page. Convert it into a list for the loop below. 
        //    var paged_data = await query.PagingBySelector(param).ToListAsync();

        //    // Loop thru the List, calculate, and assign the running qty and balance for each record. 
        //    string currentLocation = locationFromPreviousPage;
        //    string lastLocation = locationFromPreviousPage; 
        //    foreach (var row in paged_data)
        //    {
        //        if (row.intInventoryTransactionId != 0)
        //        {
        //            // Check if we need to rest the beginning qty and balance. It will reset if the location changed. 
        //            currentLocation = row.strLocationName;
        //            if (lastLocation != currentLocation)
        //            {
        //                // Reset the qty and balances back to zero. 
        //                dblBeginningBalance = 0;
        //                dblBeginningQty = 0;
        //                lastLocation = currentLocation;
        //            }

        //            // Calculate beginning and running balance
        //            row.dblBeginningBalance = dblBeginningBalance;
        //            dblRunningBalance = dblBeginningBalance + row.dblValue;
        //            row.dblRunningBalance = Convert.ToDecimal(Math.Round(Convert.ToDouble(dblRunningBalance), 2));
        //            dblBeginningBalance = dblRunningBalance;

        //            // Calculate the beginning and running quantity
        //            row.dblBeginningQtyBalance = dblBeginningQty;
        //            dblRunningQty = dblBeginningQty + row.dblQuantity;
        //            row.dblRunningQtyBalance = dblRunningQty;
        //            dblBeginningQty = dblRunningQty;                
        //        }
        //    }
            
        //    return new SearchResult()
        //    {
        //        data = paged_data.AsQueryable().Select(selector),
        //        total = await query.CountAsync()
        //    };
        //}


        public async Task<SearchResult> SearchInventoryValuation(GetParameter param)
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
                    new SearchSort()
                    {
                        direction = x.direction.ToLower() == "asc" ? "DESC" : "ASC",
                        property = x.property
                    }
                );
            }
            IEnumerable<SearchSort> enReverseSort = reverseSortList;
            var reverseSort = ExpressionBuilder.GetSortSelector(enReverseSort);
            var selector = string.IsNullOrEmpty(param.columns) ? ExpressionBuilder.GetSelector<vyuICGetInventoryValuation>() : ExpressionBuilder.GetSelector(param.columns);

            // Assemble the query
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
            string itemFromPreviousPage = "";

            // If it is not the starting page, retrieve the previous page data. 
            if (param.start > 0)
            {
                // Get the last location used from the previous page. 
                var previousPage = query.OrderBySelector(sort).Skip(0).Take(param.start.Value).OrderBySelector(reverseSort).FirstOrDefault();
                locationFromPreviousPage = previousPage.strLocationName;
                itemFromPreviousPage = previousPage.strItemNo;

                // Get the beginning qty and balances
                dblBeginningBalance += query.OrderBySelector(sort).Skip(0).Take(param.start.Value).Where(w => w.strLocationName == locationFromPreviousPage && w.strItemNo == itemFromPreviousPage).Sum(s => s.dblValue);
                dblBeginningQty += query.OrderBySelector(sort).Skip(0).Take(param.start.Value).Where(w => w.strLocationName == locationFromPreviousPage && w.strItemNo == itemFromPreviousPage).Sum(s => s.dblQuantityInStockUOM); // Calculate the Qty using the Stock Qty. 
            }

            // Create the filter for the Prior Balance Query
            List<SearchFilter> priorBalanceFilter = new List<SearchFilter>();
            var itemExists = false;
            var locationExists = false;
            {
                foreach (var pf in param.filter)
                {
                    switch (pf.c.ToString().ToLower())
                    {
                        case "dtmdate":
                            switch (pf.co.ToString().ToLower())
                            {
                                case "gte":
                                case "noteq":
                                    if (pf.v.ToString() != "")
                                    {
                                        priorBalanceFilter.Add(
                                            new SearchFilter()
                                            {
                                                c = pf.c,
                                                v = pf.v,
                                                co = "lt",
                                                cj = pf.cj
                                            }
                                        );
                                    }
                                    break;
                                case "gt":                                
                                    if (pf.v.ToString() != "")
                                    {
                                        priorBalanceFilter.Add(
                                            new SearchFilter()
                                            {
                                                c = pf.c,
                                                v = pf.v,
                                                co = "lte",
                                                cj = pf.cj
                                            }
                                        );
                                    }
                                    break;
                                default:
                                    break;
                            }
                            break;
                        case "stritemno":
                        case "strlocationname":
                            break; 
                        default:
                            priorBalanceFilter.Add(
                                new SearchFilter()
                                {
                                    c = pf.c,
                                    v = pf.v,
                                    co = pf.co,
                                    cj = pf.cj
                                }
                            );
                            break;
                    }
                }
            }

            // Get the page. Convert it into a list for the loop below. 
            var paged_data = await query.PagingBySelector(param).ToListAsync();

            // Loop thru the List, calculate, and assign the running qty and balance for each record. 
            string currentLocation = locationFromPreviousPage;
            string lastLocation = locationFromPreviousPage;
            string currentItem =  itemFromPreviousPage;
            string lastItem = itemFromPreviousPage;
            foreach (var row in paged_data)
            {
                if (row.intInventoryTransactionId != 0)
                {                    
                    currentLocation = row.strLocationName;
                    currentItem = row.strItemNo;
                    if (lastItem == "" || lastLocation == "" || currentItem != lastItem || currentLocation != lastLocation)
                    {
                        // Reset the qty and balances back to zero. 
                        dblBeginningBalance = 0;
                        dblBeginningQty = 0;

                        itemExists = false;
                        locationExists = false;

                        priorBalanceFilter.RemoveAll(p => p.c == "strItemNo" || p.c == "strLocationName"); 
                    }

                    // Check if we need to rest the beginning qty and balance. It will reset if the item or location changes. 
                    if (!itemExists || !locationExists) {
                        if (!itemExists)
                        {
                            priorBalanceFilter.Add(
                                new SearchFilter()
                                {
                                    c = "strItemNo",
                                    v = currentItem,
                                    cj = "And"
                                }
                            );
                            itemExists = true;
                        }

                        if (!locationExists) {
                            priorBalanceFilter.Add(
                                new SearchFilter()
                                {
                                    c = "strLocationName",
                                    v = currentLocation,
                                    cj = "And"
                                }
                            );
                            locationExists = true; 
                        }                        

                        var priorBalanceQuery = GetOpeningBalances(priorBalanceFilter);

                        // Get the beginning qty and balances
                        dblBeginningBalance = priorBalanceQuery.Sum(s => s.dblValue);
                        dblBeginningQty = priorBalanceQuery.Sum(s => s.dblQuantityInStockUOM); // Calculate the Qty using the Stock Qty. 
                        lastLocation = currentLocation;
                        lastItem = currentItem;
                    }

                    // Calculate beginning and running balance
                    row.dblBeginningBalance = dblBeginningBalance;
                    dblRunningBalance = dblBeginningBalance + row.dblValue;
                    row.dblRunningBalance = Convert.ToDecimal(Math.Round(Convert.ToDouble(dblRunningBalance), 2));
                    dblBeginningBalance = dblRunningBalance;

                    // Calculate the beginning and running quantity
                    row.dblBeginningQtyBalance = dblBeginningQty;
                    dblRunningQty = dblBeginningQty + row.dblQuantityInStockUOM; // Calculate the Qty using the Stokc Qty. 
                    row.dblRunningQtyBalance = dblRunningQty;
                    dblBeginningQty = dblRunningQty;
                }
            }

            return new SearchResult()
            {
                data = paged_data.AsQueryable().Select(selector),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        private IQueryable<vyuICGetInventoryValuation> GetOpeningBalances(List<SearchFilter> priorBalanceFilter) {
            var priorBalanceParam = new GetParameter()
            {
                filter = priorBalanceFilter
            };

            // Create a new query for the Prior Balance
            var priorBalanceQuery = (
                from v in _db.GetQuery<vyuICGetInventoryValuation>()
                select v
            ).Filter(priorBalanceParam, true);

            return priorBalanceQuery; 
        }

        /// <summary>
        /// Return Inventory Valuation of Item and some of its details
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchInventoryValuationSummary(GetParameter param)
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
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public class DuplicateItemSaveResult : SaveResult
        {
            public int? Id { get; set; }
        }

        public DuplicateItemSaveResult DuplicateItem(int intItemId)
        {
            int? newItemId = 0;
            var duplicationResult = new DuplicateItemSaveResult();
            try
            {
                var db = (InventoryEntities)_db.ContextManager;
                newItemId = db.DuplicateItem(intItemId);
                var res = _db.Save(false);
                duplicationResult.Id = newItemId;
                duplicationResult.HasError = false;
            }
            catch (Exception ex)
            {
                duplicationResult.BaseException = ex;
                duplicationResult.HasError = true;
                duplicationResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return duplicationResult;
        }

        public SaveResult CheckStockUnit(int ItemId, bool ItemStockUnit, int ItemUOMId)
        {
            SaveResult saveResult = new SaveResult();
            //var msg = "";
           
            //Check if Stock Unit is changed
            var query = _db.GetQuery<tblICItemUOM>()
                .Where(t => t.intItemId == ItemId && t.ysnStockUnit == ItemStockUnit && t.intItemUOMId == ItemUOMId);

            var totalItemChange = query.Count();

            //No Change
            if (totalItemChange > 0)
            {
                //msg = "success";
                saveResult.HasError = false;
            }

            //Changed
            else
            {
                //Check if Transaction exists for the item
                var query2 = _db.GetQuery<vyuICGetInventoryValuation>()
                    .Where(t => t.intItemId == ItemId && t.intInventoryTransactionId != 0);

                var totalItemWithTransaction = query2.Count();

                //With Transaction
                if (totalItemWithTransaction > 0)
                {
                    //msg = "Item has already a transaction.";                    
                    saveResult.Exception = new iRely.Common.ServerException(new Exception("Item has already a transaction."), iRely.Common.Error.OtherException, iRely.Common.Button.Ok); 
                    saveResult.HasError = true;
                }

                //Without Transaction
                else
                {
                    //msg = "success";
                    saveResult.HasError = false;
                }   
            }

            return saveResult;
        }

        public SaveResult CopyItemLocation(int intSourceItemId, string strDestinationItemIds)
        {
            var result = new SaveResult();
            try
            {
                var db = (InventoryEntities)_db.ContextManager;

                if (string.IsNullOrEmpty(strDestinationItemIds))
                {
                    throw new System.ArgumentException("Cannot copy the location without a target item. Please specify the target items.");
                }

                db.CopyItemLocation(intSourceItemId, strDestinationItemIds, iRely.Common.Security.GetEntityId());
                result = _db.Save(false);
                result.HasError = false;
            }
            catch (Exception ex)
            {
                result.BaseException = ex;
                result.HasError = true;
                result.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return result;
        }

        public SaveResult ConvertItemToNewStockUnit(int ItemId, int ItemUOMId)
        {
            var conversionResult = new SaveResult();
            try
            {
                var db = (InventoryEntities)_db.ContextManager;
                db.ConvertItemToNewStockUnit(ItemId, ItemUOMId);
                conversionResult = _db.Save(false);
                conversionResult.HasError = false;
            }
            catch (Exception ex)
            {
                conversionResult.BaseException = ex;
                conversionResult.HasError = true;
                conversionResult.Exception = new ServerException(ex, Error.OtherException, Button.Ok);
            }
            return conversionResult;
        }

        public class UnitOfMeasure
        {
            [Key]
            public int? intUnitMeasureId { get; set; }
            public string strUnitMeasure { get; set; }
            public string strUnitType { get; set; }
            public string strSymbol { get; set; }
        }

        /// <summary>
        /// Return the owners of an item. 
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchItemOwner(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemOwner>()
                .Filter(param, false);

            var data = await query.ExecuteProjection(param, "intItemOwnerId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// Return the sub locations of an item. 
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> SearchItemSubLocations(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemSubLocations>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        /// <summary>
        /// Get Item Motor Fuel Tax 
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetItemMotorFuelTax(GetParameter param)
        {
            var query = (
                from v in _db.GetQuery<vyuICGetItemMotorFuelTax>()
                select v
            ).Filter(param, true);

            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
                //summaryData = await query.ToAggregateAsync(param.aggregates)
            };

        }
    }
}
