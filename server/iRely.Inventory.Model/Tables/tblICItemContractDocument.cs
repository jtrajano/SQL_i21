using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItemContractDocument : BaseEntity
    {
        public int intItemContractDocumentId { get; set; }
        public int intItemContractId { get; set; }
        public int? intDocumentId { get; set; }
        public int intSort { get; set; }

        private string _document;
        [NotMapped]
        public string strDocumentName
        {
            get
            {
                if (string.IsNullOrEmpty(_document))
                    if (tblICDocument != null)
                        return tblICDocument.strDocumentName;
                    else
                        return null;
                else
                    return _document;
            }
            set
            {
                _document = value;
            }
        }

        public tblICItemContract tblICItemContract { get; set; }
        public tblICDocument tblICDocument { get; set; }
    }
}
