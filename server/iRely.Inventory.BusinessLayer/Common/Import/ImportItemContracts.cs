using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemContracts : ImportDataLogic<tblICItemContract>
    {
        public ImportItemContracts(DbContext context, byte[] data) : base(context, data)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "item no", "location", "contract name" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intItemContractId";
        }

        public override int GetPrimaryKeyValue(tblICItemContract entity)
        {
            return entity.intItemContractId;
        }

        public override tblICItemContract Process(CsvRecord record)
        {
            var entity = new tblICItemContract();
            var valid = true;

            var lu = GetFieldValue(record, "Item No");
            valid = SetIntLookupId<tblICItem>(record, "Item No", e => e.strItemNo == lu, e => e.intItemId, e => entity.intItemId = e, required: true);
            lu = GetFieldValue(record, "Origin");
            SetLookupId<tblSMCountry>(record, "Origin", e => e.strCountry == lu, e => e.intCountryID, e => entity.intCountryId = e, required: false);
            SetText(record, "Contract Name", e => entity.strContractItemName = e);
            SetText(record, "Grade", e => entity.strGrade = e);
            SetText(record, "Grade Type", e => entity.strGradeType = e);
            SetText(record, "Garden", e => entity.strGarden = e);
            SetDecimal(record, "Yield", e => entity.dblYieldPercent = e);
            SetDecimal(record, "Tolerance", e => entity.dblTolerancePercent = e);
            SetDecimal(record, "Franchise", e => entity.dblFranchisePercent = e);

            if (valid)
                return entity;

            return null;
        }

        class LocationPipe : CsvPipe<tblICItemContract>
        {
            public LocationPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemContract Process(tblICItemContract input)
            {
                var value = GetFieldValue("Location");
                if(string.IsNullOrEmpty(value))
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Location",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_ERROR,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = value,
                        Message = $"Invalid value for Location: {value}.",
                    };
                    Result.AddError(msg);
                    return null;
                }


                var param = new System.Data.SqlClient.SqlParameter("@intItemId", input.intItemId);
                var param2 = new System.Data.SqlClient.SqlParameter("@strLocationName", value);
                param.DbType = System.Data.DbType.Int32;
                param2.DbType = System.Data.DbType.String;
                var query = @"SELECT intItemId, intItemLocationId, intLocationId, strItemNo, strItemDescription, strLocationName
                            FROM vyuICGetItemLocation
                            WHERE intItemId = @intItemId
	                            AND strLocationName = @strLocationName";

                IEnumerable<ItemLocation> itemLocations = Context.Database.SqlQuery<ItemLocation>(query, param, param2);
                try
                {
                    ItemLocation store = itemLocations.First();

                    if (store != null)
                    {
                        input.intItemLocationId = store.intItemLocationId;
                    }
                    else
                    {
                        var msg = new ImportDataMessage()
                        {
                            Column = "Location",
                            Row = Record.RecordNo,
                            Type = Constants.TYPE_ERROR,
                            Status = Constants.STAT_FAILED,
                            Action = Constants.ACTION_SKIPPED,
                            Exception = null,
                            Value = value,
                            Message = $"Invalid value for Location: {value}.",
                        };
                        Result.AddError(msg);
                        return null;
                    }
                }
                catch (Exception)
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Location",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_EXCEPTION,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = value,
                        Message = $"Invalid value for Location: {value}.",
                    };
                    Result.AddError(msg);
                    return null;
                }
                return input;
            }
        }

        private class ItemLocation
        {
            public int intItemLocationId { get; set; }
            public int intLocationId { get; set; }
            public int intItemId { get; set; }
            public string strLocationName { get; set; }
            public string strItemNo { get; set; }
            public string strItemDescription { get; set; }
        }
    }
}
