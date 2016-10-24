using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class CertificationBl : BusinessLayer<tblICCertification>, ICertificationBl 
    {
        #region Constructor
        public CertificationBl(IRepository db) : base(db)
        {
            _db = db;
        }

        public override async Task<BusinessResult<tblICCertification>> SaveAsync(bool continueOnConflict)
        {
            var result = await base.SaveAsync(continueOnConflict).ConfigureAwait(false);
            if (result.message.status == Error.UniqueViolation)
            {
                result.message.statusText = "Certification Program must be unique.";
            }
            return result;
        }
        #endregion
    }
}
