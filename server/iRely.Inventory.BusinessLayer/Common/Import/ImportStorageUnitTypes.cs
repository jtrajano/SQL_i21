using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportStorageUnitTypes : ImportDataLogic<tblICStorageUnitType>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "name" };
        }

        protected override tblICStorageUnitType ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICStorageUnitType fc = new tblICStorageUnitType();
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
                    case "name":
                        if (!SetText(value, del => fc.strStorageUnitType = del, "Name", dr, header, row, true))
                            valid = false;
                        break;
                    case "description":
                        fc.strDescription = value;
                        break;
                    case "internal code":
                        fc.strInternalCode = value;
                        break;
                    case "capacity uom":
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
                                Message = string.Format("{0}: A new unit of measurement record has been created with default unit type of 'Length'.", value)
                            });
                            dr.Info = INFO_WARN;
                        }
                        if (lu != null)
                            fc.intCapacityUnitMeasureId = (int)lu;
                        break;
                    case "max weight":
                        SetDecimal(value, del => fc.dblMaxWeight = del, "Max Weight", dr, header, row);
                        break;
                    case "allows picking":
                        SetBoolean(value, del => fc.ysnAllowPick = del);
                        break;
                    case "dimension uom":
                        lu = InsertAndOrGetLookupId<tblICUnitMeasure>(
                            context,
                            m => m.strUnitMeasure == value && (m.strUnitType == "Length" || m.strUnitType == "Area"),
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
                                Message = 
                                string.Format("{0}: A new unit of measurement record has been created with default unit type of 'Length'.", value)
                            });
                            dr.Info = INFO_WARN;
                        }
                        if (lu != null)
                            fc.intDimensionUnitMeasureId = (int)lu;
                        break;
                    case "height":
                        SetDecimal(value, del => fc.dblHeight = del, "Height", dr, header, row);
                        break;
                    case "depth":
                        SetDecimal(value, del => fc.dblDepth = del, "Depth", dr, header, row);
                        break;
                    case "width":
                        SetDecimal(value, del => fc.dblWidth = del, "Width", dr, header, row);
                        break;
                    case "pallet stack":
                        SetInteger(value, del => fc.intPalletStack = del, "Pallet Stack", dr, header, row);
                        break;
                    case "pallet columns":
                        SetInteger(value, del => fc.intPalletColumn = del, "Pallet Columns", dr, header, row);
                        break;
                    case "pallet rows":
                        SetInteger(value, del => fc.intPalletRow = del, "Pallet Rows", dr, header, row);
                        break;
                }
            }

            if (!valid)
                return null;

            context.AddNew<tblICStorageUnitType>(fc);
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICStorageUnitType entity)
        {
            return entity.intStorageUnitTypeId;
        }
    }
}
