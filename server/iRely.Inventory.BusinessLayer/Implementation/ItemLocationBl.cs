using iRely.Common;

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemLocationBl : BusinessLayer<tblICItemLocation>, IItemLocationBl 
    {
        #region Constructor
        public ItemLocationBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemLocation>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> SearchItemLocationViews(GetParameter param)
        {
            var query = (
                from ItemLocation in _db.GetQuery<vyuICGetItemLocation>()
                join RegProd in _db.GetQuery<tblSTSubcategoryRegProd>()
                on ItemLocation.intProductCodeId equals RegProd.intStoreId
                into tempTableLeftJoin
                from leftJoin in tempTableLeftJoin.DefaultIfEmpty()
                select new GetItemLocationVM
                    {
                        intItemLocationId = ItemLocation.intItemLocationId,
                        intItemId = ItemLocation.intItemId,
                        strItemNo = ItemLocation.strItemNo,
                        strItemDescription = ItemLocation.strItemDescription,
                        intLocationId = ItemLocation.intLocationId,
                        strLocationName = ItemLocation.strLocationName,
                        strLocationType = ItemLocation.strLocationType,
                        intVendorId = ItemLocation.intVendorId,
                        strVendorId = ItemLocation.strVendorId,
                        strVendorName = ItemLocation.strVendorName,
                        strDescription = ItemLocation.strDescription,
                        intCostingMethod = ItemLocation.intCostingMethod,
                        strCostingMethod = ItemLocation.strCostingMethod,
                        intAllowNegativeInventory = ItemLocation.intAllowNegativeInventory,
                        strAllowNegativeInventory = ItemLocation.strAllowNegativeInventory,
                        intSubLocationId = ItemLocation.intSubLocationId,
                        strSubLocationName = ItemLocation.strSubLocationName,
                        intStorageLocationId = ItemLocation.intStorageLocationId,
                        strStorageLocationName = ItemLocation.strStorageLocationName,
                        intIssueUOMId = ItemLocation.intIssueUOMId,
                        strIssueUOM = ItemLocation.strIssueUOM,
                        intReceiveUOMId = ItemLocation.intReceiveUOMId,
                        strReceiveUOM = ItemLocation.strReceiveUOM,
                        intFamilyId = ItemLocation.intFamilyId,
                        strFamily = ItemLocation.strFamily,
                        intClassId = ItemLocation.intClassId,
                        strClass = ItemLocation.strClass,
                        intProductCodeId = ItemLocation.intProductCodeId,
                        strPassportFuelId1 = ItemLocation.strPassportFuelId1,
                        strPassportFuelId2 = ItemLocation.strPassportFuelId2,
                        strPassportFuelId3 = ItemLocation.strPassportFuelId3,
                        ysnTaxFlag1 = ItemLocation.ysnTaxFlag1,
                        ysnTaxFlag2 = ItemLocation.ysnTaxFlag2,
                        ysnTaxFlag3 = ItemLocation.ysnTaxFlag3,
                        ysnTaxFlag4 = ItemLocation.ysnTaxFlag4,
                        ysnPromotionalItem = ItemLocation.ysnPromotionalItem,
                        intMixMatchId = ItemLocation.intMixMatchId,
                        strPromoItemListId = ItemLocation.strPromoItemListId,
                        ysnDepositRequired = ItemLocation.ysnDepositRequired,
                        intDepositPLUId = ItemLocation.intDepositPLUId,
                        strDepositPLU = ItemLocation.strDepositPLU,
                        intBottleDepositNo = ItemLocation.intBottleDepositNo,
                        ysnSaleable = ItemLocation.ysnSaleable,
                        ysnQuantityRequired = ItemLocation.ysnQuantityRequired,
                        ysnScaleItem = ItemLocation.ysnScaleItem,
                        ysnFoodStampable = ItemLocation.ysnFoodStampable,
                        ysnReturnable = ItemLocation.ysnReturnable,
                        ysnPrePriced = ItemLocation.ysnPrePriced,
                        ysnOpenPricePLU = ItemLocation.ysnOpenPricePLU,
                        ysnLinkedItem = ItemLocation.ysnLinkedItem,
                        strVendorCategory = ItemLocation.strVendorCategory,
                        ysnCountBySINo = ItemLocation.ysnCountBySINo,
                        strSerialNoBegin = ItemLocation.strSerialNoBegin,
                        strSerialNoEnd = ItemLocation.strSerialNoEnd,
                        ysnIdRequiredLiquor = ItemLocation.ysnIdRequiredLiquor,
                        ysnIdRequiredCigarette = ItemLocation.ysnIdRequiredCigarette,
                        intMinimumAge = ItemLocation.intMinimumAge,
                        ysnApplyBlueLaw1 = ItemLocation.ysnApplyBlueLaw1,
                        ysnApplyBlueLaw2 = ItemLocation.ysnApplyBlueLaw2,
                        ysnCarWash = ItemLocation.ysnCarWash,
                        intItemTypeCode = ItemLocation.intItemTypeCode,
                        strItemTypeCode = ItemLocation.strItemTypeCode,
                        intItemTypeSubCode = ItemLocation.intItemTypeSubCode,
                        ysnAutoCalculateFreight = ItemLocation.ysnAutoCalculateFreight,
                        intFreightMethodId = ItemLocation.intFreightMethodId,
                        strFreightTerm = ItemLocation.strFreightTerm,
                        dblFreightRate = ItemLocation.dblFreightRate,
                        intShipViaId = ItemLocation.intShipViaId,
                        strShipVia = ItemLocation.strShipVia,
                        dblReorderPoint = ItemLocation.dblReorderPoint,
                        dblMinOrder = ItemLocation.dblMinOrder,
                        dblSuggestedQty = ItemLocation.dblSuggestedQty,
                        dblLeadTime = ItemLocation.dblLeadTime,
                        strCounted = ItemLocation.strCounted,
                        intCountGroupId = ItemLocation.intCountGroupId,
                        strCountGroup = ItemLocation.strCountGroup,
                        ysnCountedDaily = ItemLocation.ysnCountedDaily,
                        ysnLockedInventory = ItemLocation.ysnLockedInventory,
                        intSort = ItemLocation.intSort,
                        strRegProdCode = leftJoin.strRegProdCode
                    } 
                )
                .Filter(param, true);
            var data = await query.ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public SaveResult CheckCostingMethod(int ItemId, int ItemLocationId, int CostingMethod)
        {
            SaveResult saveResult = new SaveResult();
            var msg = "";

                //Check if Stock exists for the item
                var query = _db.GetQuery<tblICItemStock>()
                         .Where(t => t.intItemId == ItemId && t.intItemLocationId == ItemLocationId && t.dblUnitOnHand > 0);

                var totalItemWithStock = query.Count();

                //Stock Exists
                if (totalItemWithStock > 0)
                {
                    //Check if Costing Method is Changed
                    var query2 = _db.GetQuery<tblICItemLocation>()
                         .Where(t => t.intItemLocationId == ItemLocationId && t.intCostingMethod != CostingMethod);

                    var totalItemCostingMethodChange = query2.Count();

                    //Costing Method is Changed
                    if (totalItemCostingMethodChange > 0)
                    {
                        msg += "Costing Method cannot be changed due to Stock already Exists.";

                        saveResult.HasError = true;
                    }

                    //Costing Method is not changed
                    else
                    {
                        msg = "success";
                        saveResult.HasError = false;
                    }

                }

                //Stock Don't Exists
                else
                {
                    msg = "success";
                    saveResult.HasError = false;
                }

                return saveResult;
        }

        public override BusinessResult<tblICItemLocation> Validate(IEnumerable<tblICItemLocation> entities, ValidateAction action)
        {
            var msg = "";
            var isValid = false;

            foreach (tblICItemLocation item in entities)
            {
                //Check if Stock exists for the item
                var query = _db.GetQuery<tblICItemStock>()
                         .Where(t => t.intItemId == item.intItemId && t.intItemLocationId == item.intItemLocationId && t.dblUnitOnHand > 0);

                var totalItemWithStock = query.Count();

                //Stock Exists
                if (totalItemWithStock > 0)
                {
                    //Check if Costing Method is Changed
                    var query2 = _db.GetQuery<tblICItemLocation>()
                         .Where(t => t.intItemLocationId == item.intItemLocationId && t.intCostingMethod != item.intCostingMethod);

                    var totalItemCostingMethodChange = query2.Count();

                    //Costing Method is Changed
                    if (totalItemCostingMethodChange > 0)
                    {
                        msg += "Costing Method cannot be changed due to Stock already Exists.";
                        isValid = false;
                    }

                    //Costing Method is not changed
                    else
                    {
                        msg = "success";
                        isValid = true;
                    }
                    
                }

                //Stock Don't Exists
                else
                {
                    msg = "success";
                    isValid = true;
                }
                
            }
            goto returnValidate;
          
        returnValidate:
        return new BusinessResult<tblICItemLocation>()
            {
                success = isValid,
                message = new MessageResult()
                {
                    statusText = msg,
                    button = "ok",
                    status = Error.OtherException
                }
            };
        }


        public override async Task<BusinessResult<tblICItemLocation>> SaveAsync(bool continueOnConflict)
        {
            var result = await _db.SaveAsync(continueOnConflict).ConfigureAwait(false);
            var msg = result.Exception.Message;

            if (result.HasError)
            {
                if (result.BaseException.Message.Contains("Violation of UNIQUE KEY constraint 'AK_tblICItemLocation'"))
                {
                    msg = "Location must be unique per Item.";
                }
                else if (result.BaseException.Message.Contains("The DELETE statement conflicted with the REFERENCE constraint \"FK_tblICItemPricing_tblICItemLocation\"."))
                {
                    msg = "The location you are trying to delete is being used in the Pricing tab.";
                }
            }

            return new BusinessResult<tblICItemLocation>()
            {
                success = !result.HasError,
                message = new MessageResult()
                {
                    statusText = msg,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            };
        }
    }
}
