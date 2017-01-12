﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemOwner : BaseEntity
    {
        public int intItemOwnerId { get; set; }
        public int intItemId { get; set; }
        public int? intOwnerId { get; set; }
        public bool ysnDefault { get; set; }
        public int? intSort { get; set; }

        private string _customerNo;
        [NotMapped]
        public string strCustomerNumber
        {
            get
            {
                if (string.IsNullOrEmpty(_customerNo))
                    if (tblARCustomer != null)
                        return tblARCustomer.strCustomerNumber;
                    else
                        return null;
                else
                    return _customerNo;
            }
            set
            {
                _customerNo = value;
            }
        }

        private string _customerName;
        [NotMapped]
        public string strName
        {
            get
            {
                if (string.IsNullOrEmpty(_customerName))
                    if (tblARCustomer != null)
                        return tblARCustomer.strCustomerName;
                    else
                        return null;
                else
                    return _customerName;
            }
            set
            {
                _customerName = value;
            }
        }

        public tblARCustomer tblARCustomer { get; set; }
        public tblICItem tblICItem { get; set; }
    }
}
