using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportFeedStockUOM : ImportDataLogic<tblICRinFeedStockUOM>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "code", "unit of measure" };
        }

        protected override tblICRinFeedStockUOM ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICRinFeedStockUOM fc = new tblICRinFeedStockUOM();
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
                    case "code":
                        if (!SetText(value, del => fc.strRinFeedStockUOMCode = del, "Code", dr, header, row, true))
                            valid = false;
                        if (HasLocalDuplicate(dr, header, value, row))
                            valid = false;
                        break;
                    case "unit of measure":
                        lu = InsertAndOrGetLookupId<tblICUnitMeasure>(
                            context,
                            m => m.strUnitMeasure == value,
                            e => e.intUnitMeasureId,
                            new tblICUnitMeasure()
                            {
                                strSymbol = value,
                                strUnitMeasure = value,
                                strUnitType = "Length"
                            }, out inserted);
                        if (inserted)
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Type = TYPE_INNER_WARN,
                                Row = row,
                                Status = STAT_INNER_SUCCESS,
                                Message = string.Format("{0}: A new unit of measurement record has been created with default unit type of 'Length'.", value)
                            });
                            dr.Info = INFO_WARN;
                            if (lu != null)
                            {
                                LogItems.Add(new ImportLogItem()
                                {
                                    Description = "Created new Unit of Measurement item.",
                                    FromValue = "",
                                    ToValue = value,
                                    ActionIcon = ICON_ACTION_NEW
                                });
                            }
                        }

                        if (lu != null)
                            fc.intUnitMeasureId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Unit of Measurement item: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                            valid = false;
                        }
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICRinFeedStockUOM>().Any(t => t.intUnitMeasureId == fc.intUnitMeasureId))
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

                var entry = context.ContextManager.Entry<tblICRinFeedStockUOM>(
                    context.GetQuery<tblICRinFeedStockUOM>().First(t => t.intUnitMeasureId == fc.intUnitMeasureId));
                entry.Property(e => e.strRinFeedStockUOMCode).CurrentValue = fc.strRinFeedStockUOMCode;

                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.intUnitMeasureId).IsModified = false;

                dr.IsUpdate = true;
            }
            else
            {
                context.AddNew<tblICRinFeedStockUOM>(fc);
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICRinFeedStockUOM entity)
        {
            return entity.intRinFeedStockUOMId;
        }
    }
}
