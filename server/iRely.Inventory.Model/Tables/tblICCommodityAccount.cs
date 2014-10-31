using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICCommodityAccount : BaseEntity
    {
        public int intCommodityAccountId { get; set; }
        public int intCommodityId { get; set; }
        public int? intLocationId { get; set; }
        public string strAccountDescription { get; set; }
        public int? intAccountId { get; set; }
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

        public tblICCommodity tblICCommodity { get; set; }
        public tblSMCompanyLocation tblSMCompanyLocation { get; set; }
        public tblGLAccount tblGLAccount { get; set; }
    }
}
