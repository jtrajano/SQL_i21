using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ManufacturerBl : BusinessLayer<tblICManufacturer>, IManufacturerBl 
    {
        #region Constructor
        public ManufacturerBl(IRepository db) : base(db)
        {
            _db = db;
        }

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICManufacturer>()
                .Filter(param, true);
            var data = await query.Execute(param, "intManufacturerId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
        #endregion

        public override async Task<BusinessResult<tblICManufacturer>> SaveAsync(bool continueOnConflict)
        {
            var result = await base.SaveAsync(continueOnConflict).ConfigureAwait(false);
            if (result.message.status == Error.UniqueViolation)
            {
                result.message.statusText = "Manufacturer must be unique.";
            }
            return result;
        }
    }
}
