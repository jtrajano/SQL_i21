using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportFeedStocks : ImportDataLogic<tblICRinFeedStock>
    {
        public ImportFeedStocks(DbContext context, byte[] data) : base(context, data)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "code" };
        }

        protected override Expression<Func<tblICRinFeedStock, bool>> GetUniqueKeyExpression(tblICRinFeedStock entity)
        {
            return (e => e.strRinFeedStockCode == entity.strRinFeedStockCode);
        }

        public override tblICRinFeedStock Process(CsvRecord record)
        {
            var feedStock = new tblICRinFeedStock();
            var valid = true;
            
            valid = SetText(record, "Code", e => feedStock.strRinFeedStockCode = e, true);
            SetText(record, "Description", e => feedStock.strDescription = e, false);
            
            if (valid)
                return feedStock;

            return null;
        }

        protected override string GetPrimaryKeyName()
        {
            return "intRinFeedStockId";
        }

        public override int GetPrimaryKeyValue(tblICRinFeedStock entity)
        {
            return entity.intRinFeedStockId;
        }
    }
}
