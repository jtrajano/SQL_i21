using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Globalization;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportCategories : ImportDataLogic<tblICCategory>
    {
        private List<string> inventoryTypes;

        public ImportCategories(DbContext context, byte[] data, string username) : base(context, data, username)
        {
            inventoryTypes = new List<string>();
            inventoryTypes.AddRange(new string[] { "Bundle", "Inventory", "Kit", "Finished Good", "Non-Inventory", "Other Charge", "Raw Material", "Service", "Software", "Comment" });
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "category code", "inventory type", "costing method" };
        }

        public override tblICCategory Process(CsvRecord record)
        {
            var entity = new tblICCategory();
            var valid = true;
            valid = SetText(record, "Category Code", e => entity.strCategoryCode = e, true);
            SetText(record, "Description", e => entity.strDescription = e, false);
            valid = SetFixedLookup(record, "Inventory Type", e => entity.strInventoryType = e, inventoryTypes, true);
            SetBoolean(record, "Sales Analysis", e => entity.ysnSalesAnalysisByTon = e);
            SetText(record, "GL Division No", e => entity.strGLDivisionNumber = e);
            var lob = GetFieldValue(record, "Line of Business");
            SetLookupId<tblSMLineOfBusiness>(record, "Line of Business", (e => e.strLineOfBusiness == lob), e => e.intLineOfBusinessId, e => entity.intLineOfBusinessId = e, false);

            if (valid)
                return entity;
            return entity;
        }

        public override void Initialize()
        {
            base.Initialize();
            AddPipe(new ValuationPipe(context, ImportResult));
            AddPipe(new CostingMethodPipe(context, ImportResult));
        }

        class ValuationPipe : CsvPipe<tblICCategory>
        {
            public ValuationPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICCategory Process(tblICCategory input)
            {
                var entity = input;
                var value = GetFieldValue("Inventory Valuation");

                switch (value.ToLower())
                {
                    case "category level":
                        entity.strInventoryTracking = "Category Level";
                        break;
                    case "lot level":
                        entity.strInventoryTracking = "Lot Level";
                        break;
                    default:
                        entity.strInventoryTracking = "Item Level";
                        break;
                }

                return entity;
            }
        }

        class CostingMethodPipe : CsvPipe<tblICCategory>
        {
            public CostingMethodPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICCategory Process(tblICCategory input)
            {
                var entity = input;
                var value = GetFieldValue("Costing Method");

                switch (value.ToUpper())
                {
                    case "AVG": entity.intCostingMethod = 1; break;
                    case "FIFO": entity.intCostingMethod = 2; break;
                    case "LIFO": entity.intCostingMethod = 3; break;
                    default:
                        if (string.IsNullOrEmpty(value.Trim()))
                        {
                            if (entity.strInventoryType == "Inventory" || entity.strInventoryType == "Finished Good" || entity.strInventoryType == "Raw Material")
                            {
                                var msg = new ImportDataMessage()
                                {
                                    Column = "Costing Method",
                                    Row = Record.RecordNo,
                                    Type = Constants.TYPE_ERROR,
                                    Status = Constants.STAT_FAILED,
                                    Action = Constants.ACTION_SKIPPED ,
                                    Exception = null,
                                    Value = value,
                                    Message = string.Format("The value for {0} should not be blank.", "Costing Method")
                                };
                                Result.AddError(msg);
                                return null;
                            }
                        }
                        break;
                }

                return entity;
            }
        }

        protected override Expression<Func<tblICCategory, bool>> GetUniqueKeyExpression(tblICCategory entity)
        {
            return (e => e.strCategoryCode == entity.strCategoryCode);
        }

        protected override string GetPrimaryKeyName()
        {
            return "intCategoryId";
        }

        public override int GetPrimaryKeyValue(tblICCategory entity)
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
