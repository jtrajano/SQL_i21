﻿CREATE PROCEDURE [dbo].[uspIPProcessSAPItems]
@strSessionId NVARCHAR(50)=''
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @intMinItem INT
Declare @strItemNo nvarchar(50)
Declare @strItemType nvarchar(50)
Declare @strSKUItemNo nvarchar(50)
Declare @intCommodityId int
Declare @intCategoryId int
Declare @strCommodity nvarchar(50)
Declare @intItemId int
Declare @strStockUOM nvarchar(50)
Declare @ErrMsg nvarchar(max)
Declare @ysnDeleted bit
Declare @intStageItemId int
Declare @intNewStageItemId int
Declare @strDescription NVARCHAR(250)
Declare @strJson NVARCHAR(Max)
Declare @dtmDate DateTime
Declare @intUserId Int
Declare @strUserName NVARCHAR(100)
Declare @strFinalErrMsg NVARCHAR(MAX)=''

If ISNULL(@strSessionId,'')=''
	Select @intMinItem=MIN(intStageItemId) From tblIPItemStage
Else
	Select @intMinItem=MIN(intStageItemId) From tblIPItemStage Where strSessionId=@strSessionId

While(@intMinItem is not null)
Begin
Begin Try

Set @intItemId=NULL
Set @intCategoryId=NULL
Set @intCommodityId=NULL
Set @strCommodity=NULL
Set @strItemNo=NULL
Set @strItemType=NULL
Set @strSKUItemNo=NULL
Set @strStockUOM=NULL
Set @strDescription=NULL
Set @ysnDeleted=0

Select @intStageItemId=intStageItemId,@strItemNo=strItemNo,@strItemType=strItemType,@strSKUItemNo=strSKUItemNo,
@strStockUOM=strStockUOM,@ysnDeleted=ISNULL(ysnDeleted,0),@strDescription=strDescription From tblIPItemStage Where intStageItemId=@intMinItem

Select @strItemNo AS strInfo1,@strItemType AS strInfo2

Select @intCategoryId=intCategoryId From tblICCategory Where strCategoryCode=@strItemType

If @strItemType='ZMPN' --Contract Item
Select TOP 1 @intItemId=intItemId From tblICItem Where strItemNo=@strSKUItemNo
Else
Select TOP 1 @intItemId=intItemId From tblICItem Where strItemNo=@strItemNo

If @strItemType='ZCOM'
Begin
	If ISNULL(@intCategoryId,0)=0
		RaisError('Category not found.',16,1)

	If Exists (Select 1 where RIGHT(@strItemNo,8) like '496%')
		Select @strCommodity='Coffee'

	If Exists (Select 1 where RIGHT(@strItemNo,8) like '491%')
		Select @strCommodity='Tea'

	Select @intCommodityId=intCommodityId From tblICCommodity Where strCommodityCode=@strCommodity

	If ISNULL(@intCommodityId,0)=0
		RaisError('Commodity not found.',16,1)
End

Begin Tran

If @ysnDeleted=1 AND @strItemType<>'ZMPN'
Begin
	Update tblICItem Set strStatus='Discontinued' Where intItemId=@intItemId

	GOTO MOVE_TO_ARCHIVE
End

If @strItemType='ZMPN' --Contract Item
Begin
	If ISNULL(@intItemId,0)=0
		Begin
			Set @ErrMsg='ZCOM item ' + @strSKUItemNo + ' not found.'
			RaisError(@ErrMsg,16,1)
		End

	If @ysnDeleted=1
		Delete From tblICItemContract Where intItemId=@intItemId AND strContractItemNo=@strItemNo
	Else
	Begin
		If Not Exists (Select 1 From tblICItemContract Where intItemId=@intItemId AND strContractItemNo=@strItemNo) --Add
		Begin
			Insert Into tblICItemContract(intItemId,strContractItemNo,strContractItemName,intItemLocationId)
			Select @intItemId,@strItemNo,@strDescription,intItemLocationId 
			From tblICItemLocation Where intItemId=@intItemId
		End
		Else
		Begin --Update
			Update tblICItemContract Set strContractItemName=@strDescription Where intItemId=@intItemId AND strContractItemNo=@strItemNo
		End
	End
	GOTO MOVE_TO_ARCHIVE
