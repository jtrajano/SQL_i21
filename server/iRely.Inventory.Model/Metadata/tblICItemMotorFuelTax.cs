using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemMotorFuelTax : BaseEntity
    {
        public int intItemMotorFuelTaxId { get; set; }
        public int intItemId { get; set; }
        public int? intTaxAuthorityId { get; set; }
        public int? intProductCodeId { get; set; }
        public int? intSort { get; set; }

        private string _taxAuthority;
        [NotMapped]
        public string strTaxAuthorityCode
        {
            get
            {
                if (string.IsNullOrEmpty(_taxAuthority))
                    if (vyuICGetItemMotorFuelTax != null)
                        return vyuICGetItemMotorFuelTax.strTaxAuthorityCode;
                    else
                        return null;
                else
                    return _taxAuthority;
            }
            set
            {
                _taxAuthority = value;
            }
        }
        private string _taxAuthorityDesc;
        [NotMapped]
        public string strTaxAuthorityDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_taxAuthorityDesc))
                    if (vyuICGetItemMotorFuelTax != null)
                        return vyuICGetItemMotorFuelTax.strTaxAuthorityDescription;
                    else
                        return null;
                else
                    return _taxAuthorityDesc;
            }
            set
            {
                _taxAuthorityDesc = value;
            }
        }
        private string _prodCode;
        [NotMapped]
        public string strProductCode
        {
            get
            {
                if (string.IsNullOrEmpty(_prodCode))
                    if (vyuICGetItemMotorFuelTax != null)
                        return vyuICGetItemMotorFuelTax.strProductCode;
                    else
                        return null;
                else
                    return _prodCode;
            }
            set
            {
                _prodCode = value;
            }
        }
        private string _prodDesc;
        [NotMapped]
        public string strProductDescription
        {
            get
            {
                if (string.IsNullOrEmpty(_prodDesc))
                    if (vyuICGetItemMotorFuelTax != null)
                        return vyuICGetItemMotorFuelTax.strProductDescription;
                    else
                        return null;
                else
                    return _prodDesc;
            }
            set
            {
                _prodDesc = value;
            }
        }
        private string _prodCodeGroup;
        [NotMapped]
        public string strProductCodeGroup
        {
            get
            {
                if (string.IsNullOrEmpty(_prodCodeGroup))
                    if (vyuICGetItemMotorFuelTax != null)
                        return vyuICGetItemMotorFuelTax.strProductCodeGroup;
                    else
                        return null;
                else
                    return _prodCodeGroup;
            }
            set
            {
                _prodCodeGroup = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public vyuICGetItemMotorFuelTax vyuICGetItemMotorFuelTax { get; set; }
    }

    public class vyuICGetItemMotorFuelTax
    {
        public int intItemMotorFuelTaxId { get; set; }
        public int intItemId { get; set; }
        public int? intTaxAuthorityId { get; set; }
        public string strTaxAuthorityCode { get; set; }
        public string strTaxAuthorityDescription { get; set; }
        public int? intProductCodeId { get; set; }
        public string strProductCode { get; set; }
        public string strProductDescription { get; set; }
        public string strProductCodeGroup { get; set; }

        public tblICItemMotorFuelTax tblICItemMotorFuelTax { get; set; }
    }
}
