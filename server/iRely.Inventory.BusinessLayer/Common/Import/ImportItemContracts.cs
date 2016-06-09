using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemContracts : ImportDataLogic<tblICItemContract>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "item no", "location", "contract name" };
        }

        protected override tblICItemContract ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICItemContract fc = new tblICItemContract();
            bool valid = true;
            for (var i = 0; i < fieldCount; i++)
            {
                //if (!valid)
                //    break;

                string header = headers[i];
                string value = csv[header];
                string h = header.ToLower().Trim();
                int? lu = null;
                int itemId = 0;
                switch (h)
                {
                    case "item no":
                        lu = GetLookUpId<tblICItem>(
                            context,
                            m => m.strItemNo == value,
                            e => e.intItemId);
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
                                Status = REC_SKIP,
                                Message = "Invalid Item No: " + value + ". The item does not exists"
                            });
                        }
                        break;
                    case "location":
                        lu = GetLookUpId<vyuICGetItemLocation>(
                            context,
                            m => m.strLocationName == value && m.intItemId == itemId,
                            e => (int)e.intLocationId);
                        if (lu != null)
                        {
                            fc.intItemLocationId = (int)lu;
                        }
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Status = REC_SKIP,
                                Message = "The Location " + value + " does not exist."
                            });
                        }
                        break;
                    case "origin":
                        lu = GetLookUpId<tblSMCountry>(
                            context,
                            m => m.strCountry == value,
                            e => (int)e.intCountryID);
                        if (lu != null)
                        {
                            fc.intCountryId = (int)lu;
                        }
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = "The Origin " + value + " does not exist."
                            });
                        }
                        break;
                    case "contract name":
                        SetText(value, del => fc.strContractItemName = del, "Contract Name", dr, header, row);
                        break;
                    case "grade":
                        fc.strGrade = value;
                        break;
                    case "grade type":
                        fc.strGradeType = value;
                        break;
                    case "garden":
                        fc.strGarden = value;
                        break;
                    case "yield":
                        SetDecimal(value, del => fc.dblYieldPercent = del, "Yield", dr, header, row);
                        break;
                    case "tolerance":
                        SetDecimal(value, del => fc.dblTolerancePercent = del, "Tolerance", dr, header, row);
                        break;
                    case "franchise":
                        SetDecimal(value, del => fc.dblFranchisePercent = del, "Franchise", dr, header, row);
                        break;
                }
            }

            if (!valid)
                return null;

            context.AddNew<tblICItemContract>(fc);
            LogItems.Add(new ImportLogItem()
            {
                ActionIcon = ICON_ACTION_NEW,
                Description = "Created Contract Item",
                FromValue = "",
                ToValue = string.Format("Contract Name: {0}, Location: {1}", fc.strContractItemName, fc.strLocationName)
            });
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICItemContract entity)
        {
            return entity.intItemContractId;
        }

        protected override void LogTransaction(ref tblICItemContract entity, ImportDataResult dr)
        {
            var id = entity.intItemId;
            if (id != 0)
            {
                string details = string.Empty;
                string comma = ",";
                int count = 0;
                foreach (ImportLogItem item in LogItems)
                {
                    count++;
                    if (count == LogItems.Count && count == 1)
                        comma = "";
                    details += "{\"change\":\"" + item.Description + "\",\"iconCls\":\"" + item.ActionIcon + "\",\"from\":\"" + item.FromValue + "\",\"to\":\"" + item.ToValue + "\",\"leaf\":true}" + comma;
                }

                if (!string.IsNullOrEmpty(details))
                    LogItem(id, "Imported from CSV file.", "Inventory.view.Item", details, dr);
            }
        }
    }
}
