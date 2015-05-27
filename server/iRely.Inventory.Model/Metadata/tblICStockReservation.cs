using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICStockReservation : BaseEntity
    {
        public int intStockReservationId { get; set; }
        public int intItemId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intItemUOMId { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intTransactionId { get; set; }
        public string strTransactionId { get; set; }
        public int? intSort { get; set; }
    }
}
