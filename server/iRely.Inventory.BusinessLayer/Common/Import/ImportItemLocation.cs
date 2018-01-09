using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportItemLocation : ImportDataLogic<tblICItemLocation>
    {
        public ImportItemLocation(DbContext context, byte[] data, string username) : base(context, data, username)
        {
        }

        protected override string[] GetRequiredFields()
        {
            return new string[] {
                "item no", "location"
            };
        }

        protected override string GetPrimaryKeyName()
        {
            return "intItemLocationId";
        }

        public override int GetPrimaryKeyValue(tblICItemLocation entity)
        {
            return entity.intItemLocationId;
        }

        protected override Expression<Func<tblICItemLocation, bool>> GetUniqueKeyExpression(tblICItemLocation entity)
        {
            return e => e.intItemId == entity.intItemId && e.intLocationId == entity.intLocationId;
        }

        public override tblICItemLocation Process(CsvRecord record)
        {
            var entity = new tblICItemLocation();
            var valid = true;

            var lu = GetFieldValue(record, "Item No");
            valid = SetIntLookupId<tblICItem>(record, "Item No", e => e.strItemNo == lu, e => e.intItemId, e => entity.intItemId = e, required: true);
            lu = GetFieldValue(record, "Location");
            valid = SetIntLookupId<vyuSMGetCompanyLocationSearchList>(record, "Location", e => e.strLocationName == lu, e => e.intCompanyLocationId, e => entity.intLocationId = e, required: true);
            SetText(record, "Description", e => entity.strDescription = e, required: false);
            lu = GetFieldValue(record, "Vendor Id");
            SetLookupId<vyuAPVendor>(record, "Vendor Id", e => e.strName == lu, e => e.intEntityId, e => entity.intVendorId = e, required: false);
            SetText(record, "POS Description", e => entity.strDescription = e);
            lu = GetFieldValue(record, "Storage Location");
            SetLookupId<tblSMCompanyLocationSubLocation>(record, "Storage Location", e => e.strSubLocationName == lu && e.intCompanyLocationId == entity.intCompanyLocationId, e => e.intCompanyLocationSubLocationId, e => entity.intSubLocationId = e, required: false);
            lu = GetFieldValue(record, "Storage Unit");
            SetLookupId<vyuICGetStorageLocation>(record, "Storage Unit", e => e.strName == lu && e.intLocationId == entity.intCompanyLocationId && e.intSubLocationId == entity.intSubLocationId, e => e.intStorageLocationId, e => entity.intStorageLocationId = e, required: false);
            lu = GetFieldValue(record, "Family");
            SetLookupId<tblSTSubcategory>(record, "Family", e => e.strSubcategoryId == lu && e.strSubcategoryType == "F", e => e.intSubcategoryId, e => entity.intFamilyId = e);
            lu = GetFieldValue(record, "Class");
            SetLookupId<tblSTSubcategory>(record, "Class", e => e.strSubcategoryId == lu && e.strSubcategoryType == "C", e => e.intSubcategoryId, e => entity.intClassId = e);
            lu = GetFieldValue(record, "Product Code");
            SetLookupId<tblSTSubcategoryRegProd>(record, "Product Code", e => e.strRegProdCode == lu && e.intStoreId != 0, e => e.intRegProdId, e => entity.intProductCodeId = e);
            SetText(record, "Passport Fuel Id 1", e => entity.strPassportFuelId1 = e);
            SetText(record, "Passport Fuel Id 2", e => entity.strPassportFuelId2 = e);
            SetText(record, "Passport Fuel Id 3", e => entity.strPassportFuelId3 = e);
            SetBoolean(record, "Tax Flag 1", e => entity.ysnTaxFlag1 = e);
            SetBoolean(record, "Tax Flag 2", e => entity.ysnTaxFlag2 = e);
            SetBoolean(record, "Tax Flag 3", e => entity.ysnTaxFlag3 = e);
            SetBoolean(record, "Tax Flag 4", e => entity.ysnTaxFlag4 = e);
            SetBoolean(record, "Promotional Item", e => entity.ysnPromotionalItem = e);
            var pi = GetFieldValue(record, "Promotion Item");
            if (!string.IsNullOrEmpty(pi.Trim()))
            {
                try
                {
                    var pc = int.Parse(pi);
                    SetLookupId<tblSTPromotionSalesList>(record, "Promotion Item", e => e.intPromoCode == pc, e => e.intPromoCode, e => entity.strPromoItemListId = e.ToString());
                }
                catch(Exception)
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Promotion Item",
                        Row = record.RecordNo,
                        Type = Constants.TYPE_WARNING,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_DISCARDED,
                        Exception = null,
                        Value = pi,
                        Message = $"Invalid value for Promotion Item: {pi}."
                    };
                    ImportResult.AddWarning(msg);
                }
            }
            SetBoolean(record, "Deposit Required", e => entity.ysnDepositRequired = e);
            SetInteger(record, "Bottle Deposit No", e => entity.intBottleDepositNo = e);
            SetBoolean(record, "Saleable", e => entity.ysnSaleable = e);
            SetBoolean(record, "Quantity Required", e => entity.ysnQuantityRequired = e);
            SetBoolean(record, "Scale Item", e => entity.ysnScaleItem = e);
            SetBoolean(record, "Food Stampable", e => entity.ysnFoodStampable = e);
            SetBoolean(record, "Returnable", e => entity.ysnReturnable = e);
            SetBoolean(record, "Pre Priced", e => entity.ysnPrePriced = e);
            SetBoolean(record, "Open Priced PLU", e => entity.ysnOpenPricePLU = e);
            SetBoolean(record, "Linked Item", e => entity.ysnLinkedItem = e);
            SetText(record, "Vendor Category", e => entity.strVendorCategory = e);
            SetBoolean(record, "Id Required (Liquor)", e => entity.ysnIdRequiredLiquor = e);
            SetBoolean(record, "Id Required (Cigarrettes)", e => entity.ysnIdRequiredCigarette = e);
            SetInteger(record, "Minimum Age", e => entity.intMinimumAge = e);
            SetBoolean(record, "Apply Blue Law 1", e => entity.ysnApplyBlueLaw1 = e);
            SetBoolean(record, "Apply Blue Law 2", e => entity.ysnApplyBlueLaw2 = e);
            SetBoolean(record, "Car Wash", e => entity.ysnCarWash = e);
            SetInteger(record, "Item Type SubCode", e => entity.intItemTypeSubCode = e);
            SetDecimal(record, "Reorder Point", e => entity.dblReorderPoint = e);
            SetDecimal(record, "Min Order", e => entity.dblMinOrder = e);
            SetDecimal(record, "Suggested Qty", e => entity.dblSuggestedQty = e);
            SetDecimal(record, "Lead Time (Days)", e => entity.dblLeadTime = e);
            SetText(record, "Counted", e => entity.strCounted = e);
            SetBoolean(record, "Counted Daily", e => entity.ysnCountedDaily = e);
            SetBoolean(record, "Counte By Serial Number", e => entity.ysnCountBySINo = e);
            SetText(record, "Serial Number Begin", e => entity.strSerialNoBegin = e);
            SetText(record, "Serial Number End", e => entity.strSerialNoEnd = e);
            SetBoolean(record, "Auto Calculate Freight", e => entity.ysnAutoCalculateFreight = e);
            SetDecimal(record, "Freight Rate", e => entity.dblFreightRate = e);
            lu = GetFieldValue(record, "Inventory Count Group");
            SetLookupId<tblICCountGroup>(record, "Inventory Count Group", e => e.strCountGroup == lu, e => e.intCountGroupId, e => entity.intCountGroupId = e);

            if (valid)
                return entity;

            return null;
        }

        public override void Initialize()
        {
            base.Initialize();
            AddPipe(new ConditionalPipe(context, ImportResult));
            AddPipe(new SaleUOMPipe(context, ImportResult));
            AddPipe(new PurchaseUOMPipe(context, ImportResult));
            AddPipe(new DepositPluPipe(context, ImportResult));
            AddPipe(new ItemTypeCodePIpe(context, ImportResult));
            AddPipe(new FreightTermPipe(context, ImportResult));
            AddPipe(new ShipViaPipe(context, ImportResult));
            AddPipe(new DefaultPricingPipe(context, ImportResult));
        }

        class ConditionalPipe : CsvPipe<tblICItemLocation>
        {
            public ConditionalPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemLocation Process(tblICItemLocation input)
            {
                var costingMethod = GetFieldValue("Costing Method");
                switch (costingMethod.ToUpper().Trim())
                {
                    case "AVG": input.intCostingMethod = 1; break;
                    case "FIFO": input.intCostingMethod = 2; break;
                    case "LIFO": input.intCostingMethod = 3; break;
                }

                var ani = GetFieldValue("Allow Negative Inventory");
                switch (ani.ToUpper().Trim())
                {
                    case "YES": input.intAllowNegativeInventory = 1; break;
                    default: input.intAllowNegativeInventory = 3; break;
                }

                return input;
            }
        }

        class SaleUOMPipe : CsvPipe<tblICItemLocation>
        {
            public SaleUOMPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemLocation Process(tblICItemLocation input)
            {
                var value = GetFieldValue("Sale UOM");
                var lu = ImportDataLogicHelpers.GetLookUpId<tblICUnitMeasure>(Context, e => e.strUnitMeasure == value, e => e.intUnitMeasureId);
                lu = ImportDataLogicHelpers.GetLookUpId<tblICItemUOM>(Context, e => e.intItemId == input.intItemId && e.intUnitMeasureId == lu, e => e.intItemUOMId);
                if(lu != null)
                    input.intIssueUOMId = lu;
                else
                {
                    AddWarning("Sale UOM", $"Can't find Sale UOM: {value}.");
                }
                return input;
            }
        }

        class PurchaseUOMPipe : CsvPipe<tblICItemLocation>
        {
            public PurchaseUOMPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemLocation Process(tblICItemLocation input)
            {
                var value = GetFieldValue("Purchase UOM");
                var lu = ImportDataLogicHelpers.GetLookUpId<tblICUnitMeasure>(Context, e => e.strUnitMeasure == value, e => e.intUnitMeasureId);
                lu = ImportDataLogicHelpers.GetLookUpId<tblICItemUOM>(Context, e => e.intItemId == input.intItemId && e.intUnitMeasureId == lu, e => e.intItemUOMId);
                if (lu != null)
                    input.intReceiveUOMId = lu;
                else
                {
                    AddWarning("Purchase UOM", $"Can't find Purchase UOM: {value}.");
                }
                return input;
            }
        }

        class DepositPluPipe : CsvPipe<tblICItemLocation>
        {
            public DepositPluPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemLocation Process(tblICItemLocation input)
            {
                var value = GetFieldValue("Deposit PLU");
                if (!string.IsNullOrEmpty(value))
                {
                    var param = new System.Data.SqlClient.SqlParameter("@strDepositPLU", value);
                    param.DbType = System.Data.DbType.String;
                    var query = @"SELECT u.intItemUOMId, u.intItemId, u.intUnitMeasureId, m.strUnitMeasure, u.strUpcCode
		                    FROM tblICItemUOM u
			                    INNER JOIN tblICUnitMeasure m ON m.intUnitMeasureId = u.intUnitMeasureId
		                    WHERE NULLIF(u.strUpcCode, '') IS NOT NULL AND m.strUnitMeasure = @strDepositPLU";

                    IEnumerable<DepositPLU> storageStores = Context.Database.SqlQuery<DepositPLU>(query, param);
                    try
                    {
                        DepositPLU store = storageStores.First();

                        if (store != null)
                            input.intDepositPLUId = store.intItemUOMId;
                        else
                        {
                            AddWarning("Deposit PLU", $"Can't find Deposit PLU: {value}.");
                        }
                    }
                    catch (Exception)
                    {
                        AddWarning("Deposit PLU", $"Can't find Deposit PLU: {value}.");
                    }
                }
                return input;
            }
        }

        class ItemTypeCodePIpe : CsvPipe<tblICItemLocation>
        {
            public ItemTypeCodePIpe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemLocation Process(tblICItemLocation input)
            {
                var value = GetFieldValue("Item Type Code");
                if (!string.IsNullOrEmpty(value))
                {
                    var val = 0;
                    try
                    {
                        val = int.Parse(value);
                    }
                    //catch (Exception ex)
                    catch (System.Reflection.AmbiguousMatchException)
                    {
                        AddWarning("Item Type Code", $"Can't find Item Type Code: {value}.");
                    }
                    var param = new System.Data.SqlClient.SqlParameter("@intRadiantItemTypeCode", val);
                    param.DbType = System.Data.DbType.Int32;
                    var query = @"SELECT intRadiantItemTypeCodeId, 
                                        intRadiantItemTypeCode, strDescription FROM tblSTRadiantItemTypeCode
                                      WHERE intRadiantItemTypeCode = @intRadiantItemTypeCode";
                    IEnumerable<RadiantItemTypeCode> itemTypes = Context.Database.SqlQuery<RadiantItemTypeCode>(query, param);
                    try
                    {
                        RadiantItemTypeCode itemType = itemTypes.First();

                        if (itemType != null)
                            input.intItemTypeCode = itemType.intRadiantItemTypeCodeId;
                        else
                        {
                            AddWarning("Item Type Code", $"Can't find Item Type Code: {value}.");
                        }
                    }
                    catch (Exception)
                    {
                        AddWarning("Item Type Code", $"Can't find Item Type Code: {value}.");
                    }
                }
                return input;
            }
        }

        class FreightTermPipe : CsvPipe<tblICItemLocation>
        {
            public FreightTermPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemLocation Process(tblICItemLocation input)
            {
                var value = GetFieldValue("Freight Term");

                if (!string.IsNullOrEmpty(value))
                {
                    var param = new System.Data.SqlClient.SqlParameter("@strFreightTerm", value);
                    param.DbType = System.Data.DbType.String;
                    var query = "SELECT intFreightTermId, strFreightTerm, strFobPoint FROM tblSMFreightTerms WHERE strFreightTerm = @strFreightTerm";
                    IEnumerable<tblSMFreightTerms> terms = Context.Database.SqlQuery<tblSMFreightTerms>(query, param);
                    try
                    {
                        tblSMFreightTerms term = terms.First();

                        if (term != null)
                            input.intFreightMethodId = term.intFreightTermId;
                        else
                        {
                            AddWarning("Freight Term", $"Can't find Freight Term: {value}.");
                        }
                    }
                    catch (Exception)
                    {
                        AddWarning("Freight Term", $"Can't find Freight Term: {value}.");
                    }
                }
                return input;
            }
        }

        class ShipViaPipe : CsvPipe<tblICItemLocation>
        {
            public ShipViaPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemLocation Process(tblICItemLocation input)
            {
                var value = GetFieldValue("Ship Via");

                if (!string.IsNullOrEmpty(value))
                {
                    var param = new System.Data.SqlClient.SqlParameter("@strShipVia", value);
                    param.DbType = System.Data.DbType.String;
                    var query = "SELECT intEntityShipViaId, strShipVia, strShippingService, strName FROM vyuEMSearchShipVia WHERE strShipVia = @strShipVia";
                    IEnumerable<vyuEMSearchShipVia> ships = Context.Database.SqlQuery<vyuEMSearchShipVia>(query, param);
                    try
                    {
                        vyuEMSearchShipVia ship = ships.First();

                        if (ship != null)
                            input.intShipViaId = ship.intEntityShipViaId;
                        else
                        {
                            AddWarning("Ship Via", $"Can't find Ship Via: {value}.");
                        }
                    }
                    catch (Exception)
                    {
                        AddWarning("Ship Via", $"Can't find Ship Via: {value}.");
                    }
                }
                return input;
            }
        }

        class DefaultPricingPipe : CsvPipe<tblICItemLocation>
        {
            public DefaultPricingPipe(DbContext context, ImportDataResult result) : base(context, result)
            {
            }

            protected override tblICItemLocation Process(tblICItemLocation input)
            {
                tblICItemPricing entity = new tblICItemPricing()
                {
                    strPricingMethod = "None",
                    dblLastCost = 0,
                    dblStandardCost = 0,
                    dblAverageCost = 0,
                    dblEndMonthCost = 0,
                    dblMSRPPrice = 0,
                    dblSalePrice = 0,
                    intItemId = input.intItemId
                };

                var location = Record["Location"].ToLower();
                if (!Context.Set<vyuICGetItemPricing>().Any(e => e.intItemId == input.intItemId && e.strLocationName.ToLower() == location))
                {
                    input.tblICItemPricings.Add(entity);
                }
                else
                {
                    var msg = new ImportDataMessage()
                    {
                        Column = "Item Pricing",
                        Row = Record.RecordNo,
                        Type = Constants.TYPE_WARNING,
                        Status = Constants.STAT_FAILED,
                        Action = Constants.ACTION_SKIPPED,
                        Exception = null,
                        Value = "Auto generated pricing.",
                        Message = $"Item pricing for location '{Record["Location"]}' already exists.",
                    };
                    Result.AddWarning(msg);
                }
                return input;
            }
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
