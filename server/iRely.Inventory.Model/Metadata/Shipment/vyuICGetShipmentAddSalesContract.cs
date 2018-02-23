using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetShipmentAddSalesContract
    {
        //public int intKey { get; set; }
        public string strOrderType { get; set; }
        public int? intContractSeq { get; set; }
        public string strSourceType { get; set; }
        public int? intLocationId { get; set; }
        public string strShipFromLocation { get; set; }
        public int? intEntityCustomerId { get; set; }
        public string strCustomerNumber { get; set; }
        public string strCustomerName { get; set; }
        public int? intLineNo { get; set; }
        public int? intOrderId { get; set; }
        public string strOrderNumber { get; set; }
        public int? intSourceId { get; set; }
        public int? strSourceNumber { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strBundleType { get; set; }
        public string strLotTracking { get; set; }
        public int? intCommodityId { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intOrderUOMId { get; set; }
        public string strOrderUOM { get; set; }
        public decimal? dblOrderUOMConvFactor { get; set; }
        public int? intItemUOMId { get; set; }
        public string strItemUOM { get; set; }
        public decimal? dblItemUOMConv { get; set; }
        public int? intWeightUOMId { get; set; }
        public string strWeightUOM { get; set; }
        public decimal? dblWeightItemUOMConv { get; set; }
        public decimal? dblQtyOrdered { get; set; }
        public decimal? dblQtyAllocated { get; set; }
        public decimal? dblQtyShipped { get; set; }
        public decimal? dblUnitPrice { get; set; }
        public decimal? dblDiscount { get; set; }
        public decimal? dblTotal { get; set; }
        public decimal? dblQtyToShip { get; set; }
        public decimal? dblPrice { get; set; }
        public decimal? dblLineTotal { get; set; }
        public int? intGradeId { get; set; }
        public int? strGrade { get; set; }
        public int? intDestinationGradeId { get; set; }
        public int? intDestinationWeightId { get; set; }
        public string strDestinationWeights { get; set; }
        public string strDestinationGrades { get; set; }
        public int? intCurrencyId { get; set; }
        public int? intForexRateTypeId { get; set; }
        public string strForexRateType { get; set; }
        public decimal? dblForexRate { get; set; }
        public int? intFreightTermId { get; set; }
        public string strFreightTerm { get; set; }
    }
}
