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
            return new string[] { "item no", "category" };
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
                if (!valid)
                    break;

                string header = headers[i];
                string value = csv[header];

                string h = header.ToLower().Trim();
                int? lu = null;
                bool inserted = false;
                switch (h)
                {
                    case "item no":
                        valid = SetText(value, del => fc.strItemNo = del, "Item No", dr, header, row, true);
                        break;
                    case "type":
                        fc.strType = value;
                        break;
                    case "short name":
                        fc.strShortName = value;
                        break;
                    case "description":
                        fc.strDescription = value;
                        break;
                    case "manufacturer":
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
                                Type = "Info",
                                Message = "Inserted new Manufacturer item: " + value + '.',
                                Status = "Success"
                            });
                            if (lu != null)
                            {
                                LogItems.Add(new ImportLogItem()
                                {
                                    Description = "Created new Manufacturer item.",
                                    FromValue = "",
                                    ToValue = value,
                                    ActionIcon = "small-new-plus"
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
                                Type = "Warning",
                                Message = "Can't find Manufacturer item: " + value + '.',
                                Status = "Ignored"
                            });
                            dr.Info = "warning";
                        }
                        break;
                    case "status":
                        fc.strStatus = value;
                        break;
                    case "commodity":
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
                                Type = "Warning",
                                Message = "Can't find Commodity item: " + value + '.',
                                Status = "Ignored"
                            });
                            dr.Info = "warning";
                        }
                        break;
                    case "lot tracking":
                        fc.strLotTracking = value;
                        break;
                    case "brand":
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
                                Type = "Warning",
                                Message = "Can't find Brand item: " + value + '.',
                                Status = "Ignored"
                            });
                            dr.Info = "warning";
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
                            fc.intCategoryId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = "Warning",
                                Message = "Can't find Category item: " + value + '.',
                                Status = "Ignored"
                            });
                            dr.Info = "warning";
                        }
                        break;
                    case "stocked item":
                        SetBoolean(value, del => fc.ysnStockedItem = del); 
                        break;
                    case "dyed fuel":
                        SetBoolean(value, del => fc.ysnDyedFuel = del);
                        break;
                    case "barcode print":
                        fc.strBarcodePrint = value;
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
                        fc.strFuelInspectFee = value;
                        break;
                    case "rin required":
                        fc.strRINRequired = value;
                        break;
                    case "fuel category":
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
                                Type = "Warning",
                                Message = "Can't find Fuel Category item: " + value + '.',
                                Status = "Ignored"
                            });
                            dr.Info = "warning";
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
                                Type = "Warning",
                                Message = "Can't find Medication Tag item: " + value + '.',
                                Status = "Ignored"
                            });
                            dr.Info = "warning";
                        }
                        break;
                    case "ingredient tag":
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
                                Type = "Warning",
                                Message = "Can't find Ingredient Tag item: " + value + '.',
                                Status = "Ignored"
                            });
                            dr.Info = "warning";
                        }
                        break;
                    case "volume rebate group":
                        fc.strVolumeRebateGroup = value;
                        break;
                    case "physical item":
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
                        SetBoolean(value, del => fc.ysnExtendPickTicket = del);
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
                        fc.strMaintenanceCalculationMethod = value;
                        break;
                    case "rate":
                        SetDecimal(value, del => fc.dblMaintenanceRate = del, "Rate", dr, header, row);
                        break;
                    case "nacs category":
                        fc.strNACSCategory = value;
                        break;
                    case "wic code":
                        fc.strWICCode = value;
                        break;
                    case "receipt comment req":
                        SetBoolean(value, del => fc.ysnReceiptCommentRequired = del);
                        break;
                    case "count code":
                        fc.strCountCode = value;
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
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICItem>().Any(t => t.strItemNo == fc.strItemNo))
            {
                var entry = context.ContextManager.Entry<tblICItem>(context.GetQuery<tblICItem>().First(t => t.strItemNo == fc.strItemNo));
                entry.Property(e => e.strDescription).CurrentValue = fc.strDescription;
                entry.Property(e => e.strType).CurrentValue = fc.strType;
                entry.Property(e => e.intLifeTime).CurrentValue = fc.intLifeTime;
                entry.Property(e => e.ysnDropShip).CurrentValue = fc.ysnDropShip;
                entry.Property(e => e.ysnTaxable).CurrentValue = fc.ysnTaxable;
                entry.Property(e => e.ysnLandedCost).CurrentValue = fc.ysnLandedCost;
                entry.Property(e => e.ysnSpecialCommission).CurrentValue = fc.ysnSpecialCommission;
                entry.Property(e => e.ysnCommisionable).CurrentValue = fc.ysnCommisionable;
                entry.Property(e => e.strShortName).CurrentValue = fc.strShortName;
                entry.Property(e => e.intManufacturerId).CurrentValue = fc.intManufacturerId;
                entry.Property(e => e.strStatus).CurrentValue = fc.strStatus;
                entry.Property(e => e.intCommodityId).CurrentValue = fc.intCommodityId;
                entry.Property(e => e.strLotTracking).CurrentValue = fc.strLotTracking;
                entry.Property(e => e.intBrandId).CurrentValue = fc.intBrandId;
                entry.Property(e => e.strModelNo).CurrentValue = fc.strModelNo;
                entry.Property(e => e.intCategoryId).CurrentValue = fc.intCategoryId;
                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.strItemNo).IsModified = false;
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
