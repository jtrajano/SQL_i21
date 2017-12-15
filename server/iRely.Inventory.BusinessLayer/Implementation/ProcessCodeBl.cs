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
        public ProcessCodeBl(IInventoryRepository db) : base(db)
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

        public override BusinessResult<tblICRinProcess> Validate(IEnumerable<tblICRinProcess> entities, ValidateAction action)
        {
            if (action != ValidateAction.Delete && action != ValidateAction.SyncDelete)
            {
                if (entities.Where(p => string.IsNullOrEmpty(p.strRinProcessCode)).Count() > 0)
                {
                    return new BusinessResult<tblICRinProcess>()
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
