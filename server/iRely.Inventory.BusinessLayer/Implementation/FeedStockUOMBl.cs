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
    public class FeedStockUOMBl : BusinessLayer<tblICRinFeedStockUOM>, IFeedStockUOMBl 
    {
        #region Constructor
        public FeedStockUOMBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICRinFeedStockUOM>()
               .Include(p => p.tblICUnitMeasure)
               .Select(p => new FeedStockUOMVM
               {
                    intRinFeedStockUOMId = p.intRinFeedStockUOMId,
                    intUnitMeasureId = p.intUnitMeasureId,
                    strRinFeedStockUOMCode = p.strRinFeedStockUOMCode,
                    strUnitMeasure = p.tblICUnitMeasure.strUnitMeasure
               })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intRinFeedStockUOMId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };

        }

        public override async Task<BusinessResult<tblICRinFeedStockUOM>> SaveAsync(bool continueOnConflict)
        {
            var result = await base.SaveAsync(continueOnConflict).ConfigureAwait(false);
            if (result.message.status == Error.OtherException && result.message.statusText.ToString().Contains("Cannot insert duplicate key"))
            {
                result.message.statusText = "Feed Stock UOM must be unique.";
            }
            return result;
        }

        public override BusinessResult<tblICRinFeedStockUOM> Validate(IEnumerable<tblICRinFeedStockUOM> entities, ValidateAction action)
        {
            if (action != ValidateAction.Delete && action != ValidateAction.SyncDelete)
            {
                if (entities.Where(p => string.IsNullOrEmpty(p.strUnitMeasure)).Count() > 0)
                {
                    return new BusinessResult<tblICRinFeedStockUOM>()
                    {
                        data = entities,
                        message = new MessageResult() { button = "Ok", status = Error.OtherException, statusText = "UOM must not be blank." },
                        success = false
                    };
                }
            }
            return base.Validate(entities, action);
        }
    }
}
