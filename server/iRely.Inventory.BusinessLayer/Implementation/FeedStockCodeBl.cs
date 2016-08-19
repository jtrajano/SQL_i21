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
        public FeedStockCodeBl(IRepository db) : base(db)
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
    }
}
