using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICReadingPoint : BaseEntity
    {
        public int intReadingPointId { get; set; }
        public string strReadingPoint { get; set; }
        public int? intSort { get; set; }

        public ICollection<tblICStorageLocationMeasurement> tblICStorageLocationMeasurements { get; set; }
    }
}
