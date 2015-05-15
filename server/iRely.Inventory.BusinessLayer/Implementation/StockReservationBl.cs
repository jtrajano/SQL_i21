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
    public class StockReservationBl : BusinessLayer<tblICStockReservation>, IStockReservationBl 
    {
        #region Constructor
        public StockReservationBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
