using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemLocation : ImportDataLogic<tblICItemLocation>
    {
        protected override string[] GetRequiredFields()
        {
            return new string[] {
                "item no", "location"
            };
        }

        protected override int GetPrimaryKeyId(ref tblICItemLocation entity)
        {
            return entity.intItemLocationId;
        }

        protected override tblICItemLocation ProcessRow(int row, int fieldCount, string[] headers, LumenWorks.Framework.IO.Csv.CsvReader csv, ImportDataResult dr)
        {
            var fc = new tblICItemLocation();
            bool valid = true;
            int? intCompanyLocationId = null;
            int? intSubLocationId = null;
            int? intItemId = null;

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
                        intItemId = lu;
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
                                Message = "Can't find Item with Item No.: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "location":
                        lu = GetLookUpId<vyuSMGetCompanyLocationSearchList>(
                            context,
                            m => m.strLocationName == value,
                            e => (int)e.intCompanyLocationId);
                        intCompanyLocationId = lu;
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
                                Message = "Can't find Location: " + value + '.',
                                Status = REC_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "vendor id":
                        lu = GetLookUpId<vyuAPVendor>(
                            context,
                            m => m.strVendorId == value,
                            e => (int)e.intEntityId);
                        if (lu != null)
                            fc.intVendorId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_WARN,
                                Message = "Can't find Vendor: " + value + '.',
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
                        break;
                    case "pos description":
                        SetText(value, del => fc.strDescription = del);
	                    break;
                    case "costing method":
                        switch (value.ToUpper().Trim())
                        {
                            case "AVG": fc.intCostingMethod = 1; break;
                            case "FIFO": fc.intCostingMethod = 2; break;
                            case "LIFO": fc.intCostingMethod = 3; break;
                            default: 
                                break;
                        }
	                    break;
                    case "storage location":
                        if (!string.IsNullOrEmpty(value))
                        {
                            lu = GetLookUpId<tblSMCompanyLocationSubLocation>(
                                context,
                                m => m.strSubLocationName == value && m.intCompanyLocationId == intCompanyLocationId,
                                e => (int)e.intCompanyLocationSubLocationId);
                            intSubLocationId = lu;
                            if (lu != null)
                                fc.intSubLocationId = (int)lu;
                            else
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Storage Location: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
                        break;
                    case "storage unit":
                        if (!string.IsNullOrEmpty(value))
                        {
                            lu = GetLookUpId<vyuICGetStorageLocation>(
                                context,
                                m => m.strName == value && m.intLocationId == intCompanyLocationId && m.intSubLocationId == intSubLocationId,
                                e => (int)e.intStorageLocationId);
                            if (lu != null)
                                fc.intStorageLocationId = (int)lu;
                            else
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Storage Unit: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
	                    break;
                    case "sale uom":
                        int? uomId = null;
                        if (!string.IsNullOrEmpty(value))
                        {
                            lu = GetLookUpId<tblICUnitMeasure>(
                                context,
                                m => m.strUnitMeasure == value,
                                e => (int)e.intUnitMeasureId);
                            uomId = lu;
                            lu = GetLookUpId<tblICItemUOM>(
                                context,
                                m => m.intItemId == intItemId && m.intUnitMeasureId == uomId,
                                e => (int)e.intItemUOMId);
                            if (lu != null)
                                fc.intIssueUOMId = (int)lu;
                            else
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Sale UOM: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
	                    break;
                    case "purchase uom":
                        if (!string.IsNullOrEmpty(value))
                        {
                            uomId = null;
                            lu = GetLookUpId<tblICUnitMeasure>(
                                context,
                                m => m.strUnitMeasure == value,
                                e => (int)e.intUnitMeasureId);
                            uomId = lu;
                            lu = GetLookUpId<tblICItemUOM>(
                                context,
                                m => m.intItemId == intItemId && m.intUnitMeasureId == uomId && m.ysnAllowPurchase,
                                e => (int)e.intItemUOMId);
                            if (lu != null)
                                fc.intReceiveUOMId = (int)lu;
                            else
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Purchase UOM: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
	                    break;
                    case "family":
                        if (!string.IsNullOrEmpty(value))
                        {
                            lu = GetLookUpId<tblSTSubcategory>(
                                context,
                                m => m.strSubcategoryId == value && m.strSubcategoryType == "F",
                                e => (int)e.intSubcategoryId);
                            if (lu != null)
                                fc.intFamilyId = (int)lu;
                            else
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Family: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
	                    break;
                    case "class":
                        if (!string.IsNullOrEmpty(value))
                        {
                            lu = GetLookUpId<tblSTSubcategory>(
                                context,
                                m => m.strSubcategoryId == value && m.strSubcategoryType == "C",
                                e => (int)e.intSubcategoryId);
                            if (lu != null)
                                fc.intClassId = (int)lu;
                            else
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Class: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
	                    break;
                    case "product code":
                        if (!string.IsNullOrEmpty(value))
                        {
                            lu = GetLookUpId<tblSTSubcategoryRegProd>(
                                context,
                                //m => m.strRegProdCode == value && m.intStoreId != null && m.intStoreId != 0,
                                m => m.strRegProdCode == value && m.intStoreId != 0,
                                e => (int)e.intRegProdId);
                            if (lu != null)
                                fc.intProductCodeId = (int)lu;
                            else
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Product Code: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
	                    break;
                    case "passport fuel id 1":
                        SetText(value, del => fc.strPassportFuelId1 = del);
	                    break;
                    case "passport fuel id 2":
                        SetText(value, del => fc.strPassportFuelId2 = del);
	                    break;
                    case "passport fuel id 3":
                        SetText(value, del => fc.strPassportFuelId3 = del);
	                    break;
                    case "tax flag 1":
                        SetBoolean(value, del => fc.ysnTaxFlag1 = del);
	                    break;
                    case "tax flag 2":
                        SetBoolean(value, del => fc.ysnTaxFlag2 = del);
	                    break;
                    case "tax flag 3":
                        SetBoolean(value, del => fc.ysnTaxFlag3 = del);
	                    break;
                    case "tax flag 4":
                        SetBoolean(value, del => fc.ysnTaxFlag4 = del);
	                    break;
                    case "promotional item":
                        SetBoolean(value, del => fc.ysnPromotionalItem = del);
	                    break;
                    case "promotion item":
                        if (string.IsNullOrEmpty(value))
                            break;
                        int val;
                        try
                        {
                            val = int.Parse(value);
                        }
                        //catch (Exception ex)
                        catch (System.Reflection.AmbiguousMatchException)
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Invalid Promotion Item: {0}.", value),
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                            break;
                        }
                        lu = GetLookUpId<tblSTPromotionSalesList>(
                            context,
                            m => m.intPromoCode == val,
                            e => e.intPromoSalesListId);
                        if (lu != null)
                            fc.intMixMatchId = (int)lu;
                        else
                        {
                            dr.Messages.Add(new ImportDataMessage()
                            {
                                Column = header,
                                Row = row,
                                Type = TYPE_INNER_ERROR,
                                Message = string.Format("Can't find Promotion Item: {0}.", value),
                                Status = STAT_INNER_COL_SKIP
                            });
                            dr.Info = INFO_WARN;
                        }
	                    break;
                    case "deposit required":
                        SetBoolean(value, del => fc.ysnDepositRequired = del);
	                    break;
                    case "deposit plu":
                        if (string.IsNullOrEmpty(value))
                            break;
                        var param = new System.Data.SqlClient.SqlParameter("@strDepositPLU", value);
                        param.DbType = System.Data.DbType.String;
                        var query = @"SELECT u.intItemUOMId, u.intItemId, u.intUnitMeasureId, m.strUnitMeasure, u.strUpcCode
		                    FROM tblICItemUOM u
			                    INNER JOIN tblICUnitMeasure m ON m.intUnitMeasureId = u.intUnitMeasureId
		                    WHERE NULLIF(u.strUpcCode, '') IS NOT NULL AND m.strUnitMeasure = @strDepositPLU";

                        IEnumerable<DepositPLU> storageStores = context.ContextManager.Database.SqlQuery<DepositPLU>(query, param);
                            try
                            {
                                DepositPLU store = storageStores.First();

                                if (store != null)
                                    fc.intDepositPLUId = store.intItemUOMId;
                                else
                                {
                                    dr.Messages.Add(new ImportDataMessage()
                                    {
                                        Column = header,
                                        Row = row,
                                        Type = TYPE_INNER_WARN,
                                        Message = "Can't find Deposit PLU: " + value + '.',
                                        Status = STAT_INNER_COL_SKIP
                                    });
                                    dr.Info = INFO_WARN;
                                }
                            }
                            catch(Exception)
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Deposit PLU: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
	                    break;
                    case "bottle deposit no:":
                        SetInteger(value, del => fc.intBottleDepositNo = del, "Bottle Deposit No", dr, header, row);
	                    break;
                    case "saleable":
                        SetBoolean(value, del => fc.ysnSaleable = del);
	                    break;
                    case "quantity required":
                        SetBoolean(value, del => fc.ysnQuantityRequired = del);
	                    break;
                    case "scale item":
                        SetBoolean(value, del => fc.ysnScaleItem = del);
	                    break;
                    case "food stampable":
                        SetBoolean(value, del => fc.ysnFoodStampable = del);
	                    break;
                    case "returnable":
                        SetBoolean(value, del => fc.ysnReturnable = del);
	                    break;
                    case "pre priced":
                        SetBoolean(value, del => fc.ysnPrePriced = del);
	                    break;
                    case "open priced plu":
                        SetBoolean(value, del => fc.ysnOpenPricePLU = del);
	                    break;
                    case "linked item":
                        SetBoolean(value, del => fc.ysnLinkedItem = del);
	                    break;
                    case "vendor category":
                        SetText(value, del => fc.strVendorCategory = del);
	                    break;
                    case "id required (liquor)":
                        SetBoolean(value, del => fc.ysnIdRequiredLiquor = del);
	                    break;
                    case "id required (cigarrettes)":
                        SetBoolean(value, del => fc.ysnIdRequiredCigarette = del);
	                    break;
                    case "minimum age":
                        SetInteger(value, del => fc.intMinimumAge = del, "Minimum Age", dr, header, row);
	                    break;
                    case "apply blue law 1":
                        SetBoolean(value, del => fc.ysnApplyBlueLaw1 = del);
	                    break;
                    case "apply blue law 2":
                        SetBoolean(value, del => fc.ysnApplyBlueLaw2 = del);
	                    break;
                    case "car wash":
                        SetBoolean(value, del => fc.ysnCarWash = del);
	                    break;
                    case "item type subcode":
                        SetInteger(value, del => fc.intItemTypeSubCode = del, "Item Type Subcode", dr, header, row);
	                    break;
                    case "item type code":
                        query = "";
                        if (!string.IsNullOrEmpty(value))
                        {
                            try
                            {
                                val = int.Parse(value);
                            }
                            //catch (Exception ex)
                            catch (System.Reflection.AmbiguousMatchException)
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Invalid Item Type Code: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                                break;
                            }
                            param = new System.Data.SqlClient.SqlParameter("@intRadiantItemTypeCode", val);
                            param.DbType = System.Data.DbType.Int32;
                            query = @"SELECT intRadiantItemTypeCodeId, 
                                        intRadiantItemTypeCode, strDescription FROM tblSTRadiantItemTypeCode
                                      WHERE intRadiantItemTypeCode = @intRadiantItemTypeCode";
                            IEnumerable<RadiantItemTypeCode> itemTypes = context.ContextManager.Database.SqlQuery<RadiantItemTypeCode>(query, param);
                            try
                            {
                                RadiantItemTypeCode itemType = itemTypes.First();

                                if (itemType != null)
                                    fc.intItemTypeCode = itemType.intRadiantItemTypeCodeId;
                                else
                                {
                                    dr.Messages.Add(new ImportDataMessage()
                                    {
                                        Column = header,
                                        Row = row,
                                        Type = TYPE_INNER_WARN,
                                        Message = "Can't find Item Type Code: " + value + '.',
                                        Status = STAT_INNER_COL_SKIP
                                    });
                                    dr.Info = INFO_WARN;
                                }
                            }
                            catch(Exception)
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Item Type Code: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }

                        }
                        break;
                    case "allow negative inventory":
                        switch (value.ToUpper().Trim())
                        {
                            case "YES": fc.intAllowNegativeInventory = 1; break;
                            default:
                                fc.intAllowNegativeInventory = 3;
                                break;
                        }
	                    break;
                    case "reorder point":
                        SetDecimal(value, del => fc.dblReorderPoint = del, "Reorder Point", dr, header, row);
	                    break;
                    case "min order":
                        SetDecimal(value, del => fc.dblMinOrder = del, "Min Order", dr, header, row);
	                    break;
                    case "suggested qty":
                        SetDecimal(value, del => fc.dblSuggestedQty = del, "Suggested Qty", dr, header, row);
	                    break;
                    case "lead time (days)":
                        SetDecimal(value, del => fc.dblLeadTime = del, "Lead Time (days)", dr, header, row);
	                    break;
                    case "inventory count group":
                        if (!string.IsNullOrEmpty(value))
                        {
                            lu = GetLookUpId<tblICCountGroup>(
                                context,
                                m => m.strCountGroup == value,
                                e => (int)e.intCountGroupId);
                            if (lu != null)
                                fc.intCountGroupId = (int)lu;
                            else
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Count Group: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
	                    break;
                    case "counted":
                        SetText(value, del => fc.strCounted = del);
	                    break;
                    case "counted daily":
                        SetBoolean(value, del => fc.ysnCountedDaily = del);
	                    break;
                    case "count by serial number":
                        SetBoolean(value, del => fc.ysnCountBySINo = del);
	                    break;
                    case "serial number begin":
                        SetText(value, del => fc.strSerialNoBegin = del);
	                    break;
                    case "serial number end":
                        SetText(value, del => fc.strSerialNoEnd = del);
	                    break;
                    case "auto calculate freight":
                        SetBoolean(value, del => fc.ysnAutoCalculateFreight = del);
	                    break;
                    case "freight rate":
                        SetDecimal(value, del => fc.dblFreightRate = del, "Freight Rate", dr, header, row);
	                    break;
                    case "freight term":
                        query = "";
                        if (!string.IsNullOrEmpty(value))
                        {
                            param = new System.Data.SqlClient.SqlParameter("@strFreightTerm", value);
                            param.DbType = System.Data.DbType.String;
                            query = "SELECT intFreightTermId, strFreightTerm, strFobPoint FROM tblSMFreightTerms WHERE strFreightTerm = @strFreightTerm";
                            IEnumerable<tblSMFreightTerms> terms = context.ContextManager.Database.SqlQuery<tblSMFreightTerms>(query, param);
                            try
                            {
                                tblSMFreightTerms term = terms.First();

                                if (term != null)
                                    fc.intFreightMethodId = term.intFreightTermId;
                                else
                                {
                                    dr.Messages.Add(new ImportDataMessage()
                                    {
                                        Column = header,
                                        Row = row,
                                        Type = TYPE_INNER_WARN,
                                        Message = "Can't find Freight Term: " + value + '.',
                                        Status = STAT_INNER_COL_SKIP
                                    });
                                    dr.Info = INFO_WARN;
                                }
                            }
                            catch(Exception)
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Freight Term: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }

                        }
	                    break;
                    case "ship via":
                        if (!string.IsNullOrEmpty(value))
                        {
                            param = new System.Data.SqlClient.SqlParameter("@strShipVia", value);
                            param.DbType = System.Data.DbType.String;
                            query = "SELECT intEntityShipViaId, strShipVia, strShippingService, strName FROM vyuEMSearchShipVia WHERE strShipVia = @strShipVia";
                            IEnumerable<vyuEMSearchShipVia> ships = context.ContextManager.Database.SqlQuery<vyuEMSearchShipVia>(query, param );
                            try
                            {
                                vyuEMSearchShipVia ship = ships.First();

                                if (ship != null)
                                    fc.intShipViaId = ship.intEntityShipViaId;
                                else
                                {
                                    dr.Messages.Add(new ImportDataMessage()
                                    {
                                        Column = header,
                                        Row = row,
                                        Type = TYPE_INNER_WARN,
                                        Message = "Can't find Ship Method: " + value + '.',
                                        Status = STAT_INNER_COL_SKIP
                                    });
                                    dr.Info = INFO_WARN;
                                } 
                            }
                            catch(Exception)
                            {
                                dr.Messages.Add(new ImportDataMessage()
                                {
                                    Column = header,
                                    Row = row,
                                    Type = TYPE_INNER_WARN,
                                    Message = "Can't find Ship Method: " + value + '.',
                                    Status = STAT_INNER_COL_SKIP
                                });
                                dr.Info = INFO_WARN;
                            }
                        }
	                    break;
                }
            }

            if (!valid)
                return null;

            if (context.GetQuery<tblICItemLocation>().Any(t => t.intLocationId == fc.intLocationId && t.intItemId == fc.intItemId))
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
                        Message = "The item location already exists. The system does not allow existing records to be modified."
                    });
                    return null;
                }

                var entry = context.ContextManager.Entry<tblICItemLocation>(context.GetQuery<tblICItemLocation>().First(t => t.intLocationId == fc.intLocationId && t.intItemId == fc.intItemId));
                entry.Property(e => e.intVendorId).CurrentValue = fc.intVendorId;
                entry.Property(e => e.strDescription).CurrentValue = fc.strDescription;
                entry.Property(e => e.intCostingMethod).CurrentValue = fc.intCostingMethod;
                entry.Property(e => e.intSubLocationId).CurrentValue = fc.intSubLocationId;
                entry.Property(e => e.intStorageLocationId).CurrentValue = fc.intStorageLocationId;
                entry.Property(e => e.intIssueUOMId).CurrentValue = fc.intIssueUOMId;
                entry.Property(e => e.intReceiveUOMId).CurrentValue = fc.intReceiveUOMId;
                entry.Property(e => e.intFamilyId).CurrentValue = fc.intFamilyId;
                entry.Property(e => e.intClassId).CurrentValue = fc.intClassId;
                entry.Property(e => e.intProductCodeId).CurrentValue = fc.intProductCodeId;
                entry.Property(e => e.strPassportFuelId1).CurrentValue = fc.strPassportFuelId1;
                entry.Property(e => e.strPassportFuelId2).CurrentValue = fc.strPassportFuelId2;
                entry.Property(e => e.strPassportFuelId3).CurrentValue = fc.strPassportFuelId3;
                entry.Property(e => e.ysnTaxFlag1).CurrentValue = fc.ysnTaxFlag1;
                entry.Property(e => e.ysnTaxFlag2).CurrentValue = fc.ysnTaxFlag2;
                entry.Property(e => e.ysnTaxFlag3).CurrentValue = fc.ysnTaxFlag3;
                entry.Property(e => e.ysnTaxFlag4).CurrentValue = fc.ysnTaxFlag4;
                entry.Property(e => e.ysnPromotionalItem).CurrentValue = fc.ysnPromotionalItem;
                entry.Property(e => e.intMixMatchId).CurrentValue = fc.intMixMatchId;
                entry.Property(e => e.ysnDepositRequired).CurrentValue = fc.ysnDepositRequired;
                entry.Property(e => e.intDepositPLUId).CurrentValue = fc.intDepositPLUId;
                entry.Property(e => e.intBottleDepositNo).CurrentValue = fc.intBottleDepositNo;
                entry.Property(e => e.ysnSaleable).CurrentValue = fc.ysnSaleable;
                entry.Property(e => e.ysnQuantityRequired).CurrentValue = fc.ysnQuantityRequired;
                entry.Property(e => e.ysnScaleItem).CurrentValue = fc.ysnScaleItem;
                entry.Property(e => e.ysnFoodStampable).CurrentValue = fc.ysnFoodStampable;
                entry.Property(e => e.ysnReturnable).CurrentValue = fc.ysnReturnable;
                entry.Property(e => e.ysnPrePriced).CurrentValue = fc.ysnPrePriced;
                entry.Property(e => e.ysnOpenPricePLU).CurrentValue = fc.ysnOpenPricePLU;
                entry.Property(e => e.ysnLinkedItem).CurrentValue = fc.ysnLinkedItem;
                entry.Property(e => e.strVendorCategory).CurrentValue = fc.strVendorCategory;
                entry.Property(e => e.ysnIdRequiredLiquor).CurrentValue = fc.ysnIdRequiredLiquor;
                entry.Property(e => e.ysnIdRequiredCigarette).CurrentValue = fc.ysnIdRequiredCigarette;
                entry.Property(e => e.intMinimumAge).CurrentValue = fc.intMinimumAge;
                entry.Property(e => e.ysnApplyBlueLaw1).CurrentValue = fc.ysnApplyBlueLaw1;
                entry.Property(e => e.ysnApplyBlueLaw2).CurrentValue = fc.ysnApplyBlueLaw2;
                entry.Property(e => e.ysnTaxFlag4).CurrentValue = fc.ysnTaxFlag4;
                entry.Property(e => e.ysnCarWash).CurrentValue = fc.ysnCarWash;
                entry.Property(e => e.intItemTypeSubCode).CurrentValue = fc.intItemTypeSubCode;
                entry.Property(e => e.intItemTypeCode).CurrentValue = fc.intItemTypeCode;
                entry.Property(e => e.intAllowNegativeInventory).CurrentValue = fc.intAllowNegativeInventory;
                entry.Property(e => e.dblReorderPoint).CurrentValue = fc.dblReorderPoint;
                entry.Property(e => e.dblMinOrder).CurrentValue = fc.dblMinOrder;
                entry.Property(e => e.dblSuggestedQty).CurrentValue = fc.dblSuggestedQty;
                entry.Property(e => e.dblLeadTime).CurrentValue = fc.dblLeadTime;
                entry.Property(e => e.intCountGroupId).CurrentValue = fc.intCountGroupId;
                entry.Property(e => e.strCounted).CurrentValue = fc.strCounted;
                entry.Property(e => e.ysnCountedDaily).CurrentValue = fc.ysnCountedDaily;
                entry.Property(e => e.ysnCountBySINo).CurrentValue = fc.ysnCountBySINo;
                entry.Property(e => e.strSerialNoBegin).CurrentValue = fc.strSerialNoBegin;
                entry.Property(e => e.strSerialNoEnd).CurrentValue = fc.strSerialNoEnd;
                entry.Property(e => e.ysnAutoCalculateFreight).CurrentValue = fc.ysnAutoCalculateFreight;
                entry.Property(e => e.dblFreightRate).CurrentValue = fc.dblFreightRate;
                entry.Property(e => e.intFreightMethodId).CurrentValue = fc.intFreightMethodId;
                entry.Property(e => e.intShipViaId).CurrentValue = fc.intShipViaId;
                
                entry.Property(e => e.intItemId).IsModified = false;
                entry.Property(e => e.intItemLocationId).IsModified = false;
            }
            else
            {
                context.AddNew<tblICItemLocation>(fc);
                CreateDefaultPricing(fc);
            }

            return fc;
        }

        private void CreateDefaultPricing(tblICItemLocation il)
        {
            tblICItemPricing fc = new tblICItemPricing()
            {
                strPricingMethod = "None",
                dblLastCost = 0,
                dblStandardCost = 0,
                dblAverageCost = 0,
                dblEndMonthCost = 0,
                dblMSRPPrice = 0,
                dblSalePrice = 0
            };

            fc.intItemId = il.intItemId;
            fc.intItemLocationId = il.intItemLocationId;
            context.AddNew<tblICItemPricing>(fc);
        }

        private class RadiantItemTypeCode
        {
            public int intRadiantItemTypeCodeId { get; set; }
            public int intRadiantItemTypeCode { get; set; }
            public string strDescription { get; set; }
        }

        private class DepositPLU
        {
            public int intItemUOMId { get; set; }
            public int intItemId { get; set; }
            public int intUnitMeasureId { get; set; }
            public string strUnitMeasure { get; set; }
            public string strUpcCode { get; set; }
        }

        public class tblSMFreightTerms
        {
            public int intFreightTermId { get; set; }
            public string strFreightTerm { get; set; }
            public string strFobPoint { get; set; }
            public bool ysnActive { get; set; }
        }

        public class vyuEMSearchShipVia
        {
            public int intEntityShipViaId { get; set; }
            public string strShipVia { get; set; }
            public string strShippingService { get; set; }
            public string strName { get; set; }
        }
    }
}
