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
    public class CategoryLocationBl : BusinessLayer<tblICCategoryLocation>, ICategoryLocationBl 
    {
        #region Constructor
        public CategoryLocationBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICCategoryLocation>()
               .Include(p => p.tblSMCompanyLocation)
               .Select(p => new CategoryLocationVM
               {
                    intCategoryLocationId = p.intCategoryLocationId,
                    intCategoryId = p.intCategoryId,
                    intLocationId = p.intLocationId,
                    strLocationName = p.tblSMCompanyLocation.strLocationName,
                    strLocationType = p.tblSMCompanyLocation.strLocationType,
                    intCompanyLocationId = p.tblSMCompanyLocation.intCompanyLocationId
               })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intCategoryLocationId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public override async Task<BusinessResult<tblICCategoryLocation>> SaveAsync(bool continueOnConflict)
        {
            var result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);
            var msg = result.Exception.Message;

            if (result.HasError)
            {
                if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICCategoryLocation'"))
                {
                    msg = "Category Location must be unique.";
                }
            }

            return new BusinessResult<tblICCategoryLocation>()
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
