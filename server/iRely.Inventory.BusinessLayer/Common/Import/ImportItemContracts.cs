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
            int itemId = 0;
            for (var i = 0; i < fieldCount; i++)
            {
                //if (!valid)
                //    break;

                string header = headers[i];
                string value = csv[header];
                string h = header.ToLower().Trim();
                int? lu = null;
                
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
                            itemId = fc.intItemId;
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
                        if (string.IsNullOrEmpty(value))
                            break;
                        var param = new System.Data.SqlClient.SqlParameter("@intItemId", itemId);
                        var param2 = new System.Data.SqlClient.SqlParameter("@strLocationName", value);
                        param.DbType = System.Data.DbType.Int32;
                        param2.DbType = System.Data.DbType.String;
                        var query = @"SELECT intItemId, intItemLocationId, intLocationId, strItemNo, strItemDescription, strLocationName
                            FROM vyuICGetItemLocation
                            WHERE intItemId = @intItemId
	                            AND strLocationName = @strLocationName";

                        IEnumerable<ItemLocation> itemLocations = context.ContextManager.Database.SqlQuery<ItemLocation>(query, param, param2);
                            try
                            {
                                ItemLocation store = itemLocations.First();

                                if (store != null)
                                {
                                    fc.intItemLocationId = store.intItemLocationId;
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
                                    dr.Info = INFO_WARN;
                                }
                            }
                            catch(Exception)
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
                                dr.Info = INFO_WARN;
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

        private class ItemLocation
        {
            public int intItemLocationId { get; set; }
            public int intLocationId { get; set; }
            public int intItemId { get; set; }
            public string strLocationName { get; set; }
            public string strItemNo { get; set; }
            public string strItemDescription { get; set; }
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
