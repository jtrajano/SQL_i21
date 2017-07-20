using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemCustomerXref : BaseEntity
    {
        public int intItemCustomerXrefId { get; set; }
        public int intItemId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intCustomerId { get; set; }
        public string strCustomerProduct { get; set; }
        public string strProductDescription { get; set; }
        public string strPickTicketNotes { get; set; }
        public int? intSort { get; set; }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblICItemLocation != null)
                        return tblICItemLocation.strLocationName;
                    else
                        return null;
                else
                    return _location;
            }
            set
            {
                _location = value;
            }
        }
        private string _customer;
        [NotMapped]
        public string strCustomerNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_customer))
                    if (tblARCustomer != null)
                        return tblARCustomer.strCustomerNumber;
                    else
                        return null;
                else
                    return _customer;
            }
            set
            {
                _customer = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public tblICItemLocation tblICItemLocation { get; set; }
        public tblARCustomer tblARCustomer { get; set; }
    }
}
