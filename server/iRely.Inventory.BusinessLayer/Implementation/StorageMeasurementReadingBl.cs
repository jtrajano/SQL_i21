using iRely.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class StorageMeasurementReadingBl : BusinessLayer<tblICStorageMeasurementReading>, IStorageMeasurementReadingBl 
    {
        #region Constructor
        public StorageMeasurementReadingBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
