﻿CREATE PROCEDURE [dbo].[uspIPProcessSAPItems]
AS
BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @strItemNo nvarchar(50)
Declare @strItemType nvarchar(50)
Declare @strSKUItemNo nvarchar(50)
Declare @intCommodityId int
Declare @intCategoryId int
Declare @strCommodity nvarchar(50)
Declare @strItemPart nvarchar(8)
Declare @intItemId int
Declare @strStockUOM nvarchar(50)
Declare @ErrMsg nvarchar(max)
Declare @ysnDeleted bit
Declare @intStageItemId int
Declare @intNewStageItemId int

Select TOP 1 @intStageItemId=intStageItemId,@strItemNo=strItemNo,@strItemType=strItemType,@strSKUItemNo=strSKUItemNo,@strStockUOM=strStockUOM,@ysnDeleted=ISNULL(ysnDeleted,0) From tblIPItemStage

Select @intCategoryId=intCategoryId From tblICCategory Where strCategoryCode=@strItemType

If @strItemType='ZMPN' --Contract Item
Select TOP 1 @intItemId=intItemId From tblICItem Where strItemNo=@strSKUItemNo
Else
Select TOP 1 @intItemId=intItemId From tblICItem Where strItemNo=@strItemNo

If @strItemType='ZCOM'
Begin
	If ISNULL(@intCategoryId,0)=0
		RaisError('Category not found.',16,1)

	Select @strItemPart=SUBSTRING(@strItemNo,1,5)
	If @strItemPart='49600'
		Select @strCommodity='Coffee'

	If @strItemPart='49100'
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
	If Not Exists (Select 1 From tblICItemContract Where intItemId=@intItemId AND strContractItemName=@strItemNo)
	Begin
		Insert Into tblICItemContract(intItemId,strContractItemName,intItemLocationId)
		Select @intItemId,@strItemNo,intItemLocationId 
		From tblICItemLocation Where intItemId=@intItemId

		GOTO MOVE_TO_ARCHIVE
	End
End
Else
Begin --Inventory Item
If ISNULL(@intItemId,0)=0 --Create
Begin
	Insert Into tblICItem(strItemNo,strDescription,strShortName,strType,strLotTracking,strInventoryTracking,intCategoryId,intCommodityId,strStatus,intLifeTime)
	Select strItemNo,strDescription,LEFT(strDescription,50),'Inventory','Yes - Manual','Lot Level',@intCategoryId,@intCommodityId,'Active',0
	From tblIPItemStage Where strItemNo=@strItemNo AND intStageItemId=@intStageItemId

	Select @intItemId=SCOPE_IDENTITY()

	Insert Into tblICItemUOM(intItemId,intUnitMeasureId,dblUnitQty,ysnStockUnit,ysnAllowPurchase,ysnAllowSale)
	Select @intItemId,um.intUnitMeasureId,iu.dblNumerator/iu.dblDenominator,CASE When iu.strUOM=@strStockUOM THEN 1 ELSE 0 End,1,1  
	From tblIPItemUOMStage iu 
	Join tblIPSAPUOM su on iu.strUOM=su.strSAPUOM 
	Join tblICUnitMeasure um on su.stri21UOM=um.strUnitMeasure
	Where strItemNo=@strItemNo AND iu.intStageItemId=@intStageItemId

	Insert Into tblICItemLocation(intItemId,intLocationId,intCostingMethod,intAllowNegativeInventory)
	Select @intItemId,cl.intCompanyLocationId,1,3
	From tblSMCompanyLocation cl
End
Else
Begin --Update
	Update i  Set i.strDescription=si.strDescription,i.strShortName=LEFT(si.strDescription,50) 
	From tblICItem i Join tblIPItemStage si on i.strItemNo=si.strItemNo 
	Where intItemId=@intItemId AND si.intStageItemId=@intStageItemId
End
End

	MOVE_TO_ARCHIVE:

	--Move to Archive
	Insert into tblIPItemArchive(strItemNo,dtmCreated,strCreatedUserName,dtmLastModified,strLastModifiedUserName,ysnDeleted,strItemType,strStockUOM,strSKUItemNo,strDescription)
	Select strItemNo,dtmCreated,strCreatedUserName,dtmLastModified,strLastModifiedUserName,ysnDeleted,strItemType,strStockUOM,strSKUItemNo,strShortName
	From tblIPItemStage Where intStageItemId=@intStageItemId

	Select @intNewStageItemId=SCOPE_IDENTITY()

	Insert Into tblIPItemUOMArchive(intStageItemId,strItemNo,strUOM,dblNumerator,dblDenominator)
	Select @intNewStageItemId,@strItemNo,strUOM,dblNumerator,dblDenominator
	From tblIPItemUOMStage Where intStageItemId=@intStageItemId

	Delete From tblIPItemStage Where intStageItemId=@intStageItemId
	Delete From tblIPItemUOMStage Where intStageItemId=@intStageItemId

	Commit Tran

END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	--Move to Error
	Insert into tblIPItemError(strItemNo,dtmCreated,strCreatedUserName,dtmLastModified,strLastModifiedUserName,ysnDeleted,strItemType,strStockUOM,strSKUItemNo,strDescription,strErrorMessage,strImportStatus)
	Select strItemNo,dtmCreated,strCreatedUserName,dtmLastModified,strLastModifiedUserName,ysnDeleted,strItemType,strStockUOM,strSKUItemNo,strShortName,@ErrMsg,'Failed'
	From tblIPItemStage Where intStageItemId=@intStageItemId

	Select @intNewStageItemId=SCOPE_IDENTITY()

	Insert Into tblIPItemUOMError(intStageItemId,strItemNo,strUOM,dblNumerator,dblDenominator)
	Select @intNewStageItemId,@strItemNo,strUOM,dblNumerator,dblDenominator
	From tblIPItemUOMStage Where intStageItemId=@intStageItemId

	Delete From tblIPItemStage Where intStageItemId=@intStageItemId
	Delete From tblIPItemUOMStage Where intStageItemId=@intStageItemId

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH