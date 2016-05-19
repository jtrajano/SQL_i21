CREATE PROCEDURE [dbo].[uspMFGetSalesOrderPickListAvailableLots]
	@intItemId int,
	@intLocationId int,
	@intItemUOMId int,
	@strLotTracking nvarchar(50)
AS

Declare @strUOM nvarchar(50)

Select @strUOM=um.strUnitMeasure From tblICItemUOM iu Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
Where iu.intItemUOMId=@intItemUOMId

If @strLotTracking <> 'No'
Select * From
	(SELECT L.intLotId
		,L.strLotNumber
		,L.intItemId
		,I.strItemNo
		,I.strDescription
		,dbo.fnMFConvertQuantityToTargetItemUOM(L.intItemUOMId,@intItemUOMId,L.dblQty) - 
		(Select ISNULL(SUM(ISNULL(dbo.fnMFConvertQuantityToTargetItemUOM(sr.intItemUOMId,@intItemUOMId,sr.dblQty),0)),0) 
		From tblICStockReservation sr Where sr.intLotId=L.intLotId AND ISNULL(sr.ysnPosted,0)=0) AS dblAvailableQty
		,@intItemUOMId AS intItemUOMId
		,@strUOM AS strUOM
		,L.intLocationId
		,L.intSubLocationId
		,L.intStorageLocationId
		,SL.strName AS strStorageLocationName
		,CSL.strSubLocationName
		,L.dtmDateCreated
		,L.intParentLotId
	FROM tblICLot L
	JOIN tblICLotStatus LS ON L.intLotStatusId = LS.intLotStatusId
	JOIN tblICItem I ON L.intItemId=I.intItemId
	JOIN tblICStorageLocation SL ON L.intStorageLocationId=SL.intStorageLocationId
	JOIN tblSMCompanyLocationSubLocation CSL ON L.intSubLocationId=CSL.intCompanyLocationSubLocationId
	WHERE L.intItemId = @intItemId
		AND L.intLocationId = @intLocationId
		AND LS.strPrimaryStatus IN (
			'Active'
			)
		AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
		AND L.dblQty  >= .01
	) t Where t.dblAvailableQty >= .01
	ORDER BY t.dtmDateCreated
Else
	Select 0,sd.intItemId,i.strItemNo,i.strDescription,dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,@intItemUOMId,sd.dblAvailableQty) AS dblAvailableQty,
	@intItemUOMId AS intItemUOMId,@strUOM AS strUOM,
	sd.intLocationId,sd.intSubLocationId,sd.intStorageLocationId,sl.strName AS strStorageLocationName,csl.strSubLocationName
	From vyuMFGetItemStockDetail sd
	JOIN tblICItem i ON sd.intItemId=i.intItemId
	JOIN tblICStorageLocation sl ON sd.intStorageLocationId=sl.intStorageLocationId
	JOIN tblSMCompanyLocationSubLocation csl ON sd.intSubLocationId=csl.intCompanyLocationSubLocationId	 
	Where sd.intItemId=@intItemId AND sd.dblAvailableQty > .01 AND sd.intLocationId=@intLocationId AND ISNULL(sd.ysnStockUnit,0)=1 ORDER BY sd.intItemStockUOMId
