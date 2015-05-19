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
    public class ProcessCodeBl : BusinessLayer<tblICRinProcess>, IProcessCodeBl 
    {
        #region Constructor
        public ProcessCodeBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
