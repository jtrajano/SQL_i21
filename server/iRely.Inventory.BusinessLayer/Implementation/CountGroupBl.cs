using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class CountGroupBl : BusinessLayer<tblICCountGroup>, ICountGroupBl 
    {
        #region Constructor
        public CountGroupBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<BusinessResult<tblICCountGroup>> SaveAsync(bool continueOnConflict)
        {
            var result = await base.SaveAsync(continueOnConflict).ConfigureAwait(false);
            if (result.message.status == Error.UniqueViolation)
            {
                result.message.statusText = "Count Group must be unique.";
            }
            return result;
        }
    }
}
