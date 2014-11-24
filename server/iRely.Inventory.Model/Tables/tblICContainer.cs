using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICContainer : BaseEntity
    {
        public int intContainerId { get; set; }
        public int? intExternalSystemId { get; set; }
        public string strContainerId { get; set; }
        public int? intContainerTypeId { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strLastUpdateBy { get; set; }
        public DateTime? dtmLastUpdateOn { get; set; }
        public int? intSort { get; set; }

        public tblICContainerType tblICContainerType { get; set; }

        public ICollection<tblICStorageLocationSku> tblICStorageLocationSkus { get; set; }
        public ICollection<tblICStorageLocationContainer> tblICStorageLocationContainers { get; set; }
    }
}
