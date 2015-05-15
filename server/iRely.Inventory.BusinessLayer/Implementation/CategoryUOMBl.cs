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
    public class CategoryUOMBl : BusinessLayer<tblICCategoryUOM>, ICategoryUOMBl 
    {
        #region Constructor
        public CategoryUOMBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
