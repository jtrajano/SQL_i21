using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static iRely.Inventory.BusinessLayer.ImportCategories;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportLineOfBusiness : ImportDataLogic<tblSMLineOfBusiness>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "line of business" };
        }

        protected override tblSMLineOfBusiness ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblSMLineOfBusiness fc = new tblSMLineOfBusiness();
            fc.ysnVisibleOnWeb = true;
            bool valid = true;

            for (var i = 0; i < fieldCount; i++)
            {
                //if (!valid)
                //    break;
                string header = headers[i];
                string value = csv[header];

                string h = header.ToLower().Trim();
                switch (h)
                {
                    case "line of business":
                        if(!SetText(value, del => fc.strLineOfBusiness = del, "Line of Business", dr, header, row, true))
                            valid = false;
                        break;
                    case "sales person id":
                        if(string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Status = STAT_REC_SKIP,
                                Message = "Sales Person Id should not be blank."
                            });
                            dr.Info = INFO_WARN;
                        }
                        int intEntitySalespersonId = 0;
                        var sqlParam = new SqlParameter("@strSalespersonId", value);
                        var query = "SELECT intEntityId, strSalespersonId, strName FROM vyuEMSalesperson WHERE strSalespersonId = @strSalespersonId";
                        IEnumerable<vyuEMSalesperson> salesReps = context.ContextManager.Database.SqlQuery<vyuEMSalesperson>(query, sqlParam);
                        try
                        {
                            vyuEMSalesperson salesRep = salesReps.First();

                            if (salesRep != null)
                                intEntitySalespersonId = salesRep.intEntityId;
                            else
                            {
                                valid = false;
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_ERROR,
                                    Message = "Can't find Sales Person for Line of Business: " + value + '.',
                                    Status = STAT_REC_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
                        catch (Exception)
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Sales Person for Line of Business: " + value + '.',
                                Status = STAT_REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }

                        if (intEntitySalespersonId != 0)
                            fc.intEntityId = intEntitySalespersonId;
                        break;
                    case "sic code":
                        SetText(value, del => fc.strSICCode = del, "SIC Code", dr, header, row);
                        break;
                    case "visible on web":
                        SetBoolean(value, del => fc.ysnVisibleOnWeb = del);
                        break;
                    case "type":
                        if (string.IsNullOrEmpty(value))
                            break;
                        if(GetLobTypes().Contains(value.ToLower().Trim()))
                        {
                            fc.strType = value;
                        }
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Invalid Type: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "segment code":
                        if (string.IsNullOrEmpty(value))
                            break;

                        var query2 = @"SELECT asm.intAccountSegmentId, ast.intStructureType, asm.strCode, ast.strStructureName, asm.strDescription
                            FROM tblGLAccountSegment asm
                                INNER JOIN tblGLAccountStructure ast ON ast.intAccountStructureId = asm.intAccountStructureId
                            WHERE ast.intStructureType = 5 AND asm.strCode = @strCode";
                        var sqlP = new SqlParameter("@strCode", value);
                        IEnumerable<AccountSegmentStructureVM> accountSegments = context.ContextManager.Database.SqlQuery<AccountSegmentStructureVM>(query2, sqlP);
                        try
                        {
                            AccountSegmentStructureVM asm = accountSegments.First();

                            if (asm != null)
                                fc.intSegmentCodeId = asm.intAccountSegmentId;
                            else
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Segment Code for Line of Business: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
                        catch (Exception)
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Segment Code for Line of Business: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                }
            }

            if(!valid)
                return null;

            if (context.GetQuery<tblSMLineOfBusiness>().Any(t => t.strLineOfBusiness == fc.strLineOfBusiness))
            {
                if (!GlobalSettings.Instance.AllowOverwriteOnImport)
                {
                    dr.Info = INFO_ERROR;
                    dr.Messages.Add(new ImportDataMessage()
                    {
                        Type = TYPE_INNER_ERROR,
                        Status = STAT_REC_SKIP,
                        Column = headers[0],
                        Row = row,
                        Message = "The record already exists: " + fc.strLineOfBusiness + ". The system does not allow existing records to be modified."
                    });
                    return null;
                }

                var entry = context.ContextManager.Entry<tblSMLineOfBusiness>(context.GetQuery<tblSMLineOfBusiness>().First(t => t.strLineOfBusiness == fc.strLineOfBusiness));
                entry.Property(e => e.strLineOfBusiness).CurrentValue = fc.strLineOfBusiness;
                entry.Property(e => e.strSICCode).CurrentValue = fc.strSICCode;
                entry.Property(e => e.strType).CurrentValue = fc.strType;
                entry.Property(e => e.ysnVisibleOnWeb).CurrentValue = fc.ysnVisibleOnWeb;
                entry.Property(e => e.intSegmentCodeId).CurrentValue = fc.intSegmentCodeId;
                entry.Property(e => e.intEntityId).CurrentValue = fc.intEntityId;

                entry.State = System.Data.Entity.EntityState.Modified;
            }
            else
            {
                context.AddNew(fc);
            }

            return fc;
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

        protected override int GetPrimaryKeyId(ref tblSMLineOfBusiness entity)
        {
            return entity.intLineOfBusinessId;
        }
    }
}
