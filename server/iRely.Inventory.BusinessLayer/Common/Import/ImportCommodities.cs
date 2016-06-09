using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportCommodities : ImportDataLogic<tblICCommodity>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] { "commodity code" };
        }

        protected override tblICCommodity ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            tblICCommodity fc = new tblICCommodity();
            bool valid = true;

            for (var i = 0; i < fieldCount; i++)
            {
                //if (!valid)
                //    break;
                string header = headers[i];
                string value = csv[header];
                
                string h = header.ToLower().Trim();

                switch (h)
                {
                    case "commodity code":
                        if (!SetText(value, del => fc.strCommodityCode = del, "Commodity Code", dr, header, row, true))
                            valid = false;
                        break;
                    case "description":
                        fc.strDescription = value;
                        break;
                    case "exchange traded":
                        SetBoolean(value, del => fc.ysnExchangeTraded = del);
                        break;
                    case "consolidate factor":
                        SetDecimal(value, del => fc.dblConsolidateFactor = del, "Consolidate Factor", dr, header, row);
                        break;
                    case "fx exposure":
                        SetBoolean(value, del => fc.ysnFXExposure = del);
                        break;
                    case "price checks min":
                        SetDecimal(value, del => fc.dblPriceCheckMin = del, "Price Checks Min", dr, header, row);
                        break;
                    case "price checks max":
                        SetDecimal(value, del => fc.dblPriceCheckMax = del, "Price Checks Max", dr, header, row);
                        break;
                    case "checkoff tax desc":
                        fc.strCheckoffTaxDesc = value;
                        break;
                    case "checkoff all states":
                        fc.strCheckoffAllState = value;
                        break;
                    case "insurance tax desc":
                        fc.strInsuranceTaxDesc = value;
                        break;
                    case "insurance all states":
                        fc.strInsuranceAllState = value;
                        break;
                    case "crop end date current":
                        SetDate(value, del => fc.dtmCropEndDateCurrent = del, "Crop End Date Current", dr, header, row);
                        break;
                    case "crop end date new":
                        SetDate(value, del => fc.dtmCropEndDateNew = del, "Crop End Date New", dr, header, row);
                        break;
                    case "edi code":
                        fc.strEDICode = value;
                        break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICCommodity>().Any(t => t.strCommodityCode == fc.strCommodityCode))
            {
                var entry = context.ContextManager.Entry<tblICCommodity>(context.GetQuery<tblICCommodity>().First(t => t.strCommodityCode == fc.strCommodityCode));
                entry.Property(e => e.strDescription).CurrentValue = fc.strDescription;
                entry.Property(e => e.ysnFXExposure).CurrentValue = fc.ysnFXExposure;
                entry.Property(e => e.ysnExchangeTraded).CurrentValue = fc.ysnExchangeTraded;
                entry.Property(e => e.dblConsolidateFactor).CurrentValue = fc.dblConsolidateFactor;
                entry.Property(e => e.dblPriceCheckMin).CurrentValue = fc.dblPriceCheckMin;
                entry.Property(e => e.dblPriceCheckMax).CurrentValue = fc.dblPriceCheckMax;
                entry.Property(e => e.strCheckoffTaxDesc).CurrentValue = fc.strCheckoffTaxDesc;
                entry.Property(e => e.strCheckoffAllState).CurrentValue = fc.strCheckoffAllState;
                entry.Property(e => e.strInsuranceTaxDesc).CurrentValue = fc.strInsuranceTaxDesc;
                entry.Property(e => e.strInsuranceAllState).CurrentValue = fc.strInsuranceAllState;
                entry.Property(e => e.dtmCropEndDateCurrent).CurrentValue = fc.dtmCropEndDateCurrent;
                entry.Property(e => e.dtmCropEndDateNew).CurrentValue = fc.dtmCropEndDateNew;
                entry.Property(e => e.strEDICode).CurrentValue = fc.strEDICode;
                entry.State = System.Data.Entity.EntityState.Modified;
                entry.Property(e => e.strCommodityCode).IsModified = false;
            }
            else
            {
                context.AddNew<tblICCommodity>(fc);
            }
            return fc;
        }

        protected override int GetPrimaryKeyId(ref tblICCommodity entity)
        {
            return entity.intCommodityId;
        }
    }
}
