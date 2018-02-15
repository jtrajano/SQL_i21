﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemVendorXref : BaseEntity
    {
        public int intItemVendorXrefId { get; set; }
        public int intItemId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intVendorId { get; set; }
        public string strVendorProduct { get; set; }
        public string strProductDescription { get; set; }
        public decimal? dblConversionFactor { get; set; }
        public int? intItemUnitMeasureId { get; set; }
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
        private string _vendor;
        [NotMapped]
        public string strVendorId
        {
            get
            {
                if (string.IsNullOrEmpty(_vendor))
                    if (vyuAPVendor != null)
                        return vyuAPVendor.strVendorId;
                    else
                        return null;
                else
                    return _vendor;
            }
            set
            {
                _vendor = value;
            }
        }
        private string _unitmeasure;
        [NotMapped]
        public string strUnitMeasure
        {
            get
            {
                if (string.IsNullOrEmpty(_unitmeasure))
                    if (tblICItemUOM != null)
                        return tblICItemUOM.strUnitMeasure;
                    else
                        return null;
                else
                    return _unitmeasure;
            }
            set
            {
                _unitmeasure = value;
            }
        }
        private string _vendorName;
        [NotMapped]
        public string strVendorName
        {
            get
            {
                if (string.IsNullOrEmpty(_vendorName))
                    if (vyuAPVendor != null)
                        return vyuAPVendor.strName;
                    else
                        return null;
                else
                    return _vendorName;
            }
            set
            {
                _vendorName = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public tblICItemLocation tblICItemLocation { get; set; }
        public vyuAPVendor vyuAPVendor { get; set; }
        public tblICItemUOM tblICItemUOM { get; set; }
    }
}
