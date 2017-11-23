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
            return new string[] { "category code", "inventory type" };
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
                string inventoryType = "";

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
                        inventoryType = value;
                        if (!SetFixedLookup(value, del => fc.strInventoryType = del, "Inventory Type", inventoryTypes, dr, header, row, true))
                            valid = false;
                        break;
                    case "line of business":
                        // Get the default sales person
                        //int intEntitySalespersonId = 0; 

                        //var query = "SELECT intEntitySalespersonId, strSalespersonId, strName FROM vyuEMSalesperson";
                        //IEnumerable<vyuEMSalesperson> salesReps = context.ContextManager.Database.SqlQuery<vyuEMSalesperson>(query);
                        //try
                        //{
                        //    vyuEMSalesperson salesRep = salesReps.First();

                        //    if (salesRep != null)
                        //        intEntitySalespersonId = salesRep.intEntitySalespersonId;
                        //    else
                        //    {
                        //        dr.Messages.Add(new ImportDataMessage()
                        //        {
                        //            Column = header,
                        //            Row = row,
                        //            Type = TYPE_INNER_WARN,
                        //            Message = "Can't find default Sales Rep for Line of Business: " + value + '.',
                        //            Status = STAT_INNER_COL_SKIP
                        //        });
                        //        dr.Info = INFO_WARN;
                        //    }
                        //}
                        //catch (Exception)
                        //{
                        //    dr.Messages.Add(new ImportDataMessage()
                        //    {
                        //        Column = header,
                        //        Row = row,
                        //        Type = TYPE_INNER_WARN,
                        //        Message = "Can't find default Sales Rep for Line of Business: " + value + '.',
                        //        Status = STAT_INNER_COL_SKIP
                        //    });
                        //    dr.Info = INFO_WARN;
                        //}

                        // Find or Insert a new Line of Business record. 
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblSMLineOfBusiness>(
                            context,
                            m => m.strLineOfBusiness == value,
                            e => e.intLineOfBusinessId);
                        if (lu != null)
                            fc.intLineOfBusinessId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find default Sales Rep for Line of Business: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                        }
                        break;
                    //case "costing method":
                    //    switch (value.ToUpper().Trim())
                    //    {
                    //        case "AVG": fc.intCostingMethod = 1; break;
                    //        case "FIFO": fc.intCostingMethod = 2; break;
                    //        case "LIFO": fc.intCostingMethod = 3; break;
                    //        default:
                    //            if (string.IsNullOrEmpty(value.Trim()))
                    //            {
                    //                if (inventoryType == "Inventory" || inventoryType == "Finished Good" || inventoryType == "Raw Material")
                    //                {
                    //                    valid = false;
                    //                    dr.Messages.Add(new ImportDataMessage()
                    //                    {
                    //                        Column = header,
                    //                        Row = row,
                    //                        Type = TYPE_INNER_ERROR,
                    //                        Status = STAT_REC_SKIP,
                    //                        Message = string.Format("The value for Costing Method should not be blank.")
                    //                    });
                    //                }
                    //            }
                    //            break;
                    //    }
                    //    break;
                    //case "inventory valuation":
                    //    switch (value.ToLower())
                    //    {
                    //        case "item level": fc.strInventoryTracking = "Item Level"; break;
                    //        case "category level": fc.strInventoryTracking = "Category Level"; break;
                    //        case "lot level": fc.strInventoryTracking = "Lot Level"; break;
                    //    }
                    //    break;
                    //case "gl division no":
                    //    fc.strGLDivisionNumber = value;
                    //    break;
                    //case "sales analysis":
                    //    SetBoolean(value, flag => fc.ysnSalesAnalysisByTon = flag);
                    //    break;
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
                        Status = STAT_REC_SKIP,
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
                //entry.Property(e => e.intLineOfBusinessId).CurrentValue = fc.intLineOfBusinessId;
                //entry.Property(e => e.ysnSalesAnalysisByTon).CurrentValue = fc.ysnSalesAnalysisByTon;
                //entry.Property(e => e.strGLDivisionNumber).CurrentValue = fc.strGLDivisionNumber;
                //entry.Property(e => e.strInventoryTracking).CurrentValue = fc.strInventoryTracking;
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
        
        public class vyuEMSalesperson
        {
            public int intEntityId { get; set; }
            public string strSalespersonId { get; set; }
            public string strName { get; set; }
        }
    }
}
