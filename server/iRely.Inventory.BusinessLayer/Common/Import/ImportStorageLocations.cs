using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportStorageLocations : ImportDataLogic<tblICStorageLocation>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "name", "sub location" };
        }

        protected override tblICStorageLocation ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICStorageLocation fc = new tblICStorageLocation();
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
                        if (!SetText(value, del => fc.strName = del, "Name", dr, header, row, true))
                            valid = false;
                        break;
                    case "description":
                        fc.strDescription = value;
                        break;
                    case "storage unit type":
                        lu = GetLookUpId<tblICStorageUnitType>(
                            context,
                            m => m.strStorageUnitType == value,
                            e => e.intStorageUnitTypeId);
                        if (lu != null)
                            fc.intStorageUnitTypeId = (int)lu;
                        break;
                    case "location":
                        lu = GetLookUpId<tblSMCompanyLocation>(
                            context,
                            m => m.strLocationName == value,
                            e => e.intCompanyLocationId);
                        if (lu != null)
                            fc.intLocationId = (int)lu;
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Invalid Location: {0}.", value)
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "sub location":
                        lu = GetLookUpId<tblSMCompanyLocationSubLocation>(
                            context,
                            m => m.strSubLocationName == value,
                            e => e.intCompanyLocationSubLocationId);
                        if (lu != null)
                            fc.intSubLocationId = (int)lu;
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Invalid Sub Location: {0}.", value)
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "restriction type":
                        lu = GetLookUpId<tblICRestriction>(
                            context,
                            m => m.strInternalCode == value,
                            e => e.intRestrictionId);
                        if (lu != null)
                            fc.intRestrictionId = (int)lu;
                        break;
                    case "parent unit":
                        lu = GetLookUpId<tblICStorageLocation>(
                            context,
                            m => m.strName == value,
                            e => e.intStorageLocationId);
                        if (lu != null)
                            fc.intParentStorageLocationId = (int)lu;
                        break;
                    case "aisle":
                        fc.strUnitGroup = value;
                        break;
                    case "min batch size":
                        SetDecimal(value, del => fc.dblMinBatchSize = del, "Min Batch Size", dr, header, row);
                        break;
                    case "batch size":
                        SetDecimal(value, del => fc.dblBatchSize = del, "Batch Size", dr, header, row);
                        break;
                    case "batch size uom":
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
                            fc.intBatchSizeUOMId = (int)lu;
                        break;
                    case "commodity":
                        lu = GetLookUpId<tblICCommodity>(
                            context,
                            m => m.strCommodityCode == value,
                            e => e.intCommodityId);
                        if (lu != null)
                            fc.intCommodityId = (int)lu;
                        break;
                    case "pack factor":
                        SetDecimal(value, del => fc.dblPackFactor = del, "Pack Factor", dr, header, row);
                        break;
                    case "effective depth":
                        SetDecimal(value, del => fc.dblEffectiveDepth = del, "Effective Depth", dr, header, row);
                        break;
                    case "units per foot":
                         SetDecimal(value, del => fc.dblUnitPerFoot = del, "Units Per Foot", dr, header, row);
                        break;
                    case "residual units":
                        SetDecimal(value, del => fc.dblResidualUnit = del, "Residual Units", dr, header, row);
                        break;
                    case "sequence":
                        SetInteger(value, del => fc.intSequence = del, "Sequence", dr, header, row);
                        break;
                    case "active":
                        SetBoolean(value, del => fc.ysnActive = del);
                        break;
                    case "z position":
                        SetInteger(value, del => fc.intRelativeZ = del, "Z Position", dr, header, row);
                        break;
                    case "x position":
                        SetInteger(value, del => fc.intRelativeX = del, "X Position", dr, header, row);
                        break;
                    case "y position":
                        SetInteger(value, del => fc.intRelativeY = del, "Y Position", dr, header, row);
                        break;
                    case "allow consume":
                        SetBoolean(value, del => fc.ysnAllowConsume = del);
                        break;
                    case "allow multiple items":
                        SetBoolean(value, del => fc.ysnAllowMultipleItem = del);
                        break;
                    case "allow multiple lots":
                        SetBoolean(value, del => fc.ysnAllowMultipleLot = del);
                        break;
                    case "merge on move":
                        SetBoolean(value, del => fc.ysnMergeOnMove = del);
                        break;
                    case "cycle counted":
                        SetBoolean(value, del => fc.ysnCycleCounted = del);
                        break;
                    case "default warehouse staging unit":
                        SetBoolean(value, del => fc.ysnDefaultWHStagingUnit = del);
                        break;
                }
            }
            if (!valid)
                return null;
            context.AddNew<tblICStorageLocation>(fc);
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICStorageLocation entity)
        {
            return entity.intStorageLocationId;
        }
    }
}
