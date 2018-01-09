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
    public class ImportFuelCodes : ImportDataLogic<tblICRinFuel>
    {
        public ImportFuelCodes(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "code" };
        }

        public override tblICRinFuel Process(CsvRecord record)
        {
            tblICRinFuel fc = new tblICRinFuel();
            var entity = new tblICRinFuel();
            var valid = true;
            
            valid = SetText(record, "Code", e => entity.strRinFuelCode = e, true);
            SetText(record, "Description", e => entity.strDescription = e, false);

            if (valid)
                return entity;

            return null;
        }

        public override void Initialize()
        {
            base.Initialize();
            /* Sample adding transformation pipelines */
            //AddPipe(new MappingPipe());
            //AddPipe(new MappingPipe2());
        }

        protected override Expression<Func<tblICRinFuel, bool>> GetUniqueKeyExpression(tblICRinFuel entity)
        {
            return (e => e.strRinFuelCode == entity.strRinFuelCode);
        }

        public override int GetPrimaryKeyValue(tblICRinFuel entity)
        {
            return entity.intRinFuelId;
        }

        protected override string GetPrimaryKeyName()
        {
            return "intRinFuelId";
        }

        /* Sample Transformation Pipelines */
        //class MappingPipe : CsvPipe<tblICRinFuel>
        //{
        //    protected override tblICRinFuel Process(tblICRinFuel input)
        //    {
        //        input.strDescription = Record["Description"];
        //        input.strRinFuelCode = Record["Code"];
        //        return input;
        //    }
        //}

        //class MappingPipe2 : CsvPipe<tblICRinFuel>
        //{
        //    protected override tblICRinFuel Process(tblICRinFuel input)
        //    {
        //        input.strDescription = input.strDescription.ToUpper();
        //        input.strRinFuelCode = input.strRinFuelCode.ToUpper();
        //        return input;
        //    }
        //}
    }
}
