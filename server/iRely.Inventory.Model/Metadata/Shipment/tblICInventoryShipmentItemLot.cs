using iRely.Common;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICInventoryShipmentItemLot : BaseEntity
    {

        public int intInventoryShipmentItemLotId { get; set; }
        public int intInventoryShipmentItemId { get; set; }
        public int? intLotId { get; set; }
        public decimal? dblQuantityShipped { get; set; }
        public decimal? dblGrossWeight { get; set; }
        public decimal? dblTareWeight { get; set; }
        public decimal? dblWeightPerQty { get; set; }
        public string strWarehouseCargoNumber { get; set; }
        public int? intSort { get; set; }

        //private string _lotId;
        //[NotMapped]
        //public string strLotId
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_lotId))
        //            if (tblICLot != null)
        //                return tblICLot.strLotNumber;
        //            else
        //                return null;
        //        else
        //            return _lotId;
        //    }
        //    set
        //    {
        //        _lotId = value;
        //    }
        //}
        //private string _storageLoc;
        //[NotMapped]
        //public string strStorageLocation
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_storageLoc))
        //            if (tblICLot != null)
        //                return tblICLot.strStorageLocation;
        //            else
        //                return null;
        //        else
        //            return _storageLoc;
        //    }
        //    set
        //    {
        //        _storageLoc = value;
        //    }
        //}
        //private decimal _lotQty;
        //[NotMapped]
        //public decimal dblLotQty
        //{
        //    get
        //    {
        //        if (tblICLot != null)
        //            return tblICLot.dblQty ?? 0;
        //        else
        //            return _lotQty;
        //    }
        //    set
        //    {
        //        _lotQty = value;
        //    }
        //}
        //private decimal _lotUOMConv;
        //[NotMapped]
        //public decimal dblLotItemUOMConv
        //{
        //    get
        //    {
        //        if (tblICLot != null)
        //            return tblICLot.dblItemUOMConv ?? 0;
        //        else
        //            return _lotUOMConv;
        //    }
        //    set
        //    {
        //        _lotUOMConv = value;
        //    }
        //}
        //private string _uom;
        //[NotMapped]
        //public string strUnitMeasure
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_uom))
        //            if (tblICLot != null)
        //                return tblICLot.strItemUOM;
        //            else
        //                return null;
        //        else
        //            return _uom;
        //    }
        //    set
        //    {
        //        _uom = value;
        //    }
        //}
        ////private decimal? _itemUOMConv;
        ////[NotMapped]
        ////public decimal? dblItemUOMConv
        ////{
        ////    get
        ////    {
        ////        if (tblICInventoryShipmentItem != null)
        ////            return tblICLot.dblItemUOMConv;
        ////        else
        ////            return _itemUOMConv;
        ////    }
        ////    set
        ////    {
        ////        _itemUOMConv = value;
        ////    }
        ////}
        //private string _weightUOM;
        //[NotMapped]
        //public string strWeightUOM
        //{
        //    get
        //    {
        //        if (string.IsNullOrEmpty(_weightUOM))
        //            if (tblICLot != null)
        //                return tblICLot.strWeightUOM;
        //            else
        //                return null;
        //        else
        //            return _weightUOM;
        //    }
        //    set
        //    {
        //        _weightUOM = value;
        //    }
        //}
        //private decimal? _weightConv;
        //[NotMapped]
        //public decimal? dblWeightItemUOMConv
        //{
        //    get
        //    {
        //        if (tblICLot != null)
        //            return tblICLot.dblWeightUOMConv;
        //        else
        //            return _weightConv;
        //    }
        //    set
        //    {
        //        _weightConv = value;
        //    }
        //}
        //private decimal _availableQty;
        //[NotMapped]
        //public decimal dblAvailableQty
        //{
        //    get
        //    {
        //        if (tblICLot != null)
        //            return tblICLot.dblAvailableQty ?? 0;
        //        else
        //            return _availableQty;
        //    }
        //    set
        //    {
        //        _availableQty = value;
        //    }
        //}

        public tblICInventoryShipmentItem tblICInventoryShipmentItem { get; set; }
        public tblICLot tblICLot { get; set; }

    }
}
