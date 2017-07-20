﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemLocation : BaseEntity
    {
        public int intItemLocationId { get; set; }
        public int intItemId { get; set; }
        public int? intLocationId { get; set; }
        public int? intVendorId { get; set; }
        public string strDescription { get; set; }
        public int? intCostingMethod { get; set; }
        public int intAllowNegativeInventory { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intStorageLocationId { get; set; }
        public int? intIssueUOMId { get; set; }
        public int? intReceiveUOMId { get; set; }
        public int? intGrossUOMId { get; set; }
        public int? intFamilyId { get; set; }
        public int? intClassId { get; set; }
        public int? intProductCodeId { get; set; }
        public int? intFuelTankId { get; set; }
        public string strPassportFuelId1 { get; set; }
        public string strPassportFuelId2 { get; set; }
        public string strPassportFuelId3 { get; set; }
        public bool? ysnTaxFlag1 { get; set; }
        public bool? ysnTaxFlag2 { get; set; }
        public bool? ysnTaxFlag3 { get; set; }
        public bool? ysnTaxFlag4 { get; set; }
        public bool? ysnPromotionalItem { get; set; }
        public int? intMixMatchId { get; set; }
        public bool? ysnDepositRequired { get; set; }
        public int? intDepositPLUId { get; set; }
        public int? intBottleDepositNo { get; set; }
        public bool? ysnSaleable { get; set; }
        public bool? ysnQuantityRequired { get; set; }
        public bool? ysnScaleItem { get; set; }
        public bool? ysnFoodStampable { get; set; }
        public bool? ysnReturnable { get; set; }
        public bool? ysnPrePriced { get; set; }
        public bool? ysnOpenPricePLU { get; set; }
        public bool? ysnLinkedItem { get; set; }
        public string strVendorCategory { get; set; }
        public bool? ysnCountBySINo { get; set; }
        public string strSerialNoBegin { get; set; }
        public string strSerialNoEnd { get; set; }
        public bool? ysnIdRequiredLiquor { get; set; }
        public bool? ysnIdRequiredCigarette { get; set; }
        public int? intMinimumAge { get; set; }
        public bool? ysnApplyBlueLaw1 { get; set; }
        public bool? ysnApplyBlueLaw2 { get; set; }
        public bool? ysnCarWash { get; set; }
        public int? intItemTypeCode { get; set; }
        public int? intItemTypeSubCode { get; set; }
        public bool? ysnAutoCalculateFreight { get; set; }
        public int? intFreightMethodId { get; set; }
        public decimal? dblFreightRate { get; set; }
        public int? intShipViaId { get; set; }
        public int? intNegativeInventory { get; set; }
        public decimal? dblReorderPoint { get; set; }
        public decimal? dblMinOrder { get; set; }
        public decimal? dblSuggestedQty { get; set; }
        public decimal? dblLeadTime { get; set; }
        public string strCounted { get; set; }
        public int? intCountGroupId { get; set; }
        public bool? ysnCountedDaily { get; set; }
        public int? intSort { get; set; }

        private string _countGroup;
        [NotMapped]
        public string strCountGroup
        {
            get
            {
                if (string.IsNullOrEmpty(_countGroup))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strCountGroup;
                    else
                        return null;
                else
                    return _countGroup;
            }
            set
            {
                _countGroup = value;
            }
        }

        private string _promotionItem;
        [NotMapped]
        public string strPromoItemListId
        {
            get
            {
                if (string.IsNullOrEmpty(_promotionItem))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strPromoItemListId;
                    else
                        return null;
                else
                    return _promotionItem;
            }
            set
            {
                _promotionItem = value;
            }
        }

        private string _class;
        [NotMapped]
        public string strClass
        {
            get
            {
                if (string.IsNullOrEmpty(_class))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strClass;
                    else
                        return null;
                else
                    return _class;
            }
            set
            {
                _class = value;
            }
        }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strLocationName;
                    else
                        return null;
                else
                    return _location;
            }
            set
            {
                _location = value;
            }
        }
        [NotMapped]
        public int? intCompanyLocationId
        {
            get
            {
                if (vyuICGetItemLocation != null)
                    return vyuICGetItemLocation.intLocationId;
                else
                    return null;
            }
        }
        [NotMapped]
        public string strCostingMethod
        {
            get
            {
                var costingMethod = "";
                switch (intCostingMethod)
                {
                    case 1:
                        costingMethod = "AVG";
                        break;
                    case 2:
                        costingMethod = "FIFO";
                        break;
                    case 3:
                        costingMethod = "LIFO";
                        break;
                    default:
                        costingMethod = "";
                        break;
                }
                return costingMethod;
            }
        }
        private string _vendor;
        [NotMapped]
        public string strVendorId
        {
            get
            {
                if (string.IsNullOrEmpty(_vendor))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strVendorId;
                    else
                        return null;
                else
                    return _vendor;
            }
            set
            {
                _vendor = value;
            }
        }

        private string _vendorName;
        [NotMapped]
        public string strVendorName
        {
            get
            {
                if (string.IsNullOrEmpty(_vendorName))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strVendorName;
                    else
                        return null;
                else
                    return _vendorName;
            }
            set
            {
                _vendorName = value;
            }
        }

        private string _family;
        [NotMapped]
        public string strFamily
        {
            get
            {
                if (string.IsNullOrEmpty(_family))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strFamily;
                    else
                        return null;
                else
                    return _family;
            }
            set
            {
                _family = value;
            }
        }

        private string _subLocationName;
        [NotMapped]
        public string strSubLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocationName))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strSubLocationName;
                    else
                        return null;
                else
                    return _subLocationName;
            }
            set
            {
                _subLocationName = value;
            }
        }

        private string _storageLocationName;
        [NotMapped]
        public string strStorageLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_storageLocationName))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strStorageLocationName;
                    else
                        return null;
                else
                    return _storageLocationName;
            }
            set
            {
                _storageLocationName = value;
            }
        }

        private string _issueUom;
        [NotMapped]
        public string strIssueUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_issueUom))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strIssueUOM;
                    else
                        return null;
                else
                    return _issueUom;
            }
            set
            {
                _issueUom = value;
            }
        }

        private string _grossUOM;
        [NotMapped]
        public string strGrossUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_grossUOM))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strGrossUOM;
                    else
                        return null;
                else
                    return _grossUOM;
            }
            set
            {
                _grossUOM = value;
            }
        }

        private string _receiveUom;
        [NotMapped]
        public string strReceiveUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_receiveUom))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strReceiveUOM;
                    else
                        return null;
                else
                    return _receiveUom;
            }
            set
            {
                _receiveUom = value;
            }
        }

        private string _productCode;
        [NotMapped]
        public string strProductCode 
        {
            get
            {
                if (string.IsNullOrEmpty(_productCode))
                    if (vyuICGetItemLocation != null)
                        return vyuICGetItemLocation.strProductCode;
                    else
                        return null;
                else
                    return _productCode;
            }
            set
            {
                _productCode = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public vyuICGetItemLocation vyuICGetItemLocation { get; set; }
                
        public ICollection<tblICItemNote> tblICItemNotes { get; set; }
        public ICollection<tblICItemCustomerXref> tblICItemCustomerXrefs { get; set; }
        public ICollection<tblICItemVendorXref> tblICItemVendorXrefs { get; set; }
        public ICollection<tblICItemContract> tblICItemContracts { get; set; }
        public ICollection<tblICItemStock> tblICItemStocks { get; set; }
        public ICollection<tblICItemPricing> tblICItemPricings { get; set; }
        public ICollection<tblICItemPricingLevel> tblICItemPricingLevels { get; set; }
        public ICollection<tblICItemSpecialPricing> tblICItemSpecialPricings { get; set; }
        public ICollection<tblICItemCommodityCost> tblICItemCommodityCosts { get; set; }
        public ICollection<tblICItemSubLocation> tblICItemSubLocations { get; set; }
        
    }
}
