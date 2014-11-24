using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICContainerType : BaseEntity
    {
        public int intContainerTypeId { get; set; }
        public int? intExternalSystemId { get; set; }
        public string strInternalCode { get; set; }
        public string strDisplayMember { get; set; }
        public int? intDimensionUnitMeasureId { get; set; }
        public decimal? dblHeight { get; set; }
        public decimal? dblWidth { get; set; }
        public decimal? dblDepth { get; set; }
        public int? intWeightUnitMeasureId { get; set; }
        public decimal? dblMaxWeight { get; set; }
        public bool ysnLocked { get; set; }
        public bool ysnDefault { get; set; }
        public decimal? dblPalletWeight { get; set; }
        public string strLastUpdateBy { get; set; }
        public DateTime dtmLastUpdateOn { get; set; }
        public string strContainerDescription { get; set; }
        public bool ysnReusable { get; set; }
        public bool ysnAllowMultipleItems { get; set; }
        public bool ysnAllowMultipleLots { get; set; }
        public bool ysnMergeOnMove { get; set; }
        public int? intTareUnitMeasureId { get; set; }
        public int? intSort { get; set; }

        public ICollection<tblICContainer> tblICContainers { get; set; }
        public ICollection<tblICStorageLocationContainer> tblICStorageLocationContainers { get; set; }
    }
}
