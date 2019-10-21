CREATE VIEW vyuMFGetTaskQty
AS
SELECT T.intOrderDetailId
	,SUM(dbo.fnMFConvertQuantityToTargetItemUOM(T.intItemUOMId , OD.intItemUOMId, T.dblPickQty)) AS dblTaskQty from tblMFTask T JOIN tblMFOrderDetail OD on OD.intOrderDetailId=T.intOrderDetailId
	Group by T.intOrderDetailId
