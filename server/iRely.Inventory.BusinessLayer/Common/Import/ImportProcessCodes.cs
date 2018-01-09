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
    public class ImportProcessCodes : ImportDataLogic<tblICRinProcess>
    {
        public ImportProcessCodes(DbContext context, byte[] data) : base(context, data)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "code" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intRinProcessId";
        }

        protected override Expression<Func<tblICRinProcess, bool>> GetUniqueKeyExpression(tblICRinProcess entity)
        {
            return (e => e.strRinProcessCode == entity.strRinProcessCode);
        }

        public override int GetPrimaryKeyValue(tblICRinProcess entity)
        {
            return entity.intRinProcessId;
        }

        public override tblICRinProcess Process(CsvRecord record)
        {
            var entity = new tblICRinProcess();
            var valid = true;

            valid = SetText(record, "Code", e => entity.strRinProcessCode = e, required: true);
            SetText(record, "Description", e => entity.strDescription = e, required: false);

            if (valid)
                return entity;

            return null;
        }
    }
}
