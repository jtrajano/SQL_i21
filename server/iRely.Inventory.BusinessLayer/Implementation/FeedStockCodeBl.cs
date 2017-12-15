using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;


namespace iRely.Inventory.BusinessLayer
{
    public class FeedStockCodeBl : BusinessLayer<tblICRinFeedStock>, IFeedStockCodeBl 
    {
        #region Constructor
        public FeedStockCodeBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
        public override async Task<BusinessResult<tblICRinFeedStock>> SaveAsync(bool continueOnConflict)
        {
            var result = await base.SaveAsync(continueOnConflict).ConfigureAwait(false);
            if (result.message.status == Error.UniqueViolation)
            {
                result.message.statusText = "Feed Stock must be unique.";
            }
            return result;
        }

        public override BusinessResult<tblICRinFeedStock> Validate(IEnumerable<tblICRinFeedStock> entities, ValidateAction action)
        {
            if (action != ValidateAction.Delete && action != ValidateAction.SyncDelete)
            {
                if (entities.Where(p => string.IsNullOrEmpty(p.strRinFeedStockCode)).Count() > 0)
                {
                    return new BusinessResult<tblICRinFeedStock>()
                    {
                        data = entities,
                        message = new MessageResult() { button = "Ok", status = Error.OtherException, statusText = "Code must not be blank." },
                        success = false
                    };
                }
            }
            return base.Validate(entities, action);
        }
    }
}
