using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItems : ImportDataLogic<tblICItem>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "item no", "type", "category" };
        }

        protected override tblICItem ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICItem fc = new tblICItem()
            {
                intLifeTime = 0,
                ysnTaxable = false,
                ysnDropShip = false,
                ysnLandedCost = false,
                ysnCommisionable = false,
                ysnSpecialCommission = false
            };

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
                    case "item no":
                        valid = SetText(value, del => fc.strItemNo = del, "Item No", dr, header, row, true);
                        valid = !HasLocalDuplicate(dr, header, value, row);
                        break;
                    case "type":
                        switch (value.Trim().ToLower())
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
                                fc.strType = value;
                                break;
                            default:
                                fc.strType = "Inventory";
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Invalid item Type: " + value + ". Set default: 'Inventory'.",
                                    Status = STAT_INNER_DEF
                                });
                                break;
                        }
                        break;
                    case "short name":
                        fc.strShortName = value;
                        break;
                    case "description":
                        if (string.IsNullOrEmpty(value))
                            fc.strDescription = fc.strItemNo;
                        else
                            fc.strDescription = value;
                        break;
                    case "manufacturer":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = InsertAndOrGetLookupId<tblICManufacturer>(
                            context,
                            m => m.strManufacturer == value,
                            e => e.intManufacturerId,
                            new tblICManufacturer()
                            {
                                strManufacturer = value
                            }, out inserted);
                        if (inserted)
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_INFO,
                                Message = "Created new Manufacturer item: " + value + '.',
                                Status = STAT_INNER_SUCCESS
                            });
                            if (lu != null)
                            {
                                LogItems.Add(new ImportLogItem()
                                {
                                    Description = "Created new Manufacturer item.",
                                    FromValue = "",
                                    ToValue = value,
                                    ActionIcon = ICON_ACTION_NEW
                                });
                            }
                        }
                        if (lu != null)
                            fc.intManufacturerId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Manufacturer item: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "status":
                        switch (value.Trim().ToLower())
                        {
                            case "active":
                            case "phased out":
                            case "discontinued":
                                fc.strStatus = value;
                                break;
                            default:
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Invalid item Status: " + value + ". Set to default: 'Active'",
                                    Status = STAT_INNER_DEF
                                });
                                break;
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
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Commodity item: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "lot tracking":
                        if (value.Trim().ToLower().Contains("manual/serial"))
                            fc.strLotTracking = "Yes - Manual/Serial Number";
                        else if (value.Trim().ToLower().Contains("manual"))
                            fc.strLotTracking = "Yes - Manual";
                        else if (value.Trim().ToLower().Contains("serial"))
                            fc.strLotTracking = "Yes - Serial Number";
                        else
                        {
                            switch (value.Trim().ToLower())
                            {
                                case "no":
                                    fc.strLotTracking = "No";
                                    break;
                                case "yes - manual":
                                    fc.strLotTracking = "Yes - Manual";
                                    break;
                                case "yes - serial number":
                                    fc.strLotTracking = "Yes - Serial Number";
                                    break;
                                case "yes - manual/serial number":
                                    fc.strLotTracking = "Yes - Manual/Serial Number";
                                    break;
                                default:
                                    fc.strLotTracking = "No";
                                    //dr.Messages.Add(new ImportDataMessage()
                                    //{
                                    //    Column = header,
                                    //    Row = row,
                                    //    Type = TYPE_INNER_WARN,
                                    //    Message = "Invalid value for Lot Tracking: " + value + ". Lot Tracking set to default 'No'.",
                                    //    Status = STAT_INNER_DEF
                                    //});
                                    break;
                            }
                        }
                        if (value.Trim().ToLower() == "no")
                            fc.strInventoryTracking = "Item Level";
                        else
                            fc.strInventoryTracking = "Lot Level";
                        break;
                    case "brand":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICBrand>(
                            context,
                            m => m.strBrandCode == value,
                            e => e.intBrandId);
                        if (lu != null)
                            fc.intBrandId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Brand item: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "model no":
                        fc.strModelNo = value;
                        break;
                    case "category":
                        lu = GetLookUpId<tblICCategory>(
                            context,
                            m => m.strCategoryCode == value,
                            e => e.intCategoryId);
                        if (lu != null)
                        {
                            fc.intCategoryId = (int)lu;
                        }
                        else
                        {
                            valid = false;
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Category item: " + value + '.',
                                Status = TYPE_INNER_ERROR
                            });
                            dr.Info = INFO_ERROR;
                        }
                        break;
                    case "stocked item":
                        SetBoolean(value, del => fc.ysnStockedItem = del); 
                        break;
                    case "dyed fuel":
                        SetBoolean(value, del => fc.ysnDyedFuel = del);
                        break;
                    case "barcode print":
                        switch (value.Trim().ToLower())
                        {
                            case "upc":
                            case "item":
                            case "none":
                                fc.strBarcodePrint = value;
                                break;
                            default:
                                if (!string.IsNullOrEmpty(value))
                                {
                                    dr.Messages.Add(new ImportDataMessage()
                                    {
                                        Column = header,
                                        Row = row,
                                        Type = TYPE_INNER_WARN,
                                        Message = "Invalid value for Barcode Print: " + value + ".",
                                        Status = STAT_INNER_COL_SKIP
                                    });
                                }
                                break;
                        }
                        break;
                    case "msds required":
                        SetBoolean(value, del => fc.ysnMSDSRequired = del);
                        break;
                    case "epa number":
                        fc.strEPANumber = value;
                        break;
                    case "inbound tax":
                        SetBoolean(value, del => fc.ysnInboundTax = del);
                        break;
                    case "outbound tax":
                        SetBoolean(value, del => fc.ysnOutboundTax = del);
                        break;
                    case "restricted chemical":
                        SetBoolean(value, del => fc.ysnRestrictedChemical = del);
                        break;
                    case "fuel item":
                        SetBoolean(value, del => fc.ysnFuelItem = del);
                        break;
                    case "list bundle items separately":
                        SetBoolean(value, del => fc.ysnListBundleSeparately = del);
                        break;
                    case "fuel inspect fee":
                        if (string.IsNullOrEmpty(value))
                            break;
                        switch (value.Trim().ToLower())
                        {
                            case "yes (fuel item)":
                            case "no (not fuel item)":
                            case "no (fuel item)":
                                fc.strFuelInspectFee = value;
                                break;
                            default:
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Invalid Fuel Inspect Fee: " + value + ".",
                                    Status = STAT_INNER_COL_SKIP
                                });
                                break;
                        }
                        break;
                    case "rin required":
                        if (string.IsNullOrEmpty(value))
                            break;
                        switch (value.Trim().ToLower())
                        {
                            case "no rin":
                            case "resell rin only":
                            case "issued":
                                fc.strRINRequired = value;
                                break;
                            default:
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Invalid value for RIN Required: " + value + ".",
                                    Status = STAT_INNER_COL_SKIP
                                });
                                break;
                        }
                        break;
                    case "fuel category":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICRinFuelCategory>(
                            context,
                            m => m.strRinFuelCategoryCode == value,
                            e => e.intRinFuelCategoryId);
                        if (lu != null)
                            fc.intRINFuelTypeId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Fuel Category item: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "denaturant percentage":
                        SetDecimal(value, del => fc.dblDenaturantPercent = del, "Denaturant Percentage", dr, header, row);
                        break;
                    case "tonnage tax":
                        SetBoolean(value, del => fc.ysnTonnageTax = del);
                        break;
                    case "load tracking":
                        SetBoolean(value, del => fc.ysnLoadTracking = del);
                        break;
                    case "mix order":
                        SetDecimal(value, del => fc.dblMixOrder = del, "Mix Order", dr, header, row);
                        break;
                    case "hand add ingredients":
                        SetBoolean(value, del => fc.ysnHandAddIngredient = del);
                        break;
                    case "medication tag":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICTag>(
                            context,
                            m => m.strTagNumber == value,
                            e => e.intTagId);
                        if (lu != null)
                            fc.intMedicationTag = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Medication Tag item: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "ingredient tag":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblICTag>(
                            context,
                            m => m.strTagNumber == value,
                            e => e.intTagId);
                        if (lu != null)
                            fc.intIngredientTag = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Ingredient Tag item: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "volume rebate group":
                        fc.strVolumeRebateGroup = value;
                        break;
                    case "physical item":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<vyuICGetCompactItem>(
                            context,
                            m => m.strItemNo == value,
                            e => e.intItemId);
                        if (lu != null)
                            fc.intPhysicalItem = (int)lu;
                        break;
                    case "extend pick ticket":
                        SetBoolean(value, del => fc.ysnExtendPickTicket = del);
                        break;
                    case "export edi":
                        SetBoolean(value, del => fc.ysnExportEDI = del);
                        break;
                    case "hazard material":
                        SetBoolean(value, del => fc.ysnHazardMaterial = del);
                        break;
                    case "material fee":
                        SetBoolean(value, del => fc.ysnMaterialFee = del);
                        break;
                    case "auto blend":
                        SetBoolean(value, del => fc.ysnAutoBlend = del);
                        break;
                    case "user group fee percentage":
                        SetDecimal(value, del => fc.dblUserGroupFee = del, "User Group Fee Percentage", dr, header, row);
                        break;
                    case "wgt tolerance percentage":
                        SetDecimal(value, del => fc.dblWeightTolerance = del, "Wgt Tolerance Percentage", dr, header, row);
                        break;
                    case "over receive tolerance percentage":
                        SetDecimal(value, del => fc.dblOverReceiveTolerance = del, "Over Receive Tolerance Percentage", dr, header, row);
                        break;
                    case "maintenance calculation method":
                        if (string.IsNullOrEmpty(value))
                            break;
                        switch (value.Trim().ToLower())
                        {
                            case "percentage":
                            case "fixed":
                                fc.strMaintenanceCalculationMethod = value;
                                break;
                            default:
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Invalid Maintenance Calculation Method: " + value + ".",
                                    Status = STAT_INNER_COL_SKIP
                                });
                                break;
                        }
                        break;
                    case "rate":
                        SetDecimal(value, del => fc.dblMaintenanceRate = del, "Rate", dr, header, row);
                        break;
                    case "nacs category":
                        fc.strNACSCategory = value;
                        break;
                    case "wic code":
                        if (string.IsNullOrEmpty(value))
                            break;
                        switch (value.Trim().ToLower())
                        {
                            case "woman":
                            case "infant":
                            case "child":
                                fc.strWICCode = value;
                                break;
                            default:
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Invalid WIC Code: " + value + ".",
                                    Status = STAT_INNER_COL_SKIP
                                });
                                break;
                        }
                        break;
                    case "receipt comment req":
                        SetBoolean(value, del => fc.ysnReceiptCommentRequired = del);
                        break;
                    case "count code":
                        if (string.IsNullOrEmpty(value))
                            break;
                        switch (value.Trim().ToLower())
                        {
                            case "item":
                            case "package":
                            case "cases":
                                fc.strCountCode = value;
                                break;
                            default:
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Invalid Count Code: " + value + ".",
                                    Status = STAT_INNER_COL_SKIP
                                });
                                break;
                        }
                        break;
                    case "landed cost":
                        SetBoolean(value, del => fc.ysnLandedCost = del);
                        break;
                    case "lead time":
                        fc.strLeadTime = value;
                        break;
                    case "taxable":
                        SetBoolean(value, del => fc.ysnTaxable = del);
                        break;
                    case "keywords":
                        fc.strKeywords = value;
                        break;
                    case "case qty":
                        SetDecimal(value, del => fc.dblCaseQty = del, "Case Qty", dr, header, row);
                        break;
                    case "date ship":
                        SetDate(value, del => fc.dtmDateShip = del, "Date Ship", dr, header, row);
                        break;
                    case "tax exempt":
                        SetDecimal(value, del => fc.dblTaxExempt = del, "Tax Exempt", dr, header, row);
                        break;
                    case "drop ship":
                        SetBoolean(value, del => fc.ysnDropShip = del);
                        break;
                    case "commissionable":
                        SetBoolean(value, del => fc.ysnCommisionable = del);
                        break;
                    case "special commission":
                        SetBoolean(value, del => fc.ysnSpecialCommission = del);
                        break;
                    case "tank required":
                        SetBoolean(value, del => fc.ysnTankRequired = del);
                        break;
                    case "available for tm":
                        SetBoolean(value, del => fc.ysnAvailableTM = del);
                        break;
                    case "default percentage full":
                        SetDecimal(value, del => fc.dblDefaultFull = del, "Default Percentage Full", dr, header, row);
                        break;
                    case "patronage category":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblPATPatronageCategory>(
                            context,
                            m => m.strCategoryCode == value,
                            e => e.intPatronageCategoryId);
                        if (lu != null)
                            fc.intPatronageCategoryId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Patronage Category: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "direct sale":
                        if (string.IsNullOrEmpty(value))
                            break;
                        lu = GetLookUpId<tblPATPatronageCategory>(
                            context,
                            m => m.strCategoryCode == value,
                            e => e.intPatronageCategoryId);
                        if (lu != null)
                            fc.intPatronageCategoryDirectId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Direct Sale: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICItem>().Any(t => t.strItemNo == fc.strItemNo))
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
                        Message = "The record already exists: " + fc.strItemNo + ". The system does not allow existing records to be modified."
                    });
                    return null;
                }

                var entry = context.ContextManager.Entry<tblICItem>(context.GetQuery<tblICItem>().First(t => t.strItemNo == fc.strItemNo));
                entry.Property(e => e.strDescription).CurrentValue = fc.strDescription;
                entry.Property(e => e.strType).CurrentValue = fc.strType;
                entry.Property(e => e.intLifeTime).CurrentValue = fc.intLifeTime;
                entry.Property(e => e.ysnDropShip).CurrentValue = fc.ysnDropShip;
                entry.Property(e => e.ysnTaxable).CurrentValue = fc.ysnTaxable;
                entry.Property(e => e.ysnLandedCost).CurrentValue = fc.ysnLandedCost;
                entry.Property(e => e.ysnSpecialCommission).CurrentValue = fc.ysnSpecialCommission;
                entry.Property(e => e.ysnCommisionable).CurrentValue = fc.ysnCommisionable;
                entry.Property(e => e.ysnStockedItem).CurrentValue = fc.ysnStockedItem;
                entry.Property(e => e.ysnDyedFuel).CurrentValue = fc.ysnDyedFuel;
                entry.Property(e => e.ysnMSDSRequired).CurrentValue = fc.ysnMSDSRequired;
                entry.Property(e => e.ysnInboundTax).CurrentValue = fc.ysnInboundTax;
                entry.Property(e => e.ysnOutboundTax).CurrentValue = fc.ysnOutboundTax;
                entry.Property(e => e.ysnRestrictedChemical).CurrentValue = fc.ysnRestrictedChemical;
                entry.Property(e => e.ysnFuelItem).CurrentValue = fc.ysnFuelItem;
                entry.Property(e => e.ysnListBundleSeparately).CurrentValue = fc.ysnListBundleSeparately;
                entry.Property(e => e.ysnTonnageTax).CurrentValue = fc.ysnTonnageTax;
                entry.Property(e => e.ysnLoadTracking).CurrentValue = fc.ysnLoadTracking;
                entry.Property(e => e.ysnExtendPickTicket).CurrentValue = fc.ysnExtendPickTicket;
                entry.Property(e => e.ysnExportEDI).CurrentValue = fc.ysnExportEDI;
                entry.Property(e => e.ysnHazardMaterial).CurrentValue = fc.ysnHazardMaterial;
                entry.Property(e => e.ysnAutoBlend).CurrentValue = fc.ysnAutoBlend;
                entry.Property(e => e.ysnHandAddIngredient).CurrentValue = fc.ysnHandAddIngredient;
                entry.Property(e => e.dblMixOrder).CurrentValue = fc.dblMixOrder;
                entry.Property(e => e.dblUserGroupFee).CurrentValue = fc.dblUserGroupFee;
                entry.Property(e => e.dblWeightTolerance).CurrentValue = fc.dblWeightTolerance;
                entry.Property(e => e.dblOverReceiveTolerance).CurrentValue = fc.dblOverReceiveTolerance;
                entry.Property(e => e.dblMaintenanceRate).CurrentValue = fc.dblMaintenanceRate;
                entry.Property(e => e.strMaintenanceCalculationMethod).CurrentValue = fc.strMaintenanceCalculationMethod;
                entry.Property(e => e.strFuelInspectFee).CurrentValue = fc.strFuelInspectFee;
                entry.Property(e => e.strNACSCategory).CurrentValue = fc.strNACSCategory;
                entry.Property(e => e.strWICCode).CurrentValue = fc.strWICCode;
                entry.Property(e => e.ysnReceiptCommentRequired).CurrentValue = fc.ysnReceiptCommentRequired;
                entry.Property(e => e.ysnLandedCost).CurrentValue = fc.ysnLandedCost;
                entry.Property(e => e.strKeywords).CurrentValue = fc.strKeywords;
                entry.Property(e => e.dblCaseQty).CurrentValue = fc.dblCaseQty;
                entry.Property(e => e.dtmDateShip).CurrentValue = fc.dtmDateShip;
                entry.Property(e => e.dblTaxExempt).CurrentValue = fc.dblTaxExempt;
                entry.Property(e => e.ysnTankRequired).CurrentValue = fc.ysnTankRequired;
                entry.Property(e => e.ysnAvailableTM).CurrentValue = fc.ysnAvailableTM;
                entry.Property(e => e.strCountCode).CurrentValue = fc.strCountCode;
                entry.Property(e => e.strRINRequired).CurrentValue = fc.strRINRequired;
                entry.Property(e => e.intRINFuelTypeId).CurrentValue = fc.intRINFuelTypeId;
                entry.Property(e => e.dblDenaturantPercent).CurrentValue = fc.dblDenaturantPercent;
                entry.Property(e => e.strEPANumber).CurrentValue = fc.strEPANumber;
                entry.Property(e => e.strBarcodePrint).CurrentValue = fc.strBarcodePrint;
                entry.Property(e => e.strShortName).CurrentValue = fc.strShortName;
                entry.Property(e => e.intManufacturerId).CurrentValue = fc.intManufacturerId;
                entry.Property(e => e.strStatus).CurrentValue = fc.strStatus;
                entry.Property(e => e.intCommodityId).CurrentValue = fc.intCommodityId;
                entry.Property(e => e.strLotTracking).CurrentValue = fc.strLotTracking;
                entry.Property(e => e.intBrandId).CurrentValue = fc.intBrandId;
                entry.Property(e => e.strModelNo).CurrentValue = fc.strModelNo;
                entry.Property(e => e.intCategoryId).CurrentValue = fc.intCategoryId;
                entry.Property(e => e.intMedicationTag).CurrentValue = fc.intMedicationTag;
                entry.Property(e => e.intIngredientTag).CurrentValue = fc.intIngredientTag;
                entry.Property(e => e.strVolumeRebateGroup).CurrentValue = fc.strVolumeRebateGroup;
                entry.Property(e => e.intPhysicalItem).CurrentValue = fc.intPhysicalItem;
                entry.Property(e => e.dblDefaultFull).CurrentValue = fc.dblDefaultFull;
                entry.Property(e => e.intPatronageCategoryId).CurrentValue = fc.intPatronageCategoryId;
                entry.Property(e => e.intPatronageCategoryDirectId).CurrentValue = fc.intPatronageCategoryDirectId;
                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.strItemNo).IsModified = false;

                dr.IsUpdate = true;
            }
            else
            {
                context.AddNew<tblICItem>(fc);
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICItem entity)
        {
            return entity.intItemId;
        }

        protected override string GetViewNamespace()
        {
            return "Inventory.view.Item";
        }
    }
}
