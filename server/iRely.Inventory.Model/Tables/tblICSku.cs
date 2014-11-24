using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICSku : BaseEntity
    {
        public int intSKUId { get; set; }
        public int? intExternalSystemId { get; set; }
        public string strSKU { get; set; }
        public int? intSKUStatusId { get; set; }
        public string strLotCode { get; set; }
        public string strSerialNo { get; set; }
        public decimal? dblQuantity { get; set; }
        public DateTime? dtmReceiveDate { get; set; }
        public DateTime? dtmProductionDate { get; set; }
        public int? intItemId { get; set; }
        public int? intContainerId { get; set; }
        public int? intOwnerId { get; set; }
        public string strLastUpdateBy { get; set; }
        public DateTime? dtmLastUpdateOn { get; set; }
        public int? intLotId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public int? intReasonId { get; set; }
        public string strComment { get; set; }
        public int? intParentSKUId { get; set; }
        public decimal? dblWeightPerUnit { get; set; }
        public int? intWeightPerUnitMeasureId { get; set; }
        public int? intUnitPerLayer { get; set; }
        public int? intLayerPerPallet { get; set; }
        public bool ysnSanitized { get; set; }
        public string strBatch { get; set; }
        public int? intSort { get; set; }

        public ICollection<tblICStorageLocationSku> tblICStorageLocationSkus { get; set; }
    }
}
