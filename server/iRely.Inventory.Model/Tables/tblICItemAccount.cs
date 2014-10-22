using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemAccount : BaseEntity
    {
        public int intItemAccountId { get; set; }
        public int intItemId { get; set; }
        public int? intLocationId { get; set; }
        public string strAccountDescription { get; set; }
        public int? intAccountId { get; set; }
        public int? intProfitCenterId { get; set; }
        public int intSort { get; set; }

        private string _location;
        [NotMapped]
        public string strLocationName
        {
            get
            {
                if (string.IsNullOrEmpty(_location))
                    if (tblSMCompanyLocation != null)
                        return tblSMCompanyLocation.strLocationName;
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
        private string _accountid;
        [NotMapped]
        public string strAccountId
        {
            get
            {
                if (string.IsNullOrEmpty(_accountid))
                    if (tblGLAccount != null)
                        return tblGLAccount.strAccountId;
                    else
                        return null;
                else
                    return _accountid;
            }
            set
            {
                _accountid = value;
            }
        }
        private string _profitcenter;
        [NotMapped]
        public string strProfitCenter
        {
            get
            {
                if (string.IsNullOrEmpty(_profitcenter))
                    if (ProfitCenter != null)
                        return ProfitCenter.strAccountId;
                    else
                        return null;
                else
                    return _profitcenter;
            }
            set
            {
                _profitcenter = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public tblGLAccount tblGLAccount { get; set; }
        public tblGLAccount ProfitCenter { get; set; }
        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
    }
}
