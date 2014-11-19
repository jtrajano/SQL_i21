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
        public int intStorageLocationId { get; set; }
        public string strName { get; set; }
        public string strDescription { get; set; }
        public int? intStorageUnitTypeId { get; set; }
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
        public decimal? dblPackFactor { get; set; }
        public decimal? dblUnitPerFoot { get; set; }
        public decimal? dblResidualUnit { get; set; }
    }

    public class tblICStorageLocationCategory : BaseEntity
    {
        public int intStorageLocationCategoryId { get; set; }
        public int intStorageLocationId { get; set; }
        public int intCategoryId { get; set; }
        public int intSort { get; set; }
    }

    public class tblICStorageLocationMeasurement : BaseEntity
    {
        public int intStorageLocationMeasurementId { get; set; }
        public int intStorageLocationId { get; set; }
        public int intMeasurementId { get; set; }
        public int intReadingPointId { get; set; }
        public bool ysnActive { get; set; }
        public int intSort { get; set; }
    }

}
