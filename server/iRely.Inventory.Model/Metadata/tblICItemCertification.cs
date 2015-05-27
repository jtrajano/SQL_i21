using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemCertification : BaseEntity
    {
        public int intItemCertificationId { get; set; }
        public int intItemId { get; set; }
        public int intCertificationId { get; set; }
        public int intSort { get; set; }

        private string _certification;
        [NotMapped]
        public string strCertificationName
        {
            get
            {
                if (string.IsNullOrEmpty(_certification))
                    if (tblICCertification != null)
                        return tblICCertification.strCertificationName;
                    else
                        return null;
                else
                    return _certification;
            }
            set
            {
                _certification = value;
            }
        }

        public tblICItem tblICItem { get; set; }
        public tblICCertification tblICCertification { get; set; }
    }
}
