using iRely.Common;
using iRely.GlobalComponentEngine.BusinessLayer;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class LineOfBusinessBl : BusinessLayer<tblICLineOfBusiness>, ILineOfBusinessBl 
    {
        #region Constructor
        public LineOfBusinessBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
