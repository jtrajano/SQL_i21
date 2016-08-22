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
    public class ItemLocationBl : BusinessLayer<tblICItemLocation>, IItemLocationBl 
    {
        #region Constructor
        public ItemLocationBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemLocation>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public async Task<SearchResult> GetItemLocationViews(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemLocation>()
                .Include(p => p.tblSTSubcategoryRegProd)
                .Filter(param, true);

            var data = await query.ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public SaveResult CheckCostingMethod(int ItemId, int ItemLocationId, int CostingMethod)
        {
            SaveResult saveResult = new SaveResult();
            var msg = "";

                //Check if Stock exists for the item
                var query = _db.GetQuery<tblICItemStock>()
                         .Where(t => t.intItemId == ItemId && t.intItemLocationId == ItemLocationId && t.dblUnitOnHand > 0);

                var totalItemWithStock = query.Count();

                //Stock Exists
                if (totalItemWithStock > 0)
                {
                    //Check if Costing Method is Changed
                    var query2 = _db.GetQuery<tblICItemLocation>()
                         .Where(t => t.intItemLocationId == ItemLocationId && t.intCostingMethod != CostingMethod);

                    var totalItemCostingMethodChange = query2.Count();

                    //Costing Method is Changed
                    if (totalItemCostingMethodChange > 0)
                    {
                        msg += "Costing Method cannot be changed due to Stock already Exists.";

                        saveResult.HasError = true;
                    }

                    //Costing Method is not changed
                    else
                    {
                        msg = "success";
                        saveResult.HasError = false;
                    }

                }

                //Stock Don't Exists
                else
                {
                    msg = "success";
                    saveResult.HasError = false;
                }

                return saveResult;
        }

        public override BusinessResult<tblICItemLocation> Validate(IEnumerable<tblICItemLocation> entities, ValidateAction action)
        {
            var msg = "";
            var isValid = false;

            foreach (tblICItemLocation item in entities)
            {
                //Check if Stock exists for the item
                var query = _db.GetQuery<tblICItemStock>()
                         .Where(t => t.intItemId == item.intItemId && t.intItemLocationId == item.intItemLocationId && t.dblUnitOnHand > 0);

                var totalItemWithStock = query.Count();

                //Stock Exists
                if (totalItemWithStock > 0)
                {
                    //Check if Costing Method is Changed
                    var query2 = _db.GetQuery<tblICItemLocation>()
                         .Where(t => t.intItemLocationId == item.intItemLocationId && t.intCostingMethod != item.intCostingMethod);

                    var totalItemCostingMethodChange = query2.Count();

                    //Costing Method is Changed
                    if (totalItemCostingMethodChange > 0)
                    {
                        msg += "Costing Method cannot be changed due to Stock already Exists.";
                        isValid = false;
                    }

                    //Costing Method is not changed
                    else
                    {
                        msg = "success";
                        isValid = true;
                    }
                    
                }

                //Stock Don't Exists
                else
                {
                    msg = "success";
                    isValid = true;
                }
                
            }
            goto returnValidate;
          
        returnValidate:
        return new BusinessResult<tblICItemLocation>()
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


        public override async Task<BusinessResult<tblICItemLocation>> SaveAsync(bool continueOnConflict)
        {
            var result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);
            var msg = result.Exception.Message;

            if (result.HasError)
            {
                if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICItemLocation'"))
                {
                    msg = "Location must be unique per Item.";
                }
            }

            return new BusinessResult<tblICItemLocation>()
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
    }
}
