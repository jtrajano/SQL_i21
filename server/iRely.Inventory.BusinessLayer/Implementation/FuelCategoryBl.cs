using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class FuelCategoryBl : BusinessLayer<tblICRinFuelCategory>, IFuelCategoryBl 
    {
        #region Constructor
        public FuelCategoryBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<BusinessResult<tblICRinFuelCategory>> SaveAsync(bool continueOnConflict)
        {
            var result = await base.SaveAsync(continueOnConflict).ConfigureAwait(false);
            if (result.message.status == Error.UniqueViolation)
            {
                result.message.statusText = "Fuel Category must be unique.";
            }
            return result;
        }

        public override BusinessResult<tblICRinFuelCategory> Validate(IEnumerable<tblICRinFuelCategory> entities, ValidateAction action)
        {
            if (action != ValidateAction.Delete && action != ValidateAction.SyncDelete)
            {
                if (entities.Where(p => string.IsNullOrEmpty(p.strRinFuelCategoryCode)).Count() > 0)
                {
                    return new BusinessResult<tblICRinFuelCategory>()
                    {
                        data = entities,
                        message = new MessageResult() { button = "Ok", status = Error.OtherException, statusText = "Fuel Category must not be blank." },
                        success = false
                    };
                }
            }
            return base.Validate(entities, action);
        }
    }
}
