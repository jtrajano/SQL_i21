using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using static iRely.Inventory.BusinessLayer.ImportCategories;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportLineOfBusiness : ImportDataLogic<tblSMLineOfBusiness>
    {
        public ImportLineOfBusiness(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "line of business", "sales person id" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intLineOfBusinessId";
        }

        public override int GetPrimaryKeyValue(tblSMLineOfBusiness entity)
        {
            return entity.intLineOfBusinessId;
        }

        protected override Expression<Func<tblSMLineOfBusiness, bool>> GetUniqueKeyExpression(tblSMLineOfBusiness entity)
        {
            return (e => e.strLineOfBusiness == entity.strLineOfBusiness && e.intEntityId == entity.intEntityId);
        }

        public override tblSMLineOfBusiness Process(CsvRecord record)
        {
            var entity = new tblSMLineOfBusiness();
            entity.ysnVisibleOnWeb = true;

            var valid = true;

            valid = SetText(record, "Line of Business", e => entity.strLineOfBusiness = e, required: true);
            var lu = GetFieldValue(record, "Sales Person Id");
            //valid = GetLookUpId<vyuEMSalesperson>(record, "Sales Person Id", e => e.strSalespersonId == lu, e => e.intEntityId, e => entity.intEntityId = e, required: true);
            var sqlParam = new SqlParameter("@strSalespersonId", lu);
            var query = "SELECT intEntityId, strSalespersonId, strName FROM vyuEMSalesperson WHERE strSalespersonId = @strSalespersonId";
            IEnumerable<vyuEMSalesperson> salesReps = Context.Database.SqlQuery<vyuEMSalesperson>(query, sqlParam);
            try
            {
                vyuEMSalesperson salesRep = salesReps.FirstOrDefault();

                if (salesRep != null)
                    entity.intEntityId = salesRep.intEntityId;
                else
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Sales Person Id",
                        Row = record.RecordNo,
                        Type = Constants.TYPE_ERROR,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = lu,
                        Message = $"Can't find Sales Person Id: {lu}.",
                    };
                    ImportResult.AddError(msg);
                    valid = false;
                }
            }
            catch (Exception)
            {
                var msg = new ImportDataMessage()
                {
                    Column = "Sales Person Id",
                    Row = record.RecordNo,
                    Type = Constants.TYPE_ERROR,
                    Status = Constants.STAT_FAILED,
                    Action = Constants.ACTION_SKIPPED,
                    Exception = null,
                    Value = lu,
                    Message = $"Can't find Sales Person Id: {lu}.",
                };
                ImportResult.AddError(msg);
                valid = false;
            }

            SetText(record, "Sic Code", e => entity.strSICCode = e);
            SetBoolean(record, "Visible on Web", e => entity.ysnVisibleOnWeb = e);
            SetFixedLookup(record, "Type", e => entity.strType = e, GetLobTypes(), required: false, exactMatch: false);

            if (valid)
                return entity;

            return null;
        }

        public override void Initialize()
        {
            base.Initialize();
            AddPipe(new SalesPersonPipe(context, ImportResult));
            AddPipe(new SegmentCodePipe(context, ImportResult));
        }

        class SalesPersonPipe : CsvPipe<tblSMLineOfBusiness>
        {
            public SalesPersonPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblSMLineOfBusiness Process(tblSMLineOfBusiness input)
            {
                var value = GetFieldValue("Sales Person Id");

                if (string.IsNullOrEmpty(value)) return null;

                var sqlParam = new SqlParameter("@strSalespersonId", value);
                var query = "SELECT intEntityId, strSalespersonId, strName FROM vyuEMSalesperson WHERE strSalespersonId = @strSalespersonId";
                IEnumerable<vyuEMSalesperson> salesReps = Context.Database.SqlQuery<vyuEMSalesperson>(query, sqlParam);
                try
                {
                    vyuEMSalesperson salesRep = salesReps.FirstOrDefault();

                    if (salesRep != null)
                        input.intEntityId = salesRep.intEntityId;
                    else
                    {
                        var msg = new ImportDataMessage()
                        {
                            Column = "Sales Person Id",
                            Row = Record.RecordNo,
                            Type = Constants.TYPE_ERROR,
                            Status = Constants.STAT_FAILED,
                            Action = Constants.ACTION_SKIPPED,
                            Exception = null,
                            Value = value,
                            Message = $"Can't find Sales Person Id: {value}.",
                        };
                        Result.AddError(msg);
                        return null;
                    }
                }
                catch (Exception)
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Sales Person Id",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_ERROR,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = value,
                        Message = $"Can't find Sales Person Id: {value}.",
                    };
                    Result.AddError(msg);
                    return null;
                }

                return input;
            }
        }

        class SegmentCodePipe : CsvPipe<tblSMLineOfBusiness>
        {
            public SegmentCodePipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblSMLineOfBusiness Process(tblSMLineOfBusiness input)
            {
                var value = GetFieldValue("Segment Code");
                if (string.IsNullOrEmpty(value)) return input;
                var query2 = @"SELECT asm.intAccountSegmentId, ast.intStructureType, asm.strCode, ast.strStructureName, asm.strDescription
                            FROM tblGLAccountSegment asm
                                INNER JOIN tblGLAccountStructure ast ON ast.intAccountStructureId = asm.intAccountStructureId
                            WHERE ast.intStructureType = 5 AND asm.strCode = @strCode";
                var sqlP = new SqlParameter("@strCode", value);
                IEnumerable<AccountSegmentStructureVM> accountSegments = Context.Database.SqlQuery<AccountSegmentStructureVM>(query2, sqlP);
                try
                {
                    AccountSegmentStructureVM asm = accountSegments.First();

                    if (asm != null)
                        input.intSegmentCodeId = asm.intAccountSegmentId;
                    else
                    {
                        var msg = new ImportDataMessage()
                        {
                            Column = "Sales Person Id",
                            Row = Record.RecordNo,
                            Type = Constants.TYPE_WARNING,
                            Status = Constants.STAT_FAILED,
                            Action = Constants.ACTION_SKIPPED,
                            Exception = null,
                            Value = value,
                            Message = $"Can't find Sales Person Id: {value}.",
                        };
                        Result.AddWarning(msg);
                    }
                }
                catch (Exception)
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Segment Code",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_WARNING,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = value,
                        Message = $"Can't find Segment Code: {value}.",
                    };
                    Result.AddWarning(msg);
                }
                return input;
            }
        }

        class AccountSegmentStructureVM
        {
            public int intAccountSegmentId { get; set; }
            public int? intStructureType { get; set; }
            public string strCode { get; set; }
            public string strStructureName { get; set; }
            public string strDescription { get; set; }
        }

        public string[] GetLobTypes()
        {
            return new string[]
            {
                "software",
                "agriculture",
                "grain",
                "petroleum"
            };
        }
    }
}
