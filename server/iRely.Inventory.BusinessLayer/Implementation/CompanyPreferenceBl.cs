using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    // Note: Change null to a specific model class
    public class CompanyPreferenceBl : BusinessLayer<tblICCompanyPreference>, ICompanyPreferenceBl 
    {
        #region Constructor
        public CompanyPreferenceBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
