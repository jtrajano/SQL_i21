using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LumenWorks.Framework.IO.Csv;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportCommodityUOM : ImportDataLogic<tblICCommodityUnitMeasure>
    {
        protected override int GetPrimaryKeyId(ref tblICCommodityUnitMeasure entity)
        {
            return entity.intCommodityUnitMeasureId;
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "commodity code", "uom", "unit qty" };
        }

        protected override tblICCommodityUnitMeasure ProcessRow(int row, int fieldCount, string[] headers, CsvReader csv, ImportDataResult dr)
        {
            tblICCommodityUnitMeasure fc = new tblICCommodityUnitMeasure();
            bool valid = true;

            for (int i = 0; i < fieldCount; i++)
            {
                string header = headers[i];
                string value = csv[header];
                string h = header.ToLower().Trim();
                tblICCommodity commodity = null;
                tblICUnitMeasure uom = null;

                switch (h)
                {
                    case "commodity code":
                        commodity = GetLookUpObject<tblICCommodity>(
                            context,
                            m => m.strCommodityCode == value);
                        if (commodity != null)
                        {
                            fc.intCommodityId = commodity.intCommodityId;
                            fc.tblICCommodity = commodity;
                        }
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Status = STAT_REC_SKIP,
                                Message = "The Commodity Code " + value + " does not exist."
                            });
                            dr.Info = INFO_ERROR;
                        }
                        break;
                    case "uom":
                        uom = GetLookUpObject<tblICUnitMeasure>(
                            context,
                            m => m.strUnitMeasure == value);
                        if (uom != null)
                        {
                            fc.intUnitMeasureId = uom.intUnitMeasureId;
                            fc.tblICUnitMeasure = uom;
                        }
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Status = STAT_REC_SKIP,
                                Message = "The UOM " + value + " does not exist."
                            });
                            dr.Info = INFO_ERROR;
                        }
                        break;
                    case "unit qty":
                        SetDecimal(value, del => fc.dblUnitQty = del, "Unit Qty", dr, header, row);
                        break;
                    case "is stock unit":
                        SetBoolean(value, del => fc.ysnStockUnit = del);
                        break;
                    case "is default uom":
                        SetBoolean(value, del => fc.ysnDefault = del);
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICCommodityUnitMeasure>().Any(t => t.intUnitMeasureId == fc.intUnitMeasureId
                && t.intCommodityId == fc.intCommodityId))
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
                        Message = "The record already exists: " + fc.strUnitMeasure + ". The system does not allow existing records to be modified."
                    });
                    return null;
                }

                var entry = context.ContextManager.Entry<tblICCommodityUnitMeasure>(context.GetQuery<tblICCommodityUnitMeasure>()
                    .First(t => t.intUnitMeasureId == fc.intUnitMeasureId && t.intCommodityId == fc.intCommodityId));

                entry.Property(e => e.intUnitMeasureId).CurrentValue = fc.intUnitMeasureId;
                entry.Property(e => e.intCommodityId).CurrentValue = fc.intCommodityId;
                entry.Property(e => e.dblUnitQty).CurrentValue = fc.dblUnitQty;
                entry.Property(e => e.ysnDefault).CurrentValue = fc.ysnDefault;
                entry.Property(e => e.ysnStockUnit).CurrentValue = fc.ysnStockUnit;

                entry.Property(e => e.intCommodityUnitMeasureId).IsModified = false;
                entry.State = System.Data.Entity.EntityState.Modified;
            }
            else
            {
                context.AddNew<tblICCommodityUnitMeasure>(fc);
            }
            return fc;
        }
    }
}