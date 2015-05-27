using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class DocumentBl : BusinessLayer<tblICDocument>, IDocumentBl 
    {
        #region Constructor
        public DocumentBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
