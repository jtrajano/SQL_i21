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
        public string strManufacturer { get; set; }
        public string strContact { get; set; }
        public string strAddress { get; set; }
        public string strZipCode { get; set; }
        public string strCity { get; set; }
        public string strState { get; set; }
        public string strCountry { get; set; }
        public string strPhone { get; set; }
        public string strFax { get; set; }
        public string strWebsite { get; set; }
        public string strEmail { get; set; }
        public string strNotes { get; set; }

        public ICollection<tblICBrand> tblICBrands { get; set; }
    }
}
