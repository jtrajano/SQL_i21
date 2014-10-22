using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICBrand : BaseEntity
    {
        public int intBrandId { get; set; }
        public string strBrandCode { get; set; }
        public string strBrandName { get; set; }
        public int? intManufacturerId { get; set; }
        public int intSort { get; set; }

        private string _manufacturer;
        [NotMapped]
        public string strManufacturer
        {
            get
            {
                if (string.IsNullOrEmpty(_manufacturer))
                    if (tblICManufacturer != null)
                        return tblICManufacturer.strManufacturer;
                    else
                        return null;
                else
                    return _manufacturer;
            }
            set
            {
                _manufacturer = value;
            }
        }

        public tblICManufacturer tblICManufacturer { get; set; }
    }
}
