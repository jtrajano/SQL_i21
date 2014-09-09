using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICManufacturer : BaseEntity
    {
        public int intManufacturerId { get; set; }
        public int strManufacturer { get; set; }
        public int strContact { get; set; }
        public int strAddress { get; set; }
        public int strZipCode { get; set; }
        public int strCity { get; set; }
        public int strState { get; set; }
        public int strCountry { get; set; }
        public int strPhone { get; set; }
        public int strFax { get; set; }
        public int strWebsite { get; set; }
        public int strEmail { get; set; }
        public int strNotes { get; set; }
    }
}
