using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportCommodities : ImportDataLogic<tblICCommodity>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "commodity code" };
        }

        protected override tblICCommodity ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICCommodity fc = new tblICCommodity();
            bool valid = true;

            for (var i = 0; i < fieldCount; i++)
            {
                //if (!valid)
                //    break;
                string header = headers[i];
                string value = csv[header];

                string h = header.ToLower().Trim();
                int? lu = null;
                bool inserted = false;

                switch (h)
                {
                    case "commodity code":
                        if (!SetText(value, del => fc.strCommodityCode = del, "Commodity Code", dr, header, row, true))
                            valid = false;
                        break;
                    case "description":
                        fc.strDescription = value;
                        break;
                    case "exchange traded":
                        SetBoolean(value, del => fc.ysnExchangeTraded = del);
                        break;
                    case "consolidate factor":
                        SetDecimal(value, del => fc.dblConsolidateFactor = del, "Consolidate Factor", dr, header, row);
                        break;
                    case "fx exposure":
                        SetBoolean(value, del => fc.ysnFXExposure = del);
                        break;
                    case "price checks min":
                        SetDecimal(value, del => fc.dblPriceCheckMin = del, "Price Checks Min", dr, header, row);
                        break;
                    case "price checks max":
                        SetDecimal(value, del => fc.dblPriceCheckMax = del, "Price Checks Max", dr, header, row);
                        break;
                    case "checkoff tax desc":
                        fc.strCheckoffTaxDesc = value;
                        break;
                    case "checkoff all states":
                        if (states.Contains(value.Trim().ToLower()))
                            fc.strCheckoffAllState = value;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Invalid Checkoff All States: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "insurance tax desc":
                        fc.strInsuranceTaxDesc = value;
                        break;
                    case "insurance all states":
                        if (states.Contains(value.Trim().ToLower()))
                            fc.strInsuranceAllState = value;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Invalid Insurance All States: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "crop end date current":
                        SetDate(value, del => fc.dtmCropEndDateCurrent = del, "Crop End Date Current", dr, header, row);
                        break;
                    case "crop end date new":
                        SetDate(value, del => fc.dtmCropEndDateNew = del, "Crop End Date New", dr, header, row);
                        break;
                    case "edi code":
                        fc.strEDICode = value;
                        break;
                    case "default schedule store":
                        if (string.IsNullOrEmpty(value))
                            break;
                        var param = new System.Data.SqlClient.SqlParameter("@intCommodityId", fc.intCommodityId);
                        var param2 = new System.Data.SqlClient.SqlParameter("@strScheduleId", value);
                        param.DbType = System.Data.DbType.Int32;
                        param2.DbType = System.Data.DbType.String;
                        var query = @"SELECT s.[intStorageScheduleRuleId], s.[strScheduleId]
                                    FROM [dbo].[vyuGRGetStorageSchedule] s 
                                    WHERE s.[intCommodity] = @intCommodityId AND s.[strScheduleId] = @strScheduleId";

                        IEnumerable<DefaultStorageStore> storageStores = context.ContextManager.Database.SqlQuery<DefaultStorageStore>(query, param, param2);
                            try
                            {
                                DefaultStorageStore store = storageStores.First();

                                if (store != null)
                                    fc.intScheduleStoreId = store.intStorageScheduleRuleId;
                                else
                                {
                                    dr.Messages.Add(new ImportDataMessage()
                                    {
                                        Column = header,
                                        Row = row,
                                        Type = TYPE_INNER_WARN,
                                        Message = "Can't find Default Schedule Store: " + value + '.',
                                        Status = STAT_INNER_COL_SKIP
                                    });
                                    dr.Info = INFO_WARN;
                                }
                            }
                            catch(Exception)
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Default Schedule Store: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        break;
                    case "discount":
                        if (string.IsNullOrEmpty(value))
                            break;
                        param = new System.Data.SqlClient.SqlParameter("@strDiscountId", value);
                        param.DbType = System.Data.DbType.String;
                        query = @"SELECT intDiscountId, intCurrencyId, strDiscountId, strDiscountDescription, ysnDiscountIdActive 
                                FROM tblGRDiscountId 
                                WHERE [strDiscountId] = @strDiscountId";

                        IEnumerable<DiscountId> discountIds = context.ContextManager.Database.SqlQuery<DiscountId>(query, param);
                        try
                        {
                            DiscountId discountId = discountIds.First();

                            if (discountId != null)
                                fc.intScheduleDiscountId = discountId.intDiscountId;
                            else
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Discount Id: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
                        catch(Exception)
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Discount Id: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "scale auto dist default":
                        if (string.IsNullOrEmpty(value))
                            break;
                        query = @"DECLARE @Max INT
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
                        param = new System.Data.SqlClient.SqlParameter("@strStorageTypeCode", value);
                        param.DbType = System.Data.DbType.String;
                        IEnumerable<ScaleAutoDist> dists = context.ContextManager.Database.SqlQuery<ScaleAutoDist>(query, param);
                            try
                            {
                                ScaleAutoDist dist = dists.First();

                                if (dist != null)
                                    fc.intScaleAutoDistId = dist.intStorageScheduleTypeId;
                                else
                                {
                                    dr.Messages.Add(new ImportDataMessage()
                                    {
                                        Column = header,
                                        Row = row,
                                        Type = TYPE_INNER_WARN,
                                        Message = "Invalid value for Scale Auto Dist Default: " + value + '.',
                                        Status = STAT_INNER_COL_SKIP
                                    });
                                    dr.Info = INFO_WARN;
                                }
                            }
                            catch(Exception)
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Invalid value for Scale Auto Dist Default: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        break;
                    case "default future market":
                        if (string.IsNullOrEmpty(value))
                            break;
                        query = @"SELECT intFutureMarketId, strFutMarketName, strFutSymbol, intFutMonthsToOpen
                                FROM tblRKFutureMarket
                                WHERE strFutMarketName = @strFutMarketName";
                        param = new System.Data.SqlClient.SqlParameter("@strFutMarketName", value);
                        param.DbType = System.Data.DbType.String;
                        IEnumerable<FutureMarket> markets = context.ContextManager.Database.SqlQuery<FutureMarket>(query, param);
                            try
                            {
                                FutureMarket market = markets.First();

                                if (market != null)
                                    fc.intFutureMarketId = market.intFutureMarketId;
                                else
                                {
                                    dr.Messages.Add(new ImportDataMessage()
                                    {
                                        Column = header,
                                        Row = row,
                                        Type = TYPE_INNER_WARN,
                                        Message = "Invalid value for Default Future Market: " + value + '.',
                                        Status = STAT_INNER_COL_SKIP
                                    });
                                    dr.Info = INFO_WARN;
                                }
                            }
                            catch(Exception)
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Invalid value for Default Future Market: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        break;
                    case "decimals on dpr":
                        SetInteger(value, del => fc.intDecimalDPR = del, "Decimals on DPR", dr, header, row);
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICCommodity>().Any(t => t.strCommodityCode == fc.strCommodityCode))
            {
                var entry = context.ContextManager.Entry<tblICCommodity>(context.GetQuery<tblICCommodity>().First(t => t.strCommodityCode == fc.strCommodityCode));
                entry.Property(e => e.strDescription).CurrentValue = fc.strDescription;
                entry.Property(e => e.ysnFXExposure).CurrentValue = fc.ysnFXExposure;
                entry.Property(e => e.ysnExchangeTraded).CurrentValue = fc.ysnExchangeTraded;
                entry.Property(e => e.dblConsolidateFactor).CurrentValue = fc.dblConsolidateFactor;
                entry.Property(e => e.dblPriceCheckMin).CurrentValue = fc.dblPriceCheckMin;
                entry.Property(e => e.dblPriceCheckMax).CurrentValue = fc.dblPriceCheckMax;
                entry.Property(e => e.strCheckoffTaxDesc).CurrentValue = fc.strCheckoffTaxDesc;
                entry.Property(e => e.strCheckoffAllState).CurrentValue = fc.strCheckoffAllState;
                entry.Property(e => e.strInsuranceTaxDesc).CurrentValue = fc.strInsuranceTaxDesc;
                entry.Property(e => e.strInsuranceAllState).CurrentValue = fc.strInsuranceAllState;
                entry.Property(e => e.dtmCropEndDateCurrent).CurrentValue = fc.dtmCropEndDateCurrent;
                entry.Property(e => e.dtmCropEndDateNew).CurrentValue = fc.dtmCropEndDateNew;
                entry.Property(e => e.strEDICode).CurrentValue = fc.strEDICode;
                entry.Property(e => e.intScheduleStoreId).CurrentValue = fc.intScheduleStoreId;
                entry.Property(e => e.intScheduleDiscountId).CurrentValue = fc.intScheduleDiscountId;
                entry.Property(e => e.intScaleAutoDistId).CurrentValue = fc.intScaleAutoDistId;
                entry.Property(e => e.intFutureMarketId).CurrentValue = fc.intFutureMarketId;
                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.strCommodityCode).IsModified = false;
            }
            else
            {
                context.AddNew<tblICCommodity>(fc);
            }
            return fc;
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

        protected override int GetPrimaryKeyId(ref tblICCommodity entity)
        {
            return entity.intCommodityId;
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
