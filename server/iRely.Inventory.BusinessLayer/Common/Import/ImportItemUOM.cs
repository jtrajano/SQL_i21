using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemUOM : ImportDataLogic<tblICItemUOM>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "uom", "item no" };
        }

        protected override int GetPrimaryKeyId(ref tblICItemUOM entity)
        {
            return entity.intItemUOMId;
        }

        protected override tblICItemUOM ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            var fc = new tblICItemUOM();
            bool valid = true;
            int? intItemId = null;

            for (var i = 0; i < fieldCount; i++)
            {
                //if (!valid)
                //    break;

                string header = headers[i];
                string value = csv[header];

                string h = header.ToLower().Trim();
                int? lu = null;

                string unitType = "Weight";
                switch (h)
                {
                    case "item no":
                        lu = GetLookUpId<tblICItem>(
                            context,
                            m => m.strItemNo == value,
                            e => e.intItemId);
                        intItemId = lu;
                        if (lu != null)
                        {
                            fc.intItemId = (int)lu;
                        }
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Item with Item No.: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "unit type":
                        unitType = value;
                        break;
                    case "uom":
                        lu = GetLookUpId<tblICUnitMeasure>(
                            context,
                            m => m.strUnitMeasure == value,
                            e => e.intUnitMeasureId);
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
                    case "unit qty":
                        if (!SetNonZeroDecimal(value, del => fc.dblUnitQty = del, "Unit Qty", dr, header, row))
                            valid = false;
                        break;
                    case "weight uom":
                        lu = GetLookUpId<tblICUnitMeasure>(
                            context,
                            m => m.strUnitMeasure == value,
                            e => e.intUnitMeasureId);

                        if (lu != null)
                            fc.intWeightUOMId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Unit of Measurement item for Weight: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "upc code":
                        SetText(value, del => fc.strLongUPCCode = del);
                        break;
                    case "short upc code":
                        SetText(value, del => fc.strUpcCode = del);
                        break;
                    case "is stock unit":
                        SetBoolean(value, del => fc.ysnStockUnit = del);
                        break;
                    case "allow purchase":
                        SetBoolean(value, del => fc.ysnAllowPurchase = del);
                        break;
                    case "allow sale":
                        SetBoolean(value, del => fc.ysnAllowSale = del);
                        break;
                    case "length":
                        SetDecimal(value, del => fc.dblLength = del, "Length", dr, header, row);
                        break;
                    case "width":
                        SetDecimal(value, del => fc.dblWidth = del, "Width", dr, header, row);
                        break;
                    case "height":
                        SetDecimal(value, del => fc.dblHeight = del, "Height", dr, header, row);
                        break;
                    case "dimension uom":
                        lu = GetLookUpId<tblICUnitMeasure>(
                            context,
                            m => m.strUnitMeasure == value,
                            e => e.intUnitMeasureId);

                        if (lu != null)
                            fc.intDimensionUOMId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Unit of Measurement item for Dimension: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "volume":
                        SetDecimal(value, del => fc.dblVolume = del, "Volume", dr, header, row);
                        break;
                    case "volume uom":
                        lu = GetLookUpId<tblICUnitMeasure>(
                            context,
                            m => m.strUnitMeasure == value,
                            e => e.intUnitMeasureId);

                        if (lu != null)
                            fc.intVolumeUOMId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "Can't find Unit of Measurement item for Volume: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                            valid = false;
                        }
                        break;
                    case "max qty":
                        SetDecimal(value, del => fc.dblMaxQty = del, "Max Qty", dr, header, row);
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICItemUOM>().Any(t => t.intItemId == fc.intItemId && t.intUnitMeasureId == fc.intUnitMeasureId))
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
                        Message = "The item uom already exists. The system does not allow existing records to be modified."
                    });
                    return null;
                }

                var entry = context.ContextManager.Entry<tblICItemUOM>(context.GetQuery<tblICItemUOM>().First(t => t.intItemId == fc.intItemId && t.intUnitMeasureId == fc.intUnitMeasureId));
                entry.Property(e => e.intItemId).CurrentValue = fc.intItemId;
                entry.Property(e => e.intUnitMeasureId).CurrentValue = fc.intUnitMeasureId;
                entry.Property(e => e.dblUnitQty).CurrentValue = fc.dblUnitQty;
                entry.Property(e => e.dblWeight).CurrentValue = fc.dblWeight;
                entry.Property(e => e.intWeightUOMId).CurrentValue = fc.intWeightUOMId;
                entry.Property(e => e.strUpcCode).CurrentValue = fc.strUpcCode;
                entry.Property(e => e.strLongUPCCode).CurrentValue = fc.strLongUPCCode;
                entry.Property(e => e.ysnStockUnit).CurrentValue = fc.ysnStockUnit;
                entry.Property(e => e.ysnAllowPurchase).CurrentValue = fc.ysnAllowPurchase;
                entry.Property(e => e.ysnAllowSale).CurrentValue = fc.ysnAllowSale;
                entry.Property(e => e.dblLength).CurrentValue = fc.dblLength;
                entry.Property(e => e.dblWidth).CurrentValue = fc.dblWidth;
                entry.Property(e => e.dblHeight).CurrentValue = fc.dblHeight;
                entry.Property(e => e.intDimensionUOMId).CurrentValue = fc.intDimensionUOMId;
                entry.Property(e => e.dblVolume).CurrentValue = fc.dblVolume;
                entry.Property(e => e.intVolumeUOMId).CurrentValue = fc.intVolumeUOMId;
                entry.Property(e => e.dblMaxQty).CurrentValue = fc.dblMaxQty;

                entry.Property(e => e.intItemId).IsModified = false;
                entry.Property(e => e.intUnitMeasureId).IsModified = false;
            }
            else
            {
                context.AddNew<tblICItemUOM>(fc);
            }

            return fc;
        }
    }
}
