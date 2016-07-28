using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportCategories : ImportDataLogic<tblICCategory>
    {
        public ImportCategories()
            : base()
        {
            inventoryTypes = new List<string>();
            inventoryTypes.AddRange(new string[] { "Bundle", "Inventory", "Kit", "Finished Good", "Non-Inventory", "Other Charge", "Raw Material", "Service", "Software", "Comment" });
        }

        private List<string> inventoryTypes;

        protected override string[] GetRequiredFields()
        {
            return new string[] { "category code", "inventory type", "costing method" };
        }

        protected override tblICCategory ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICCategory fc = new tblICCategory();
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
                    case "category code":
                        if (!SetText(value, del => fc.strCategoryCode = del, "Category Code", dr, header, row, true))
                            valid = false;
                        break;
                    case "description":
                        fc.strDescription = value;
                        break;
                    case "inventory type":
                        if (!SetFixedLookup(value, del => fc.strInventoryType = del, "Inventory Type", inventoryTypes, dr, header, row, true))
                            valid = false;
                        break;
                    case "line of business":
                        lu = InsertAndOrGetLookupId<tblICLineOfBusiness>(
                            context,
                            m => m.strLineOfBusiness == value,
                            e => e.intLineOfBusinessId,
                            new tblICLineOfBusiness()
                            {
                                strLineOfBusiness = value
                            }, out inserted);
                        if (inserted)
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_INFO,
                                Message = "Created new Line of Business item."
                            });
                            if (lu != null)
                            {
                                LogItems.Add(new ImportLogItem()
                                {
                                    Description = "Created new Line of Business item.",
                                    FromValue = "",
                                    ToValue = value,
                                    ActionIcon = ICON_ACTION_NEW
                                });
                            }
                        }
                        if (lu != null)
                            fc.intLineOfBusinessId = (int)lu;
                        break;
                    case "costing method":
                        switch (value.ToUpper().Trim())
                        {
                            case "AVG": fc.intCostingMethod = 1; break;
                            case "FIFO": fc.intCostingMethod = 2; break;
                            case "LIFO": fc.intCostingMethod = 3; break;
                            default: 
                                valid = false;
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_ERROR,
                                    Status = REC_SKIP,
                                    Message = string.Format("The value for Costing Method should not be blank.")
                                });
                                break;
                        }
                        break;
                    case "inventory valuation":
                        switch (value.ToLower())
                        {
                            case "item level": fc.strInventoryTracking = "Item Level"; break;
                            case "category level": fc.strInventoryTracking = "Category Level"; break;
                            case "lot level": fc.strInventoryTracking = "Lot Level"; break;
                        }
                        break;
                    case "gl division no":
                        fc.strGLDivisionNumber = value;
                        break;
                    case "sales analysis":
                        SetBoolean(value, flag => fc.ysnSalesAnalysisByTon = flag);
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICCategory>().Any(t => t.strCategoryCode == fc.strCategoryCode))
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
                        Message = "The record already exists: " + fc.strCategoryCode + ". The system does not allow existing records to be modified."
                    });
                    return null;
                }

                var entry = context.ContextManager.Entry<tblICCategory>(context.GetQuery<tblICCategory>().First(t => t.strCategoryCode == fc.strCategoryCode));
                entry.Property(e => e.strDescription).CurrentValue = fc.strDescription;
                entry.Property(e => e.strInventoryType).CurrentValue = fc.strInventoryType;
                entry.Property(e => e.intCostingMethod).CurrentValue = fc.intCostingMethod;
                entry.Property(e => e.intLineOfBusinessId).CurrentValue = fc.intLineOfBusinessId;
                entry.Property(e => e.ysnSalesAnalysisByTon).CurrentValue = fc.ysnSalesAnalysisByTon;
                entry.Property(e => e.strGLDivisionNumber).CurrentValue = fc.strGLDivisionNumber;
                entry.Property(e => e.strInventoryTracking).CurrentValue = fc.strInventoryTracking;
                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.strCategoryCode).IsModified = false;
            }
            else
            {
                context.AddNew<tblICCategory>(fc);
            }

            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICCategory entity)
        {
            return entity.intCategoryId;
        }
    }
}
