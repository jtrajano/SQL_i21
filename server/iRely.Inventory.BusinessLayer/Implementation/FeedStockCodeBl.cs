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
            SaveResult result = new SaveResult();

            result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);
            if (result.HasError)
            {
                if (result.Exception.Message.Contains("{0} already exists!"))
                {
                    result.HasError = true;
                    result.Exception = new ServerException(new Exception("Feed Stock must be unique"));
                }
            }
            return new BusinessResult<tblICRinFeedStock>()
            {
                success = !result.HasError,
                message = new MessageResult()
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            };
        }
    }
}
