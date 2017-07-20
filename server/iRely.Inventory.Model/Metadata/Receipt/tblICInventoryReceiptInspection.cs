using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICInventoryReceiptInspection : BaseEntity
    {
        public int intInventoryReceiptInspectionId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intQAPropertyId { get; set; }
        public bool ysnSelected { get; set; }
        public int intSort { get; set; }
        public string strPropertyName { get; set; }
        /* private string _propertyName;
         [NotMapped]
         public string strPropertyName
         {
             get
             {
                 if (string.IsNullOrEmpty(_propertyName))
                     if (tblMFQAProperty != null)
                         return tblMFQAProperty.strPropertyName;
                     else
                         return null;
                 else
                     return _propertyName;
             }
             set
             {
                 _propertyName = value;
             }
         }
         private string _description;
         [NotMapped]
         public string strDescription
         {
             get
             {
                 if (string.IsNullOrEmpty(_description))
                     if (tblMFQAProperty != null)
                         return tblMFQAProperty.strDescription;
                     else
                         return null;
                 else
                     return _description;
             }
             set
             {
                 _description = value;
             }
         }*/

        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
        //public tblMFQAProperty tblMFQAProperty { get; set; }
    }
}
