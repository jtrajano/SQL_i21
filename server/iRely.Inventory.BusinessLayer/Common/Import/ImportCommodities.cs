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
    public class ImportCommodities : ImportDataLogic<tblICCommodity>
    {
        public ImportCommodities(DbContext context, byte[] data) : base(context, data)
        {
        }
        protected override string[] GetRequiredFields()
        {
            return new string[] { "commodity code" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intCommodityId";
        }

        public override int GetPrimaryKeyValue(tblICCommodity entity)
        {
            return entity.intCommodityId;
        }

        protected override Expression<Func<tblICCommodity, bool>> GetUniqueKeyExpression(tblICCommodity entity)
        {
            return e => e.strCommodityCode == entity.strCommodityCode;
        }

        public override tblICCommodity Process(CsvRecord record)
        {
            var entity = new tblICCommodity();
            var valid = true;

            valid = SetText(record, "Commodity Code", e => entity.strCommodityCode = e, required: true);
            SetText(record, "Description", e => entity.strDescription = e, required: false);
            SetBoolean(record, "Exchange Traded", e => entity.ysnExchangeTraded = e);
            SetDecimal(record, "Price Checks Min", e => entity.dblPriceCheckMin = e);
            SetDecimal(record, "Price Checks Max", e => entity.dblPriceCheckMax = e);
            SetText(record, "Checkoff Tax Desc", e => entity.strCheckoffTaxDesc = e);
            SetFixedLookup(record, "Checkoff All States", e => entity.strCheckoffAllState = e, states);
            SetText(record, "Insurance Tax Desc", e => entity.strInsuranceTaxDesc = e);
            SetFixedLookup(record, "Insurance All States", e => entity.strInsuranceAllState = e, states);
            SetDate(record, "Crop End Date Current", e => entity.dtmCropEndDateCurrent = e);
            SetDate(record, "Crop End Date New", e => entity.dtmCropEndDateNew = e);
            SetText(record, "Edi Code", e => entity.strEDICode = e);
            SetInteger(record, "Decimals On Dpr", e => entity.intDecimalDPR = e);

            if (valid)
                return entity;

            return null;
        }

        public override void Initialize()
        {
            base.Initialize();
            AddPipe(new ScheduleStorePipe(context, ImportResult));
            AddPipe(new DiscountPipe(context, ImportResult));
            AddPipe(new ScaleAutoDistPipe(context, ImportResult));
            AddPipe(new FutureMarketPipe(context, ImportResult));
        }

        class ScheduleStorePipe : CsvPipe<tblICCommodity>
        {
            public ScheduleStorePipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICCommodity Process(tblICCommodity input)
            {
                var value = GetFieldValue("Default Schedule Store", "");
                if (string.IsNullOrEmpty(value)) return input;
                var param = new System.Data.SqlClient.SqlParameter("@intCommodityId", input.intCommodityId);
                var param2 = new System.Data.SqlClient.SqlParameter("@strScheduleId", value);
                param.DbType = System.Data.DbType.Int32;
                param2.DbType = System.Data.DbType.String;
                var query = @"SELECT s.[intStorageScheduleRuleId], s.[strScheduleId]
                                    FROM [dbo].[vyuGRGetStorageSchedule] s 
                                    WHERE s.[intCommodity] = @intCommodityId AND s.[strScheduleId] = @strScheduleId";
                IEnumerable<DefaultStorageStore> storageStores = Context.Database.SqlQuery<DefaultStorageStore>(query, param, param2);
                try
                {
                    DefaultStorageStore store = storageStores.First();

                    if (store != null)
                        input.intScheduleStoreId = store.intStorageScheduleRuleId;
                    else
                    {
                        var msg = new ImportDataMessage()
                        {
                            Column = "Default Schedule Store",
                            Row = Record.RecordNo,
                            Type = Constants.TYPE_WARNING,
                            Status = Constants.STAT_FAILED,
                            Action = Constants.ACTION_SKIPPED,
                            Exception = null,
                            Value = value,
                            Message = $"Can't find Default Schedule Store for {value}.",
                        };
                        Result.AddWarning(msg);
                        return null;
                    }
                }
                catch (Exception)
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Default Schedule Store",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_WARNING,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = value,
                        Message = $"Can't find Default Schedule Store for {value}.",
                    };
                    Result.AddWarning(msg);
                    return null;
                }

                return input;
            }
        }

        class DiscountPipe : CsvPipe<tblICCommodity>
        {
            public DiscountPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICCommodity Process(tblICCommodity input)
            {
                var value = GetFieldValue("Discount", "");
                if (string.IsNullOrEmpty(value)) return input;
                var param = new System.Data.SqlClient.SqlParameter("@strDiscountId", value);
                param.DbType = System.Data.DbType.String;
                var query = @"SELECT intDiscountId, intCurrencyId, strDiscountId, strDiscountDescription, ysnDiscountIdActive 
                                FROM tblGRDiscountId 
                                WHERE [strDiscountId] = @strDiscountId";

                IEnumerable<DiscountId> discountIds = Context.Database.SqlQuery<DiscountId>(query, param);
                try
                {
                    DiscountId discountId = discountIds.First();

                    if (discountId != null)
                        input.intScheduleDiscountId = discountId.intDiscountId;
                    else
                    {
                        var msg = new ImportDataMessage()
                        {
                            Column = "Discount",
                            Row = Record.RecordNo,
                            Type = Constants.TYPE_WARNING,
                            Status = Constants.STAT_FAILED,
                            Action = Constants.ACTION_SKIPPED,
                            Exception = null,
                            Value = value,
                            Message = $"Can't find Discount Id {value}.",
                        };
                        Result.AddWarning(msg);
                    }
                }
                catch (Exception)
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Discount",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_WARNING,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = value,
                        Message = $"Can't find Discount Id {value}.",
                    };
                    Result.AddWarning(msg);
                }

                return input;
            }
        }

        class ScaleAutoDistPipe : CsvPipe<tblICCommodity>
        {
            public ScaleAutoDistPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICCommodity Process(tblICCommodity input)
            {
                var value = GetFieldValue("Scale Auto Dist Default", "");
                if (string.IsNullOrEmpty(value)) return input;

                var query = @"DECLARE @Max INT
                            SELECT @Max = MAX(intStorageScheduleTypeId) FROM tblGRStorageType

                            SELECT x.intStorageScheduleTypeId, x.strStorageTypeCode, x.strStorageTypeDescription
                            FROM (
	                            SELECT st.intStorageScheduleTypeId, st.strStorageTypeCode, st.strStorageTypeDescription
	                            FROM tblGRStorageType st
	                            UNION ALL
	                            SELECT @Max + 1 intStorageScheduleTypeId, 'CNT' strStorageTypeCode, 'Contract' strStorageTypeDescription
	                            UNION ALL
	                            SELECT @Max + 2 intStorageScheduleTypeId, 'SPT' strStorageTypeCode, 'Spot Sale' strStorageTypeDescription
	                            UNION ALL
	                            SELECT @Max + 3 intStorageScheduleTypeId, 'SPL' strStorageTypeCode, 'Split' strStorageTypeDescription
	                            UNION ALL
	                            SELECT @Max + 4 intStorageScheduleTypeId, 'HLD' strStorageTypeCode, 'Hold' strStorageTypeDescription
	                            UNION ALL
	                            SELECT @Max + 5 intStorageScheduleTypeId, 'LOD' strStorageTypeCode, 'Load' strStorageTypeDescription
                            ) x
                            WHERE x.strStorageTypeCode = @strStorageTypeCode";
                var param = new System.Data.SqlClient.SqlParameter("@strStorageTypeCode", value);
                param.DbType = System.Data.DbType.String;
                IEnumerable<ScaleAutoDist> dists = Context.Database.SqlQuery<ScaleAutoDist>(query, param);
                try
                {
                    ScaleAutoDist dist = dists.First();

                    if (dist != null)
                        input.intScaleAutoDistId = dist.intStorageScheduleTypeId;
                    else
                    {
                        var msg = new ImportDataMessage()
                        {
                            Column = "Scale Auto Dist Default",
                            Row = Record.RecordNo,
                            Type = Constants.TYPE_WARNING,
                            Status = Constants.STAT_FAILED,
                            Action = Constants.ACTION_SKIPPED,
                            Exception = null,
                            Value = value,
                            Message = $"Invalid value for Scale Auto Dist Default: {value}.",
                        };
                        Result.AddWarning(msg);
                    }
                }
                catch (Exception)
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Scale Auto Dist Default",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_WARNING,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = value,
                        Message = $"Invalid value for Scale Auto Dist Default: {value}.",
                    };
                    Result.AddWarning(msg);
                }
                return input;
            }
        }

        class FutureMarketPipe : CsvPipe<tblICCommodity>
        {
            public FutureMarketPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICCommodity Process(tblICCommodity input)
            {
                var value = GetFieldValue("Default Future Market", "");
                if (string.IsNullOrEmpty(value)) return input;
                var query = @"SELECT intFutureMarketId, strFutMarketName, strFutSymbol, intFutMonthsToOpen
                                FROM tblRKFutureMarket
                                WHERE strFutMarketName = @strFutMarketName";
                var param = new System.Data.SqlClient.SqlParameter("@strFutMarketName", value);
                param.DbType = System.Data.DbType.String;
                IEnumerable<FutureMarket> markets = Context.Database.SqlQuery<FutureMarket>(query, param);
                try
                {
                    FutureMarket market = markets.First();

                    if (market != null)
                        input.intFutureMarketId = market.intFutureMarketId;
                    else
                    {
                        var msg = new ImportDataMessage()
                        {
                            Column = "Default Future Market",
                            Row = Record.RecordNo,
                            Type = Constants.TYPE_WARNING,
                            Status = Constants.STAT_FAILED,
                            Action = Constants.ACTION_SKIPPED,
                            Exception = null,
                            Value = value,
                            Message = $"Invalid value for Default Future Market: {value}.",
                        };
                        Result.AddWarning(msg);
                    }
                }
                catch (Exception)
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Default Future Market",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_WARNING,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = value,
                        Message = $"Invalid value for Default Future Market: {value}.",
                    };
                    Result.AddWarning(msg); ;
                }
                return input;
            }
        }

        private class FutureMarket
        {
            public int intFutureMarketId { get; set; }
            public string strFutMarketName { get; set; }
            public string strFutSymbol { get; set; }
            public int intFutMonthsToOpen { get; set; }
        }

        private class DefaultStorageStore
        {
            public int intStorageScheduleRuleId { get; set; }
            public string strScheduleId { get; set; }
            public string strScheduleDescription { get; set; }
        }

        private class DiscountId
        {
            public int intDiscountId { get; set; }
            public int intCurrencyId { get; set; }
            public string strDiscountId { get; set; }
            public string strDiscountDescription { get; set; }
            public bool ysnDiscountIdActive { get; set; }
        }

        private class ScaleAutoDist
        {
            public int intStorageScheduleTypeId { get; set; }
            public string strStorageTypeCode { get; set; }
            public string strStorageTypeDescription { get; set; }
        }

        private string[] states = new string[] {
            "alabama", 
            "alaska",
            "arizona",
            "arkansas",
            "california",
            "colorado",
            "connecticut",
            "delaware",
            "florida",
            "georgia",
            "hawaii",
            "idaho",
            "illinois",
            "indiana",
            "iowa",
            "kansas",
            "kentucky",
            "louisiana",
            "maine",
            "maryland",
            "massachusetts",
            "michigan",
            "minnesota",
            "mississippi",
            "missouri",
            "montana",
            "nebraska",
            "nevada",
            "new hampshire",
            "new jersey",
            "new mexico",
            "new york",
            "north carolina",
            "north dakota",
            "ohio",
            "oklahoma",
            "oregon",
            "pennsylvania",
            "rhode island",
            "south carolina",
            "south dakota",
            "tennessee",
            "texas",
            "utah",
            "vermont",
            "virginia",
            "washington",
            "west virginia",
            "wisconsin",
            "wyoming"
        };
    }
}
