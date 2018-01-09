using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity;
using System.Linq.Expressions;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItems : ImportDataLogic<tblICItem>
    {
        public ImportItems(DbContext context, byte[] data) : base(context, data)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] { "item no", "type" };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intItemId";
        }

        protected override Expression<Func<tblICItem, bool>> GetUniqueKeyExpression(tblICItem entity)
        {
            return (e => e.strItemNo == entity.strItemNo);
        }

        public override int GetPrimaryKeyValue(tblICItem entity)
        {
            return entity.intItemId;
        }

        public override tblICItem Process(CsvRecord record)
        {
            var entity = new tblICItem()
            {
                intLifeTime = 0,
                ysnTaxable = false,
                ysnDropShip = false,
                ysnLandedCost = false,
                ysnCommisionable = false,
                ysnSpecialCommission = false
            };

            var valid = true;

            valid = SetText(record, "Item No", e => entity.strItemNo = e, required: true);
            valid = SetText(record, "Type", e => entity.strType = e, required: true);
            SetText(record, "Short Name", e => entity.strShortName = e);
            var desc = GetFieldValue(record, "Description");
            desc = string.IsNullOrEmpty(desc) ? entity.strItemNo : desc;
            SetText(desc, e => entity.strDescription = e);
            var lu = GetFieldValue(record, "Manufacturer");
            SetLookupId<tblICManufacturer>(record, "Manufacturer", e => e.strManufacturer == lu, e => e.intManufacturerId, e => entity.intManufacturerId = e);
            lu = GetFieldValue(record, "Commodity");
            SetLookupId<tblICCommodity>(record, "Commodity", e => e.strCommodityCode == lu, e => e.intCommodityId, e => entity.intCommodityId = e);
            lu = GetFieldValue(record, "Brand");
            SetLookupId<tblICBrand>(record, "Brand", e => e.strBrandCode == lu, e => e.intBrandId, e => entity.intBrandId = e);
            SetText(record, "Model No", e => entity.strModelNo = e);
            lu = GetFieldValue(record, "Category");
            SetLookupId<tblICCategory>(record, "Category", e => e.strCategoryCode == lu, e => e.intCategoryId, e => entity.intCategoryId = e);
            SetBoolean(record, "Stocked Item", e => entity.ysnStockedItem = e);
            SetBoolean(record, "Dyed Fuel", e => entity.ysnDyedFuel = e);
            SetBoolean(record, "MSDS Required", e => entity.ysnMSDSRequired = e);
            SetText(record, "EPA Number", e => entity.strEPANumber = e);
            SetBoolean(record, "Inbound Tax", e => entity.ysnInboundTax = e);
            SetBoolean(record, "Outbound Tax", e => entity.ysnOutboundTax = e);
            SetBoolean(record, "Restricted Chemical", e => entity.ysnRestrictedChemical = e);
            SetBoolean(record, "Fuel Item", e => entity.ysnFuelItem = e);
            SetBoolean(record, "List Bundle Items Separately", e => entity.ysnListBundleSeparately = e);
            SetDecimal(record, "Denaturant Percentage", e => entity.dblDenaturantPercent = e);
            SetBoolean(record, "Tonnage Tax", e => entity.ysnTonnageTax = e);
            SetBoolean(record, "Load Tracking", e => entity.ysnLoadTracking = e);
            SetDecimal(record, "Mix Order", e => entity.dblMixOrder = e);
            SetBoolean(record, "Hand Add Ingredients", e => entity.ysnHandAddIngredient = e);
            SetBoolean(record, "Extend Pick Ticket", e => entity.ysnExtendPickTicket = e);
            SetBoolean(record, "Export EDI", e => entity.ysnExportEDI = e);
            SetBoolean(record, "Hazard Material", e => entity.ysnHazardMaterial = e);
            SetBoolean(record, "Material Fee", e => entity.ysnMaterialFee = e);
            SetBoolean(record, "Auto Blend", e => entity.ysnAutoBlend = e);
            SetDecimal(record, "User Group Fee Percentage", e => entity.dblUserGroupFee = e);
            SetDecimal(record, "Wgt Tolerance Percentage", e => entity.dblWeightTolerance = e);
            SetDecimal(record, "Over Receive Tolerance Percentage", e => entity.dblOverReceiveTolerance = e);
            SetBoolean(record, "Landed Cost", e => entity.ysnLandedCost = e);
            SetText(record, "Lead Time", e => entity.strLeadTime = e);
            SetBoolean(record, "Taxable", e => entity.ysnTaxable = e);
            SetText(record, "Keywords", e => entity.strKeywords = e);
            SetDecimal(record, "Case Qty", e => entity.dblCaseQty = e);
            SetDate(record, "Date Ship", e => entity.dtmDateShip = e);
            SetDecimal(record, "Tax Exempt", e => entity.dblTaxExempt = e);
            SetBoolean(record, "Drop Ship", e => entity.ysnDropShip = e);
            SetBoolean(record, "Commossionable", e => entity.ysnCommisionable = e);
            SetBoolean(record, "Special Commission", e => entity.ysnSpecialCommission = e);
            SetBoolean(record, "Tank Required", e => entity.ysnTankRequired = e);
            SetBoolean(record, "Available for TM", e => entity.ysnAvailableTM = e);
            SetDecimal(record, "Default Percentage Full", e => entity.dblDefaultFull = e);
            SetDecimal(record, "Rate", e => entity.dblMaintenanceRate = e);
            SetText(record, "NACS Category", e => entity.strNACSCategory = e);
            SetBoolean(record, "Receipt Comment Req", e => entity.ysnReceiptCommentRequired = e);
            lu = GetFieldValue(record, "Direct Sale");
            SetLookupId<tblPATPatronageCategory>(record, "Direct Sale", e => e.strCategoryCode == lu, e => e.intPatronageCategoryId, e => entity.intPatronageCategoryDirectId = e);
            lu = GetFieldValue(record, "Patronage Category");
            SetLookupId<tblPATPatronageCategory>(record, "Patronage Category", e => e.strCategoryCode == lu, e => e.intPatronageCategoryId, e => entity.intPatronageCategoryId = e);
            lu = GetFieldValue(record, "Physical Item");
            SetLookupId<vyuICGetCompactItem>(record, "Physical Item", e => e.strItemNo == lu, e => e.intItemId, e => entity.intPhysicalItem = e);
            SetText(record, "Volume Rebate Group", e => entity.strVolumeRebateGroup = e);
            lu = GetFieldValue(record, "Ingredient Tag");
            SetLookupId<tblICTag>(record, "Ingredient Tag", e => e.strTagNumber == lu, e => e.intTagId, e => entity.intIngredientTag = e);
            lu = GetFieldValue(record, "Medication Tag");
            SetLookupId<tblICTag>(record, "Medication Tag", e => e.strTagNumber == lu, e => e.intTagId, e => entity.intMedicationTag = e);
            lu = GetFieldValue(record, "Fuel Category");
            SetLookupId<tblICRinFuelCategory>(record, "Fuel Category", e => e.strRinFuelCategoryCode == lu, e => e.intRinFuelCategoryId, e => entity.intRINFuelTypeId = e);

            if (valid)
                return entity;

            return null;
        }

        public override void Initialize()
        {
            base.Initialize();
            AddPipe(new TypePipe(context, ImportResult));
            AddPipe(new MaintenanceCalcPipe(context, ImportResult));
            AddPipe(new WICCodePipe(context, ImportResult));
            AddPipe(new CountCodePipe(context, ImportResult));
            AddPipe(new RinRequiredPipe(context, ImportResult));
            AddPipe(new StatusPipe(context, ImportResult));
            AddPipe(new LotTrackingPrintPipe(context, ImportResult));
            AddPipe(new BarCodePrintPipe(context, ImportResult));
            AddPipe(new FuelInspectFeePipe(context, ImportResult));
        }

        class TypePipe : CsvPipe<tblICItem>
        {
            public TypePipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItem Process(tblICItem input)
            {
                var value = GetFieldValue("Type");
                switch(value.Trim().ToLower())
                {
                    case "bundle":
                    case "inventory":
                    case "kit":
                    case "finished good":
                    case "non-inventory":
                    case "other charge":
                    case "raw material":
                    case "service":
                    case "software":
                    case "comment":
                        input.strType = value;
                        break;
                    default:
                        input.strType = "Inventory";
                        AddWarning(header: "Type", message: $"Invalid item type: {value}. Set to default: 'Inventory'.");
                        break;
                }

                return input;
            }
        }

        class MaintenanceCalcPipe : CsvPipe<tblICItem>
        {
            public MaintenanceCalcPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItem Process(tblICItem input)
            {
                var value = GetFieldValue("Maintenance Calculation Method");
                switch (value.Trim().ToLower())
                {
                    case "percentage":
                    case "fixed":
                        input.strMaintenanceCalculationMethod = value;
                        break;
                    default:
                        AddWarning("Maintenance Calculation Method", $"Invalid Maintenance Calculation Method: {value}.");
                        break;
                }

                return input;
            }
        }

        class WICCodePipe : CsvPipe<tblICItem>
        {
            public WICCodePipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItem Process(tblICItem input)
            {
                var value = GetFieldValue("Wic Code");
                switch (value.Trim().ToLower())
                {
                    case "woman":
                    case "infant":
                    case "child":
                        input.strWICCode = value;
                        break;
                    default:
                        AddWarning("Wic Code", $"Invalid Wic Code: {value}.");
                        break;
                }

                return input;
            }
        }

        class CountCodePipe : CsvPipe<tblICItem>
        {
            public CountCodePipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItem Process(tblICItem input)
            {
                var value = GetFieldValue("Count Code");
                switch (value.Trim().ToLower())
                {
                    case "item":
                    case "package":
                    case "cases":
                        input.strCountCode = value;
                        break;
                    default:
                        AddWarning("Count Code", $"Invalid Count Code: {value}.");
                        break;
                }

                return input;
            }
        }

        class RinRequiredPipe : CsvPipe<tblICItem>
        {
            public RinRequiredPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItem Process(tblICItem input)
            {
                var value = GetFieldValue("Rin Required");
                switch (value.Trim().ToLower())
                {
                    case "no rin":
                    case "resell rin only":
                    case "issued":
                        input.strRINRequired = value;
                        break;
                    default:
                        AddWarning(header: "Type", message: $"Invalid value for Rin Required: {value}.");
                        break;
                }

                return  input;
            }
        }

        class StatusPipe : CsvPipe<tblICItem>
        {
            public StatusPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItem Process(tblICItem input)
            {
                var value = GetFieldValue("Status");
                switch (value.Trim().ToLower())
                {
                    case "active":
                    case "phased out":
                    case "discontinued":
                        input.strStatus = value;
                        break;
                    default:
                        AddWarning(header: "Type", message: $"Invalid item status: {value}. Set to default: 'Active'.");
                        break;
                }

                return  input;
            }
        }

        class LotTrackingPrintPipe : CsvPipe<tblICItem>
        {
            public LotTrackingPrintPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItem Process(tblICItem input)
            {
                var value = GetFieldValue("Lot Tracking");
                if (value.Trim().ToLower().Contains("manual/serial"))
                    input.strLotTracking = "Yes - Manual/Serial Number";
                else if (value.Trim().ToLower().Contains("manual"))
                    input.strLotTracking = "Yes - Manual";
                else if (value.Trim().ToLower().Contains("serial"))
                    input.strLotTracking = "Yes - Serial Number";
                else
                {
                    switch (value.Trim().ToLower())
                    {
                        case "no":
                            input.strLotTracking = "No";
                            break;
                        case "yes - manual":
                            input.strLotTracking = "Yes - Manual";
                            break;
                        case "yes - serial number":
                            input.strLotTracking = "Yes - Serial Number";
                            break;
                        case "yes - manual/serial number":
                            input.strLotTracking = "Yes - Manual/Serial Number";
                            break;
                        default:
                            input.strLotTracking = "No";
                            break;
                    }
                }
                if (value.Trim().ToLower() == "no")
                    input.strInventoryTracking = "Item Level";
                else
                    input.strInventoryTracking = "Lot Level";
                
                return input;
            }
        }

        class BarCodePrintPipe : CsvPipe<tblICItem>
        {
            public BarCodePrintPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItem Process(tblICItem input)
            {
                var value = GetFieldValue("Barcode Print");
                switch (value.Trim().ToLower())
                {
                    case "upc":
                    case "item":
                    case "none":
                        input.strBarcodePrint = value;
                        break;
                    default:
                        AddWarning("Barcode Print", $"Invalid value for Barcode Print: {value}.");
                        break;
                }

                return  input;
            }
        }

        class FuelInspectFeePipe : CsvPipe<tblICItem>
        {
            public FuelInspectFeePipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItem Process(tblICItem input)
            {
                var value = GetFieldValue("Fuel Inspect Fee");
                switch (value.Trim().ToLower())
                {
                    case "yes (fuel item)":
                    case "no (not fuel item)":
                    case "no (fuel item)":
                        input.strFuelInspectFee = value;
                        break;
                    default:
                        AddWarning("Fuel Inspect Fee", $"Invalid value for Fuel Inpsect Fee: {value}.");
                        break;
                }
                return input;
            }
        }

        protected override string GetViewNamespace()
        {
            return "Inventory.view.Item";
        }
    }
}
