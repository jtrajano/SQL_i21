﻿using iRely.Common;

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
    public class CategoryBl : BusinessLayer<tblICCategory>, ICategoryBl 
    {
        #region Constructor
        public CategoryBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICCategory>()
                .Filter(param, true);
            var data = await query.Execute(param, "intCategoryId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public class DuplicateCategorySaveResult : SaveResult
        {
            public int? Id { get; set; }
        }

        public DuplicateCategorySaveResult DuplicateCategory(int intCategoryId)
        {
            int? newCategoryId = 0;
            var duplicationResult = new DuplicateCategorySaveResult();
            try
            {
                var db = (InventoryEntities)_db.ContextManager;
                newCategoryId = db.DuplicateCategory(intCategoryId);
                var res = _db.Save(false);
                duplicationResult.Id = newCategoryId;
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

        public override async Task<BusinessResult<tblICCategory>> SaveAsync(bool continueOnConflict)
        {
            var result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);
            var msg = result.Exception.Message;

            if (result.HasError)
            {
                if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICCategory_strCategoryCode'"))
                {
                    msg = "Category must be unique.";
                }
                else if (result.BaseException.Message.Contains("Cannot insert the value NULL into column 'intCostingMethod'"))
                {
                    msg = "Please specify a valid Costing Method.";
                }
                else if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICCategoryTax'"))
                {
                    msg = "Tax Class must be unique.";
                }
            }

            return new BusinessResult<tblICCategory>()
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
