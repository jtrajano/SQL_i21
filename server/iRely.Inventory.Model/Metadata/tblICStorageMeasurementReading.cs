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
        public int intStorageMeasurementReadingId { get; set; }
        public int? intLocationId { get; set; }
        public DateTime? dtmDate { get; set; }
        public string strReadingNo { get; set; }
        public int? intSort { get; set; }

        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public ICollection<tblICStorageMeasurementReadingConversion> tblICStorageMeasurementReadingConversions { get; set; }
    }

    public class StorageMeasurementReadingVM
    {
        public int intStorageMeasurementReadingId { get; set; }
        public int intLocationId { get; set; }
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
        public int? intSubLocationId { get; set; }
        public decimal? dblAirSpaceReading { get; set; }
        public decimal? dblCashPrice { get; set; }
        public int? intSort { get; set; }

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

        public tblICStorageMeasurementReadingConversion tblICStorageMeasurementReadingConversion { get; set; }
    }
    
}
