using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICMeasurement : BaseEntity
    {
        public int intMeasurementId { get; set; }
        public string strMeasurementName { get; set; }
        public string strDescription { get; set; }
        public string strMeasurementType { get; set; }
        public int? intSort { get; set; }

        public ICollection<tblICStorageLocationMeasurement> tblICStorageLocationMeasurements { get; set; }
    }
}
