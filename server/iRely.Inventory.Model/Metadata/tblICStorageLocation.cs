using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICStorageLocation : BaseEntity
    {
        public tblICStorageLocation()
        {
            this.tblICStorageLocationCategories = new List<tblICStorageLocationCategory>();
            this.tblICStorageLocationMeasurements = new List<tblICStorageLocationMeasurement>();
            this.tblICStorageLocationSkus = new List<tblICStorageLocationSku>();
            this.tblICStorageLocationContainers = new List<tblICStorageLocationContainer>();
        }

        public int intStorageLocationId { get; set; }
        public string strName { get; set; }
        public string strDescription { get; set; }
        public int? intStorageUnitTypeId { get; set; }
        public int? intLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intParentStorageLocationId { get; set; }
        public bool ysnAllowConsume { get; set; }
        public bool ysnAllowMultipleItem { get; set; }
        public bool ysnAllowMultipleLot { get; set; }
        public bool ysnMergeOnMove { get; set; }
        public bool ysnCycleCounted { get; set; }
        public bool ysnDefaultWHStagingUnit { get; set; }
        public int? intRestrictionId { get; set; }
        public string strUnitGroup { get; set; }
        public decimal? dblMinBatchSize { get; set; }
        public decimal? dblBatchSize { get; set; }
        public int? intBatchSizeUOMId { get; set; }
        public int? intSequence { get; set; }
        public bool ysnActive { get; set; }
        public int? intRelativeX { get; set; }
        public int? intRelativeY { get; set; }
        public int? intRelativeZ { get; set; }
        public int? intCommodityId { get; set; }
        public int? intItemId { get; set; }
        public decimal? dblPackFactor { get; set; }
        public decimal? dblEffectiveDepth { get; set; }
        public decimal? dblUnitPerFoot { get; set; }
        public decimal? dblResidualUnit { get; set; }

        private string _storageUnitType;
        [NotMapped]
        public string strStorageUnitType
        {
            get
            {
                if (string.IsNullOrEmpty(_storageUnitType))
                    if (vyuICGetStorageLocation != null)
                        return vyuICGetStorageLocation.strStorageUnitType;
                    else
                        return null;
                else
                    return _storageUnitType;
            }
            set
            {
                _storageUnitType = value;
            }
        }

        private string _location;
        [NotMapped]
        public string strLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (vyuICGetStorageLocation != null)
                        return vyuICGetStorageLocation.strLocationName;
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

        private string _subLocation;
        [NotMapped]
        public string strSubLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocation))
                    if (vyuICGetStorageLocation != null)
                        return vyuICGetStorageLocation.strSubLocationName;
                    else
                        return null;
                else
                    return _subLocation;
            }
            set
            {
                _subLocation = value;
            }
        }

        private string _parentUnit;
        [NotMapped]
        public string strParentUnit
        {
            get
            {
                if (string.IsNullOrEmpty(_parentUnit))
                    if (vyuICGetStorageLocation != null)
                        return vyuICGetStorageLocation.strParentStorageLocationName;
                    else
                        return null;
                else
                    return _parentUnit;
            }
            set
            {
                _parentUnit = value;
            }
        }

        private string _restrictionType;
        [NotMapped]
        public string strRestrictionType
        {
            get
            {
                if (string.IsNullOrEmpty(_restrictionType))
                    if (vyuICGetStorageLocation != null)
                        return vyuICGetStorageLocation.strRestrictionCode;
                    else
                        return null;
                else
                    return _restrictionType;
            }
            set
            {
                _restrictionType = value;
            }
        }

        private string _batchSizeUOM;
        [NotMapped]
        public string strBatchSizeUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_batchSizeUOM))
                    if (vyuICGetStorageLocation != null)
                        return vyuICGetStorageLocation.strBatchSizeUOM;
                    else
                        return null;
                else
                    return _batchSizeUOM;
            }
            set
            {
                _batchSizeUOM = value;
            }
        }

        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (vyuICGetStorageLocation != null)
                        return vyuICGetStorageLocation.strItemNo;
                    else
                        return null;
                else
                    return _itemNo;
            }
            set
            {
                _itemNo = value;
            }
        }

        public tblSMCompanyLocationSubLocation tblSMCompanyLocationSubLocation { get; set; }
        public ICollection<tblICStorageLocationCategory> tblICStorageLocationCategories { get; set; }
        public ICollection<tblICStorageLocationMeasurement> tblICStorageLocationMeasurements { get; set; }
        public ICollection<tblICStorageLocationSku> tblICStorageLocationSkus { get; set; }
        public ICollection<tblICStorageLocationContainer> tblICStorageLocationContainers { get; set; }
        public ICollection<tblICInventoryReceiptItemLot> tblICInventoryReceiptItemLots { get; set; }
        public vyuICGetStorageLocation vyuICGetStorageLocation { get; set; }
    }

    public class tblICStorageLocationCategory : BaseEntity
    {
        public int intStorageLocationCategoryId { get; set; }
        public int intStorageLocationId { get; set; }
        public int? intCategoryId { get; set; }
        public int intSort { get; set; }

        private string _strCategoryCode;
        [NotMapped]
        public string strCategoryCode
        {
            get
            {
                if (string.IsNullOrEmpty(_strCategoryCode))
                    if (tblICCategory != null)
                        return tblICCategory.strCategoryCode;
                    else
                        return null;
                else
                    return _strCategoryCode;
            }
            set
            {
                _strCategoryCode = value;
            }
        }

        public tblICStorageLocation tblICStorageLocation { get; set; }
        public tblICCategory tblICCategory { get; set; }
        
    }

    public class tblICStorageLocationMeasurement : BaseEntity
    {
        public int intStorageLocationMeasurementId { get; set; }
        public int intStorageLocationId { get; set; }
        public int intMeasurementId { get; set; }
        public int intReadingPointId { get; set; }
        public bool ysnActive { get; set; }
        public int intSort { get; set; }

        private string _measurementName;
        [NotMapped]
        public string strMeasurementName
        {
            get
            {
                if (string.IsNullOrEmpty(_measurementName))
                    if (tblICMeasurement != null)
                        return tblICMeasurement.strMeasurementName;
                    else
                        return null;
                else
                    return _measurementName;
            }
            set
            {
                _measurementName = value;
            }
        }
        private string _readingPoint;
        [NotMapped]
        public string strReadingPoint
        {
            get
            {
                if (string.IsNullOrEmpty(_readingPoint))
                    if (tblICReadingPoint != null)
                        return tblICReadingPoint.strReadingPoint;
                    else
                        return null;
                else
                    return _readingPoint;
            }
            set
            {
                _readingPoint = value;
            }
        }

        public tblICStorageLocation tblICStorageLocation { get; set; }
        public tblICMeasurement tblICMeasurement { get; set; }
        public tblICReadingPoint tblICReadingPoint { get; set; }
    }

    public class tblICStorageLocationSku : BaseEntity
    {
        public int intStorageLocationSkuId { get; set; }
        public int intStorageLocationId { get; set; }
        public int? intItemId { get; set; }
        public int? intSkuId { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intContainerId { get; set; }
        public int? intLotCodeId { get; set; }
        public int? intLotStatusId { get; set; }
        public int? intOwnerId { get; set; }
        public int? intSort { get; set; }

        private string _sku;
        [NotMapped]
        public string strSKU
        {
            get
            {
                if (string.IsNullOrEmpty(_sku))
                    if (tblICSku != null)
                        return tblICSku.strSKU;
                    else
                        return null;
                else
                    return _sku;
            }
            set
            {
                _sku = value;
            }
        }
        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (tblICItem != null)
                        return tblICItem.strItemNo;
                    else
                        return null;
                else
                    return _itemNo;
            }
            set
            {
                _itemNo = value;
            }
        }
        private string _container;
        [NotMapped]
        public string strContainer
        {
            get
            {
                if (string.IsNullOrEmpty(_container))
                    if (tblICContainer != null)
                        return tblICContainer.strContainerId;
                    else
                        return null;
                else
                    return _container;
            }
            set
            {
                _container = value;
            }
        }
        private string _lotStatus;
        [NotMapped]
        public string strLotStatus
        {
            get
            {
                if (string.IsNullOrEmpty(_lotStatus))
                    if (tblICLotStatus != null)
                        return tblICLotStatus.strPrimaryStatus;
                    else
                        return null;
                else
                    return _lotStatus;
            }
            set
            {
                _lotStatus = value;
            }
        }

        public tblICStorageLocation tblICStorageLocation { get; set; }
        public tblICSku tblICSku { get; set; }
        public tblICItem tblICItem { get; set; }
        public tblICContainer tblICContainer { get; set; }
        public tblICLotStatus tblICLotStatus { get; set; }
    }

    public class tblICStorageLocationContainer : BaseEntity
    {
        public int intStorageLocationContainerId { get; set; }
        public int intStorageLocationId { get; set; }
        public int? intContainerId { get; set; }
        public int? intExternalSystemId { get; set; }
        public int? intContainerTypeId { get; set; }
        public string strLastUpdatedBy { get; set; }
        public DateTime? dtmLastUpdatedOn { get; set; }
        public int? intSort { get; set; }

        private string _container;
        [NotMapped]
        public string strContainer
        {
            get
            {
                if (string.IsNullOrEmpty(_container))
                    if (tblICContainer != null)
                        return tblICContainer.strContainerId;
                    else
                        return null;
                else
                    return _container;
            }
            set
            {
                _container = value;
            }
        }
        private string _containerType;
        [NotMapped]
        public string strContainerType
        {
            get
            {
                if (string.IsNullOrEmpty(_containerType))
                    if (tblICContainerType != null)
                        return tblICContainerType.strInternalCode;
                    else
                        return null;
                else
                    return _containerType;
            }
            set
            {
                _containerType = value;
            }
        }

        public tblICStorageLocation tblICStorageLocation { get; set; }
        public tblICContainer tblICContainer { get; set; }
        public tblICContainerType tblICContainerType { get; set; }

    }

    public class vyuICGetSubLocationBins
    {
        public int intCompanyLocationId { get; set; }
        public int intSubLocationId { get; set; }
        public string strLocation { get; set; }
        public string strSubLocation { get; set; }
        public decimal? dblEffectiveDepth { get; set; }
        public decimal? dblPackFactor { get; set; }
        public decimal? dblUnitPerFoot { get; set; }
        public decimal? dblStock { get; set; }
        public decimal? dblCapacity { get; set; }
        public decimal? dblAvailable { get; set; }
    }

    public class vyuICGetSubLocationBinDetails
    {
        public int intItemId { get; set; }
        public int intItemLocationId { get; set; }
        public int intStorageLocationId { get; set; }
        public int intCompanyLocationId { get; set; }
        public string strCommodityCode { get; set; }
        public string strItemDescription { get; set; }
        public string strItemNo { get; set; }
        public string strUOM { get; set; }
        public string strLocation { get; set; }
        public string strStorageLocation { get; set; }
        public string strDiscountCode { get; set; }
        public string strDiscountDescription { get; set; }
        public DateTime? dtmReadingDate { get; set; }
        public decimal? dblAirSpaceReading { get; set; }
        public decimal? dblPhysicalReading { get; set; }
        public decimal? dblStockVariance { get; set; }
        public decimal? dblCapacity { get; set; }
        public decimal? dblStock { get; set; }
        public decimal? dblAvailable { get; set; }
        public decimal? dblEffectiveDepth { get; set; }
        public decimal? dblPackFactor { get; set; }
        public decimal? dblUnitPerFoot { get; set; }
        public string strSubLocationName { get; set; }
        public int? intSubLocationId { get; set; }
    }

    public class vyuICGetStorageBins
    {
        public int intStorageLocationId { get; set; }
        public int intCompanyLocationId { get; set; }
        public string strLocation { get; set; }
        public string strStorageLocation { get; set; }
        public decimal dblCapacity { get; set; }
        public decimal dblStock { get; set; }
        public decimal dblAvailable { get; set; }
    }

    public class vyuICGetStorageBinDetails
    {
        public int intItemId { get; set; }
        public int intItemLocationId { get; set; }
        public int intStorageLocationId { get; set; }
        public int intCompanyLocationId { get; set; }
        public string strCommodityCode { get; set; }
        public string strItemDescription { get; set; }
        public string strItemNo { get; set; }
        public string strUOM { get; set; }
        public string strLocation { get; set; }
        public string strStorageLocation { get; set; }
        public string strDiscountCode { get; set; }
        public string strDiscountDescription { get; set; }
        public DateTime? dtmReadingDate { get; set; }
        public decimal? dblAirSpaceReading { get; set; }
        public decimal? dblPhysicalReading { get; set; }
        public decimal? dblStockVariance { get; set; }
        public decimal? dblCapacity { get; set; }
        public decimal? dblStock { get; set; }
        public decimal? dblAvailable { get; set; }
        public decimal? dblEffectiveDepth { get; set; }
        public decimal? dblPackFactor { get; set; }
        public decimal? dblUnitPerFoot { get; set; }
        public string strSubLocationName { get; set; }
        public int? intSubLocationId { get; set; }
    }

    public class vyuICGetStorageBinMeasurementReading
    {
        public int intItemId { get; set; }
        public int intItemLocationId { get; set; }
        public int intStorageLocationId { get; set; }
        public int intCompanyLocationSubLocationId { get; set; }
        public int? intCommodityId { get; set; }
        public int intCompanyLocationId { get; set; }
        public string strItemDescription { get; set; }
        public string strItemNo { get; set; }
        public string strSubLocation { get; set; }
        public string strLocation { get; set; }
        public string strStorageLocation { get; set; }
        public string strCommodityCode { get; set; }
        public decimal dblEffectiveDepth { get; set; }
        public int? intUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
    }

    public class vyuICGetStorageLocation
    {
        public int intStorageLocationId { get; set; }
        public string strName { get; set; }
        public string strDescription { get; set; }
        public int? intStorageUnitTypeId { get; set; }
        public string strStorageUnitType { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intParentStorageLocationId { get; set; }
        public string strParentStorageLocationName { get; set; }
        public bool? ysnAllowConsume { get; set; }
        public bool? ysnAllowMultipleItem { get; set; }
        public bool? ysnAllowMultipleLot { get; set; }
        public bool? ysnMergeOnMove { get; set; }
        public bool? ysnCycleCounted { get; set; }
        public bool? ysnDefaultWHStagingUnit { get; set; }
        public int? intRestrictionId { get; set; }
        public string strRestrictionCode { get; set; }
        public string strRestrictionDesc { get; set; }
        public string strUnitGroup { get; set; }
        public decimal? dblMinBatchSize { get; set; }
        public decimal? dblBatchSize { get; set; }
        public int? intBatchSizeUOMId { get; set; }
        public int? intSequence { get; set; }
        public bool? ysnActive { get; set; }
        public int? intRelativeX { get; set; }
        public int? intRelativeY { get; set; }
        public int? intRelativeZ { get; set; }
        public int? intCommodityId { get; set; }
        public decimal? dblPackFactor { get; set; }
        public decimal? dblEffectiveDepth { get; set; }
        public decimal? dblUnitPerFoot { get; set; }
        public decimal? dblResidualUnit { get; set; }
        public int? intItemId { get; set; }
        public string strInternalCode { get; set; }
        public string strItemNo { get; set; }
        public string strBatchSizeUOM { get; set; }
        public tblICStorageLocation tblICStorageLocation { get; set; }
    }

}
