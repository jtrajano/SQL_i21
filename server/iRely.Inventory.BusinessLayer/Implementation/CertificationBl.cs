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
        #endregion
    }
}