End
Else
Begin --Inventory Item
If ISNULL(@intItemId,0)=0 --Create
Begin
	If Not Exists (Select 1 From tblIPItemUOMStage Where intStageItemId=@intStageItemId)
	RaisError('UOM is required.',16,1)

	Insert Into tblICItem(strItemNo,strDescription,strShortName,strType,strLotTracking,strInventoryTracking,intCategoryId,intCommodityId,strStatus,intLifeTime)
	Select strItemNo,strDescription,LEFT(strDescription,50),'Inventory','Yes - Manual/Serial Number','Lot Level',@intCategoryId,@intCommodityId,'Active',0
	From tblIPItemStage Where strItemNo=@strItemNo AND intStageItemId=@intStageItemId

	Select @intItemId=SCOPE_IDENTITY()

	Insert Into tblICItemUOM(intItemId,intUnitMeasureId,dblUnitQty,ysnStockUnit,ysnAllowPurchase,ysnAllowSale)
	Select @intItemId,um.intUnitMeasureId,iu.dblNumerator/iu.dblDenominator,CASE When iu.strUOM=@strStockUOM THEN 1 ELSE 0 End,1,1  
	From tblIPItemUOMStage iu 
	Join tblIPSAPUOM su on iu.strUOM=su.strSAPUOM 
	Join tblICUnitMeasure um on su.stri21UOM=um.strSymbol
	Where strItemNo=@strItemNo AND iu.intStageItemId=@intStageItemId

	--if stock uom is KG then add TO as one of the uom
	If (Select UPPER(strSymbol) From tblICUnitMeasure Where UPPER(strUnitMeasure) = UPPER(dbo.fnIPConvertSAPUOMToi21(@strStockUOM)))='KG'
	Begin
		If Not Exists (Select 1 From tblICItemUOM iu Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId Where iu.intItemId=@intItemId AND um.strSymbol='TO')
			Insert Into tblICItemUOM(intItemId,intUnitMeasureId,dblUnitQty,ysnStockUnit,ysnAllowPurchase,ysnAllowSale)
			Select TOP 1 @intItemId,intUnitMeasureId,1000,0,1,1 From tblICUnitMeasure Where strSymbol='TO'

		--Add 70/69/60/50/65 Kg Bags for coffee
		If (Select UPPER(strCommodityCode) From tblICCommodity Where intCommodityId=@intCommodityId)='COFFEE'
			Insert Into tblICItemUOM(intItemId,intUnitMeasureId,dblUnitQty,ysnStockUnit,ysnAllowPurchase,ysnAllowSale)
			Select @intItemId,intUnitMeasureId,SUBSTRING(strUnitMeasure,1,2),0,1,1 From tblICUnitMeasure 
			Where  UPPER(strUnitMeasure) like '%KG BAG%' AND ISNUMERIC(SUBSTRING(strUnitMeasure,1,2))=1
	End

	Insert Into tblICItemLocation(intItemId,intLocationId,intCostingMethod,intAllowNegativeInventory)
	Select @intItemId,cl.intCompanyLocationId,1,3
	From tblSMCompanyLocation cl

	Insert Into tblICItemSubLocation(intItemLocationId,intSubLocationId)
	Select il.intItemLocationId,sl.intCompanyLocationSubLocationId
	From tblIPItemSubLocationStage s join tblSMCompanyLocationSubLocation sl on s.strSubLocation=sl.strSubLocationName 
	Join tblICItemLocation il on sl.intCompanyLocationId=il.intLocationId
	where s.intStageItemId=@intStageItemId AND il.intItemId=@intItemId

	--Add Audit Trail Record
	Set @strJson='{"action":"Created","change":"Created - Record: ' + CONVERT(VARCHAR,@intItemId) + '","keyValue":' + CONVERT(VARCHAR,@intItemId) + ',"iconCls":"small-new-plus","leaf":true}'
	
	Select @dtmDate=DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), dtmCreated) From tblIPItemStage Where intStageItemId=@intStageItemId
	If @dtmDate is null
		Set @dtmDate =  GETUTCDATE()

	Select @strUserName=strCreatedUserName From tblIPItemStage Where intStageItemId=@intStageItemId
	Select @intUserId=e.intEntityId From tblEMEntity e Join tblEMEntityType et on e.intEntityId=et.intEntityId  Where e.strExternalERPId=@strUserName AND et.strType='User'

	Insert Into tblSMAuditLog(strActionType,strTransactionType,strRecordNo,strDescription,strRoute,strJsonData,dtmDate,intEntityId,intConcurrencyId)
	Values('Created','Inventory.view.Item',@intItemId,'','',@strJson,@dtmDate,@intUserId,1)
