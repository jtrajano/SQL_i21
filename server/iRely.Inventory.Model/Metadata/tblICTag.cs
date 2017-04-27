using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;
using System.ComponentModel.DataAnnotations.Schema;

namespace iRely.Inventory.Model
{
    public class tblICTag : BaseEntity
    {
        public int intTagId { get; set; }
        public string strTagNumber { get; set; }
        public string strDescription { get; set; }
        public string strMessage { get; set; }
        public bool ysnHazMat { get; set; }
        public string strType { get; set; }

        private int? _intType;

        [NotMapped]
        public int? intType
        {
            get
            {
                switch(strType)
                {
                    case "Medication Tag":
                        return 1;
                    case "Ingredient Tag":
                        return 2;
                    case "Hazmat Message":
                        return 3;
                    default:
                        return null;
                }
            }

            set
            {
                this._intType = value;
            }
        }
    }
}
