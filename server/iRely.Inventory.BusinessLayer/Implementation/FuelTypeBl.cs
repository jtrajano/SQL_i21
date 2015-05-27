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
    public class FuelTypeBl : BusinessLayer<tblICFuelType>, IFuelTypeBl 
    {
        #region Constructor
        public FuelTypeBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICFuelType>()
               .Include(p => p.RinProcess)
               .Include(p => p.RinFuelCategory)
               .Include(p => p.RinFuel)
               .Include(p => p.RinFeedStock)
               .Include(p => p.RinFeedStockUOM)
               .Select(p => new FuelTypeVM
               {
                    intFuelTypeId = p.intFuelTypeId,
                    strRinFuelTypeCodeId = p.RinFuelCategory.strRinFuelCategoryCode,
                    strRinFeedStockId = p.RinFeedStock.strRinFeedStockCode,
                    strRinFuelId = p.RinFuel.strRinFuelCode,
                    strRinProcessId = p.RinProcess.strRinProcessCode
               })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intFuelTypeId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
