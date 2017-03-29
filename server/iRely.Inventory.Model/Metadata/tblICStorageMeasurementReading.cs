using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICStorageMeasurementReading : BaseEntity
    {
        public tblICStorageMeasurementReading()
        {
            this.tblICStorageMeasurementReadingConversions = new List<tblICStorageMeasurementReadingConversion>();
        }

        public int intStorageMeasurementReadingId { get; set; }
        public int? intLocationId { get; set; }
        public DateTime? dtmDate { get; set; }
        public string strReadingNo { get; set; }
        public int? intSort { get; set; }

        private string _location;
        [NotMapped]
        public string strLocation
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblSMCompanyLocation != null)
                        return tblSMCompanyLocation.strLocationName;
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

        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public ICollection<tblICStorageMeasurementReadingConversion> tblICStorageMeasurementReadingConversions { get; set; }
    }

    public class StorageMeasurementReadingVM
    {
        public int intStorageMeasurementReadingId { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public DateTime? dtmDate { get; set; }
        public string strReadingNo { get; set; }
        public int? intSort { get; set; }
    }

    public class tblICStorageMeasurementReadingConversion : BaseEntity
    {
        public int intStorageMeasurementReadingConversionId { get; set; }
        public int intStorageMeasurementReadingId { get; set; }
        public int? intCommodityId { get; set; }
        public int? intItemId { get; set; }
        public int? intStorageLocationId { get; set; }
        public decimal? dblAirSpaceReading { get; set; }
        public decimal? dblCashPrice { get; set; }
        public int? intDiscountSchedule { get; set; }
        public int? intSort { get; set; }

        private string _unitMeasure;

        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_unitMeasure))
                    if (vyuICGetStorageMeasurementReadingConversion != null)
                        return vyuICGetStorageMeasurementReadingConversion.strUnitMeasure;
                    else
                        return null;
                else
                    return _unitMeasure;
            }
            set
            {
                _unitMeasure = value;
            }
        }

        private string _commodity;
        [NotMapped]
        public string strCommodity
        {
            get
            {
                if (string.IsNullOrEmpty(_commodity))
                    if (vyuICGetStorageMeasurementReadingConversion != null)
                        return vyuICGetStorageMeasurementReadingConversion.strCommodity;
                    else
                        return null;
                else
                    return _commodity;
            }
            set
            {
                _commodity = value;
            }
        }
        private string _itemNo;
        [NotMapped]
        public string strItemNo
        {
            get
            {
                if (string.IsNullOrEmpty(_itemNo))
                    if (vyuICGetStorageMeasurementReadingConversion != null)
                        return vyuICGetStorageMeasurementReadingConversion.strItemNo;
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
        private string _storageLocation;
        [NotMapped]
        public string strStorageLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_storageLocation))
                    if (vyuICGetStorageMeasurementReadingConversion != null)
                        return vyuICGetStorageMeasurementReadingConversion.strStorageLocationName;
                    else
                        return null;
                else
                    return _storageLocation;
            }
            set
            {
                _storageLocation = value;
            }
        }
        private int? _subLocationId;
        [NotMapped]
        public int? intSubLocationId
        {
            get
            {
                if (vyuICGetStorageMeasurementReadingConversion != null)
                    return vyuICGetStorageMeasurementReadingConversion.intSubLocationId;
                else
                    return null;
            }
            set
            {
                _subLocationId = value;
            }
        }
        private string _subLocation;
        [NotMapped]
        public string strSubLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_subLocation))
                    if (vyuICGetStorageMeasurementReadingConversion != null)
                        return vyuICGetStorageMeasurementReadingConversion.strSubLocationName;
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
        private decimal _effectiveDepth;
        [NotMapped]
        public decimal dblEffectiveDepth
        {
            get
            {
                if (vyuICGetStorageMeasurementReadingConversion != null)
                    return vyuICGetStorageMeasurementReadingConversion.dblEffectiveDepth ?? 0;
                else
                    return _effectiveDepth;
            }
            set
            {
                _effectiveDepth = value;
            }
        }
        private string _discountSchedule;
        [NotMapped]
        public string strDiscountSchedule
        {
            get
            {
                if (string.IsNullOrEmpty(_discountSchedule))
                    if (vyuICGetStorageMeasurementReadingConversion != null)
                        return vyuICGetStorageMeasurementReadingConversion.strDiscountSchedule;
                    else
                        return null;
                else
                    return _discountSchedule;
            }
            set
            {
                _discountSchedule = value;
            }
        }

        public tblICStorageMeasurementReading tblICStorageMeasurementReading { get; set; }
        public vyuICGetStorageMeasurementReadingConversion vyuICGetStorageMeasurementReadingConversion { get; set; }
    }

    public class vyuICGetStorageMeasurementReadingConversion
    {
        public int intStorageMeasurementReadingConversionId { get; set; }
        public int intStorageMeasurementReadingId { get; set; }
        public string strReadingNo { get; set; }
        public DateTime? dtmDate { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodity { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public decimal? dblEffectiveDepth { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public decimal? dblAirSpaceReading { get; set; }
        public decimal? dblCashPrice { get; set; }
        public int? intDiscountSchedule { get; set; }
        public string strDiscountSchedule { get; set; }
        public string strUnitMeasure { get; set; }
        public int? intUnitMeasureId { get; set; }

        public tblICStorageMeasurementReadingConversion tblICStorageMeasurementReadingConversion { get; set; }
    }
    
}
