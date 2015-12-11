using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICParentLot : BaseEntity
    {
        public int intParentLotId { get; set; }
        public string strParentLotNumber { get; set; }
        public string strParentLotAlias { get; set; }
        public int intItemId { get; set; }
        public DateTime? dtmExpiryDate { get; set; }
        public int intLotStatusId { get; set; }
        public DateTime? dtmDateCreated { get; set; }
        public int? intCreatedUserId { get; set; }
        public int? intCreatedEntityId { get; set; }
    }

}
