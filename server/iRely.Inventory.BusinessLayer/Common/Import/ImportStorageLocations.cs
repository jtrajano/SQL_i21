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
            return new string[] { "name", "storage location", "location" };
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
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICStorageUnitType>(
                            context,
                            m => m.strStorageUnitType == value,
                            e => e.intStorageUnitTypeId);
                        if (lu != null)
                            fc.intStorageUnitTypeId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Invalid Storage Unit Type: {0}.", value),
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "location":
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Location should not be blank.",
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
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
                                Message = string.Format("Invalid Location: {0}.", value),
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "storage location":
                        if (string.IsNullOrEmpty(value))
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Storage Location should not be blank.",
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
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
                                Message = string.Format("Invalid Storage Location: {0}.", value),
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "restriction type":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICRestriction>(
                            context,
                            m => m.strDisplayMember == value,
                            e => e.intRestrictionId);
                        if (lu != null)
                            fc.intRestrictionId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Invalid Restriction Type: {0}. (Please use Display Member instead of Internal Code).", value),
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "parent unit":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICStorageLocation>(
                            context,
                            m => m.strName == value,
                            e => e.intStorageLocationId);
                        if (lu != null)
                            fc.intParentStorageLocationId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Can't find Parent Unit: {0}.", value),
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
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
                        if (string.IsNullOrEmpty(value))
                            break;
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
                                Message = string.Format("{0}: A new unit of measurement record has been created with default unit type of 'Length'.", value),
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        if (lu != null)
                            fc.intBatchSizeUOMId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Invalid Batch Size UOM: {0}.", value),
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "commodity":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICCommodity>(
                            context,
                            m => m.strCommodityCode == value,
                            e => e.intCommodityId);
                        if (lu != null)
                            fc.intCommodityId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Can't find Commodity: {0}.", value),
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
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

            if (context.GetQuery<tblICStorageLocation>().Any(t => t.strName == fc.strName && t.intLocationId == fc.intLocationId && t.intSubLocationId == fc.intSubLocationId))
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
                        Message = "The storage unit already exists. The system does not allow existing records to be modified."
                    });
                    return null;
                }

                var entry = context.ContextManager.Entry<tblICStorageLocation>(context.GetQuery<tblICStorageLocation>().First(t => t.strName == fc.strName && t.intLocationId == fc.intLocationId && t.intSubLocationId == fc.intSubLocationId));
                entry.Property(e => e.strName).CurrentValue = fc.strName;
                entry.Property(e => e.strDescription).CurrentValue = fc.strDescription;
                entry.Property(e => e.intStorageUnitTypeId).CurrentValue = fc.intStorageUnitTypeId;
                entry.Property(e => e.intSubLocationId).CurrentValue = fc.intSubLocationId;
                entry.Property(e => e.intParentStorageLocationId).CurrentValue = fc.intParentStorageLocationId;
                entry.Property(e => e.ysnAllowConsume).CurrentValue = fc.ysnAllowConsume;
                entry.Property(e => e.ysnAllowMultipleItem).CurrentValue = fc.ysnAllowMultipleItem;
                entry.Property(e => e.ysnAllowMultipleLot).CurrentValue = fc.ysnAllowMultipleLot;
                entry.Property(e => e.ysnMergeOnMove).CurrentValue = fc.ysnMergeOnMove;
                entry.Property(e => e.ysnCycleCounted).CurrentValue = fc.ysnCycleCounted;
                entry.Property(e => e.ysnDefaultWHStagingUnit).CurrentValue = fc.ysnDefaultWHStagingUnit;
                entry.Property(e => e.intRestrictionId).CurrentValue = fc.intRestrictionId;
                entry.Property(e => e.strUnitGroup).CurrentValue = fc.strUnitGroup;
                entry.Property(e => e.dblMinBatchSize).CurrentValue = fc.dblMinBatchSize;
                entry.Property(e => e.dblBatchSize).CurrentValue = fc.dblBatchSize;
                entry.Property(e => e.intBatchSizeUOMId).CurrentValue = fc.intBatchSizeUOMId;
                entry.Property(e => e.intSequence).CurrentValue = fc.intSequence;
                entry.Property(e => e.ysnActive).CurrentValue = fc.ysnActive;
                entry.Property(e => e.intRelativeX).CurrentValue = fc.intRelativeX;
                entry.Property(e => e.intRelativeY).CurrentValue = fc.intRelativeY;
                entry.Property(e => e.intRelativeZ).CurrentValue = fc.intRelativeZ;
                entry.Property(e => e.intCommodityId).CurrentValue = fc.intCommodityId;
                entry.Property(e => e.dblPackFactor).CurrentValue = fc.dblPackFactor;
                entry.Property(e => e.dblEffectiveDepth).CurrentValue = fc.dblEffectiveDepth;
                entry.Property(e => e.dblUnitPerFoot).CurrentValue = fc.dblUnitPerFoot;
                entry.Property(e => e.dblResidualUnit).CurrentValue = fc.dblResidualUnit;

                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.intLocationId).IsModified = false;
                entry.Property(e => e.intSubLocationId).IsModified = false;
            }
            else
            {
                context.AddNew<tblICStorageLocation>(fc);
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICStorageLocation entity)
        {
            return entity.intStorageLocationId;
        }
    }
}
