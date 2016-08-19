using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ProcessCodeBl : BusinessLayer<tblICRinProcess>, IProcessCodeBl 
    {
        #region Constructor
        public ProcessCodeBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
        public override async Task<BusinessResult<tblICRinProcess>> SaveAsync(bool continueOnConflict)
        {
            var result = await base.SaveAsync(continueOnConflict).ConfigureAwait(false);
            if (result.message.status == Error.UniqueViolation)
            {
                result.message.statusText = "Production Process must be unique.";
            }
            return result;
        }
    }
}
