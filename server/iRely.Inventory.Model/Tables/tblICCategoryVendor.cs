using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCategoryVendor : BaseEntity
    {
        public int intCategoryVendorId { get; set; }
        public int intCategoryId { get; set; }
        public int? intCategoryLocationId { get; set; }
        public int? intVendorId { get; set; }
        public string strVendorDepartment { get; set; }
        public bool ysnAddOrderingUPC { get; set; }
        public bool ysnUpdateExistingRecords { get; set; }
        public bool ysnAddNewRecords { get; set; }
        public bool ysnUpdatePrice { get; set; }
        public int? intFamilyId { get; set; }
        public int? intSellClassId { get; set; }
        public int? intOrderClassId { get; set; }
        public string strComments { get; set; }
        public int? intSort { get; set; }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblICCategoryLocation != null)
                        return tblICCategoryLocation.strLocationName;
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
        private string _vendorId;
        [NotMapped]
        public string strVendorId
        {
            get
            {
                if (string.IsNullOrEmpty(_vendorId))
                    if (vyuAPVendor != null)
                        return vyuAPVendor.strVendorId;
                    else
                        return null;
                else
                    return _vendorId;
            }
            set
            {
                _vendorId = value;
            }
        }
        private string _familyId;
        [NotMapped]
        public string strFamilyId
        {
            get
            {
                if (string.IsNullOrEmpty(_familyId))
                    if (Family != null)
                        return Family.strFamilyId;
                    else
                        return null;
                else
                    return _familyId;
            }
            set
            {
                _familyId = value;
            }
        }
        private string _sellclassId;
        [NotMapped]
        public string strSellClassId
        {
            get
            {
                if (string.IsNullOrEmpty(_sellclassId))
                    if (SellClass != null)
                        return SellClass.strClassId;
                    else
                        return null;
                else
                    return _sellclassId;
            }
            set
            {
                _sellclassId = value;
            }
        }
        private string _orderclassId;
        [NotMapped]
        public string strOrderClassId
        {
            get
            {
                if (string.IsNullOrEmpty(_orderclassId))
                    if (OrderClass != null)
                        return OrderClass.strClassId;
                    else
                        return null;
                else
                    return _orderclassId;
            }
            set
            {
                _orderclassId = value;
            }
        }

        public vyuAPVendor vyuAPVendor { get; set; }
        public tblICCategory tblICCategory { get; set; }
        public tblSTSubcategoryFamily Family { get; set; }
        public tblSTSubcategoryClass SellClass { get; set; }
        public tblSTSubcategoryClass OrderClass { get; set; }
        public tblICCategoryLocation tblICCategoryLocation { get; set; }

    }
}
