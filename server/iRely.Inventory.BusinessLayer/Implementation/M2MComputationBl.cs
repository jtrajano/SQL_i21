using iRely.Common;
using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class M2MComputationBl : BusinessLayer<tblICM2MComputation>, IM2MComputationBl
    {
        #region Constructor
        public M2MComputationBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
