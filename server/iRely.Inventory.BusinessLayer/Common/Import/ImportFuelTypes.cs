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
    public class ImportFuelTypes : ImportDataLogic<tblICFuelType>
    {
        public ImportFuelTypes(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "fuel category", "feed stock", "fuel code", "production process", "feed stock uom" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intFuelTypeId";
        }

        public override int GetPrimaryKeyValue(tblICFuelType entity)
        {
            return entity.intFuelTypeId;
        }

        protected override Expression<Func<tblICFuelType, bool>> GetUniqueKeyExpression(tblICFuelType entity)
        {
            return e => e.intRinFeedStockId == entity.intRinFeedStockId && e.intRinProcessId == entity.intRinProcessId &&
                e.intRinFeedStockUOMId == entity.intRinFeedStockUOMId && e.intRinFuelCategoryId == entity.intRinFuelCategoryId &&
                e.intRinFuelId == entity.intRinFuelId;
        }

        public override tblICFuelType Process(CsvRecord record)
        {
            var entity = new tblICFuelType();
            var valid = true;

            SetInteger(record, "Batch No", e => entity.intBatchNumber = e);
            SetInteger(record, "Ending Rin Gallons", e => entity.intEndingRinGallons = e);
            SetText(record, "Equivalence Value", e => entity.strEquivalenceValue = e);
            SetDecimal(record, "Feed Stock Factor", e => entity.dblFeedStockFactor = e);
            SetBoolean(record, "Renewable Biomass", e => entity.ysnRenewableBiomass = e);
            SetDecimal(record, "Percent of Denaturant", e => entity.dblPercentDenaturant = e);
            SetBoolean(record, "Deduct Denaturant", e => entity.ysnDeductDenaturant = e);

            var lu = GetFieldValue(record, "Fuel Category");
            valid = SetIntLookupId<tblICRinFuelCategory>(record, "Fuel Category", e => e.strRinFuelCategoryCode == lu, e => e.intRinFuelCategoryId, e => entity.intRinFuelCategoryId = e, required: true);
            lu = GetFieldValue(record, "Feed Stock");
            valid = SetIntLookupId<tblICRinFeedStock>(record, "Feed Stock", e => e.strRinFeedStockCode == lu, e => e.intRinFeedStockId, e => entity.intRinFeedStockId = e, required: true);
            lu = GetFieldValue(record, "Fuel Code");
            valid = SetIntLookupId<tblICRinFuel>(record, "Fueld Code", e => e.strRinFuelCode == lu, e => e.intRinFuelId, e => entity.intRinFuelId = e, required: true);
            lu = GetFieldValue(record, "Production Process");
            valid = SetIntLookupId<tblICRinProcess>(record, "Production Process", e => e.strRinProcessCode == lu, e => e.intRinProcessId, e => entity.intRinProcessId = e, required: true);
            lu = GetFieldValue(record, "Feed Stock UOM");
            valid = SetIntLookupId<tblICRinFeedStockUOM>(record, "Feed Stock UOM", e => e.strRinFeedStockUOMCode == lu, e => e.intRinFeedStockUOMId, e => entity.intRinFeedStockUOMId = e, required: true);

            if (valid)
                return entity;

            return null;
        }

        public override void Initialize()
        {
            base.Initialize();
            AddPipe(new FeedStockUOMPipe(context, ImportResult));
        }

        class FeedStockUOMPipe : CsvPipe<tblICFuelType>
        {
            public FeedStockUOMPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICFuelType Process(tblICFuelType input)
            {
                var value = GetFieldValue("Feed Stock UOM");
                if (string.IsNullOrEmpty(value)) return null;
                var param = new System.Data.SqlClient.SqlParameter("@strUnitMeasure", value);
                param.DbType = System.Data.DbType.String;
                var query = @"SELECT u.intRinFeedStockUOMId, u.intUnitMeasureId, m.strUnitMeasure, m.strSymbol, u.strRinFeedStockUOMCode
                            FROM tblICRinFeedStockUOM u
	                            LEFT OUTER JOIN tblICUnitMeasure m ON u.intUnitMeasureId = m.intUnitMeasureId
                            WHERE m.strUnitMeasure = @strUnitMeasure";

                IEnumerable<FuelType> storageStores = Context.Database.SqlQuery<FuelType>(query, param);
                try
                {
                    FuelType store = storageStores.First();

                    if (store != null)
                        input.intRinFeedStockUOMId = store.intRinFeedStockUOMId;
                    else
                    {
                        var msg = new ImportDataMessage()
                        {
                            Column = "Feed Stock UOM",
                            Row = Record.RecordNo,
                            Type = Constants.TYPE_WARNING,
                            Status = Constants.STAT_FAILED,
                            Action = Constants.ACTION_SKIPPED,
                            Exception = null,
                            Value = value,
                            Message = $"Invalid value for Feed Stock UOM: {value}.",
                        };
                        Result.AddWarning(msg);
                        return null;
                    }
                }
                catch (Exception)
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Feed Stock UOM",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_WARNING,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = value,
                        Message = $"Invalid value for Feed Stock UOM: {value}.",
                    };
                    Result.AddWarning(msg);
                    return null;
                }
                return input;
            }
        }
        
        private class FuelType
        {
            public int intRinFeedStockUOMId { get; set; }
            public int intUnitMeasureId { get; set; }
            public string strUnitMeasure { get; set; }
            public string strSymbol { get; set; }
            public string strRinFeedStockUOMCode { get; set; }
        }
    }
}
