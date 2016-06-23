using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportUnitOfMeasurement : ImportDataLogic<tblICUnitMeasure>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "unit type", "unit of measure" };
        }

        public ImportUnitOfMeasurement()
            : base()
        {
            unitTypes = new List<string>();
            unitTypes.AddRange(new string[] {
                "Area", "Length", "Quantity", "Time", "Volume", "Weight", "Packed"
            });
        }

        private List<string> unitTypes;

        protected override tblICUnitMeasure ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICUnitMeasure fc = new tblICUnitMeasure();
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
                    case "unit of measure":
                        if (!SetText(value, del => fc.strUnitMeasure = del, "Unit of Measure", dr, header, row))
                            valid = false;
                        break;
                    case "symbol":
                        fc.strSymbol = value;
                        break;
                    case "unit type":
                        if (!SetFixedLookup(value, del => fc.strUnitType = del, "Unit Type", unitTypes, dr, header, row, true))
                            valid = false;
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICUnitMeasure>().Any(t => t.strUnitMeasure == fc.strUnitMeasure))
            {
                if (!GlobalSettings.Instance.AllowOverwriteOnImport)
                {
                    dr.Info = INFO_ERROR;
                    dr.Messages.Add(new ImportDataMessage()
                    {
                        Type = TYPE_INNER_ERROR,
                        Status = REC_SKIP,
                        Column = headers[0],
                        Row = row,
                        Message = "The record already exists: " + fc.strUnitMeasure + ". The system does not allow existing records to be modified."
                    });
                    return null;
                }
                var entry = context.ContextManager.Entry<tblICUnitMeasure>(context.GetQuery<tblICUnitMeasure>().First(t => t.strUnitMeasure == fc.strUnitMeasure));
                entry.Property(e => e.strSymbol).CurrentValue = fc.strSymbol;
                entry.Property(e => e.strUnitType).CurrentValue = fc.strUnitType;
                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.strUnitMeasure).IsModified = false;
            }
            else
            {
                context.AddNew<tblICUnitMeasure>(fc);
            }

            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICUnitMeasure entity)
        {
            return entity.intUnitMeasureId;
        }
    }
}
