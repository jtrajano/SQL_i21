using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;


namespace iRely.Inventory.BusinessLayer
{
    public class FuelCodeBl : BusinessLayer<tblICRinFuel>, IFuelCodeBl 
    {
        #region Constructor
        public FuelCodeBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
        public override async Task<BusinessResult<tblICRinFuel>> SaveAsync(bool continueOnConflict)
        {
            var result = await base.SaveAsync(continueOnConflict).ConfigureAwait(false);
            if (result.message.status == Error.UniqueViolation)
            {
                result.message.statusText = "Fuel Code must be unique.";
            }
            return result;
        }

        public override BusinessResult<tblICRinFuel> Validate(IEnumerable<tblICRinFuel> entities, ValidateAction action)
        {
            if (action != ValidateAction.Delete && action != ValidateAction.SyncDelete)
            {
                if (entities.Where(p => string.IsNullOrEmpty(p.strRinFuelCode)).Count() > 0)
                {
                    return new BusinessResult<tblICRinFuel>()
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