End
Else
Begin --Update
	Update i  Set i.strDescription=si.strDescription,i.strShortName=LEFT(si.strDescription,50) 
	From tblICItem i Join tblIPItemStage si on i.strItemNo=si.strItemNo 
	Where intItemId=@intItemId AND si.intStageItemId=@intStageItemId AND si.strDescription <> '/'

	Insert Into tblICItemUOM(intItemId,intUnitMeasureId,dblUnitQty,ysnStockUnit,ysnAllowPurchase,ysnAllowSale)
	Select @intItemId,um.intUnitMeasureId,iu.dblNumerator/iu.dblDenominator,CASE When iu.strUOM=@strStockUOM THEN 1 ELSE 0 End,1,1  
	From tblIPItemUOMStage iu 
	Join tblIPSAPUOM su on iu.strUOM=su.strSAPUOM 
	Join tblICUnitMeasure um on su.stri21UOM=um.strSymbol
	Where strItemNo=@strItemNo AND iu.intStageItemId=@intStageItemId AND 
	um.intUnitMeasureId NOT IN (Select intUnitMeasureId From tblICItemUOM Where intItemId=@intItemId)

	Update iu Set iu.dblUnitQty=st.dblNumerator/st.dblDenominator 
	From tblICItemUOM iu 
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblIPSAPUOM su on um.strSymbol=su.stri21UOM
	Join tblIPItemUOMStage st on st.strUOM=su.strSAPUOM
	Where intItemId=@intItemId AND st.intStageItemId=@intStageItemId

	--add new sublocations
	Insert Into tblICItemSubLocation(intItemLocationId,intSubLocationId)
	Select il.intItemLocationId,sl.intCompanyLocationSubLocationId
	From tblIPItemSubLocationStage s join tblSMCompanyLocationSubLocation sl on s.strSubLocation=sl.strSubLocationName 
	Join tblICItemLocation il on sl.intCompanyLocationId=il.intLocationId AND il.intItemId=@intItemId
	where s.intStageItemId=@intStageItemId AND 
	sl.intCompanyLocationSubLocationId NOT IN (Select isl.intSubLocationId From tblICItemSubLocation isl 
	Join tblICItemLocation il on isl.intItemLocationId=il.intItemLocationId Where il.intItemId=@intItemId)

	--Delete the SubLocation if it is marked for deletion
	Delete From tblICItemSubLocation
	Where intItemLocationId in (Select intItemLocationId From tblICItemLocation Where intItemId=@intItemId) AND 
	intSubLocationId IN (Select sl.intCompanyLocationSubLocationId 
	From tblSMCompanyLocationSubLocation sl Join tblIPItemSubLocationStage s on sl.strSubLocationName=s.strSubLocation 
	Where s.intStageItemId=@intStageItemId AND ISNULL(s.ysnDeleted,0)=1)
End
End

	MOVE_TO_ARCHIVE:

	--Move to Archive
	Insert into tblIPItemArchive(strItemNo,dtmCreated,strCreatedUserName,dtmLastModified,strLastModifiedUserName,ysnDeleted,strItemType,strStockUOM,strSKUItemNo,strDescription,strSessionId)
	Select strItemNo,dtmCreated,strCreatedUserName,dtmLastModified,strLastModifiedUserName,ysnDeleted,strItemType,strStockUOM,strSKUItemNo,strDescription,strSessionId
	From tblIPItemStage Where intStageItemId=@intStageItemId

	Select @intNewStageItemId=SCOPE_IDENTITY()

	Insert Into tblIPItemUOMArchive(intStageItemId,strItemNo,strUOM,dblNumerator,dblDenominator)
	Select @intNewStageItemId,@strItemNo,strUOM,dblNumerator,dblDenominator
	From tblIPItemUOMStage Where intStageItemId=@intStageItemId

	Insert Into tblIPItemSubLocationArchive(intStageItemId,strItemNo,strSubLocation,ysnDeleted)
	Select @intNewStageItemId,@strItemNo,strSubLocation,ysnDeleted
	From tblIPItemSubLocationStage Where intStageItemId=@intStageItemId

	Delete From tblIPItemStage Where intStageItemId=@intStageItemId

	Commit Tran

END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()
	SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

	--Move to Error
	Insert into tblIPItemError(strItemNo,dtmCreated,strCreatedUserName,dtmLastModified,strLastModifiedUserName,ysnDeleted,strItemType,strStockUOM,strSKUItemNo,strDescription,strErrorMessage,strImportStatus,strSessionId)
	Select strItemNo,dtmCreated,strCreatedUserName,dtmLastModified,strLastModifiedUserName,ysnDeleted,strItemType,strStockUOM,strSKUItemNo,strDescription,@ErrMsg,'Failed',strSessionId
	From tblIPItemStage Where intStageItemId=@intStageItemId

	Select @intNewStageItemId=SCOPE_IDENTITY()

	Insert Into tblIPItemUOMError(intStageItemId,strItemNo,strUOM,dblNumerator,dblDenominator)
	Select @intNewStageItemId,@strItemNo,strUOM,dblNumerator,dblDenominator
	From tblIPItemUOMStage Where intStageItemId=@intStageItemId

	Insert Into tblIPItemSubLocationError(intStageItemId,strItemNo,strSubLocation,ysnDeleted)
	Select @intNewStageItemId,@strItemNo,strSubLocation,ysnDeleted
	From tblIPItemSubLocationStage Where intStageItemId=@intStageItemId

	Delete From tblIPItemStage Where intStageItemId=@intStageItemId
END CATCH

	If ISNULL(@strSessionId,'')=''
		Select @intMinItem=MIN(intStageItemId) From tblIPItemStage Where intStageItemId>@intMinItem
	Else
		Select @intMinItem=MIN(intStageItemId) From tblIPItemStage Where intStageItemId>@intMinItem AND strSessionId=@strSessionId
End

If ISNULL(@strFinalErrMsg,'')<>'' RaisError(@strFinalErrMsg,16,1)

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH