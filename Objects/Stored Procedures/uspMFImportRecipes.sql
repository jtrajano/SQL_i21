CREATE PROCEDURE [dbo].[uspMFImportRecipes]
	@strSessionId NVARCHAR(50) = '',
	@strImportType NVARCHAR(50),
	@intUserId int=1
AS

Declare @intMinId int
Declare @intItemId int
Declare @intVersionNo int
Declare @strRecipeName NVARCHAR(250)
Declare @strItemNo NVARCHAR(50)
Declare @intLocationId int
Declare @strLocationName NVARCHAR(50)
Declare @intRecipeId int
Declare @intRecipeDetailItemId int
Declare @strRecipeDetailItemNo nvarchar(50)
Declare @intRecipeItemId int
Declare @intRecipeTypeId int
Declare @intSubstituteItemId int
Declare @strSubstituteItemNo nvarchar(50)
Declare @intRecipeSubstituteItemId int
Declare @intCustomerId int
Declare @strCustomer nvarchar(250)
Declare @intFarmFieldId int
Declare @strFarmNumber nvarchar(250)
Declare @intInputItemUOMId int
Declare @intSubstituteItemUOMId int
Declare @dblRecipeDetailCalculatedQty numeric(18,6)
Declare @dblRecipeDetailUpperTolerance numeric(18,6)
Declare @dblRecipeDetailLowerTolerance numeric(18,6)

--Recipe
If @strImportType='Recipe'
Begin
	--Recipe Name is required
	Update tblMFRecipeStage Set strMessage='Recipe Name is required' 
	Where ISNULL(strRecipeName,'')='' AND ISNULL(strItemNo,'')='' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	
	
	--Invalid Item
	Update tblMFRecipeStage Set strMessage='Invalid Item' 
	Where strItemNo not in (Select strItemNo From tblICItem) AND ISNULL(strItemNo,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Qty
	Update tblMFRecipeStage Set strMessage='Quantity should be greater than 0' 
	Where (ISNUMERIC(ISNULL([strQuantity],0))=0 OR ISNULL(CAST([strQuantity] as numeric(18,6)),0)<=0) 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	

	--UOM is required
	Update tblMFRecipeStage Set strMessage='UOM is required' 
	Where ISNULL(strUOM,'')='' AND ISNULL(strItemNo,'')='' AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	

	--Invalid UOM
	Update tblMFRecipeStage Set strMessage='Invalid UOM' 
	Where strUOM not in (Select strUnitMeasure From tblICUnitMeasure) AND ISNULL(strUOM,'')<>'' AND ISNULL(strItemNo,'')='' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Location is required
	Update tblMFRecipeStage Set strMessage='Location is required' 
	Where ISNULL(strLocationName,'')='' AND ISNULL(strItemNo,'')<>'' AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	

	--Invalid Location
	Update tblMFRecipeStage Set strMessage='Invalid Location' 
	Where strLocationName not in (Select strLocationName From tblSMCompanyLocation) AND ISNULL(strLocationName,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Version
	Update tblMFRecipeStage Set strMessage='Invalid Version No'
	Where (ISNUMERIC(ISNULL([strVersionNo],0))=0 OR CHARINDEX('.',ISNULL([strVersionNo],0))>0 OR [strVersionNo]='0')
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	

	--Invalid Recipe Type
	Update tblMFRecipeStage Set strMessage='Invalid Recipe Type' 
	Where strRecipeType not in (Select strName From tblMFRecipeType) AND ISNULL(strRecipeType,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Manufacturing Process
	Update tblMFRecipeStage Set strMessage='Invalid Manufacturing Process' 
	Where strManufacturingProcess not in (Select strProcessName From tblMFManufacturingProcess) AND ISNULL(strManufacturingProcess,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Customer
	Update tblMFRecipeStage Set strMessage='Invalid Customer' 
	Where strCustomer not in (Select strCustomer From vyuARCustomer) AND ISNULL(strCustomer,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Farm
	Update tblMFRecipeStage Set strMessage='Invalid Farm' 
	Where strFarm not in (Select strFarm From tblEMEntityFarm) AND ISNULL(strFarm,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Cost Type
	Update tblMFRecipeStage Set strMessage='Invalid Cost Type' 
	Where strCostType not in (Select strName From tblMFCostType) AND ISNULL(strCostType,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Margin By
	Update tblMFRecipeStage Set strMessage='Invalid Margin By' 
	Where strMarginBy not in (Select strName From tblMFMarginBy) AND ISNULL(strMarginBy,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Margin
	Update tblMFRecipeStage Set strMessage='Invalid Margin / Margin cannot be negative' 
	Where (ISNUMERIC(ISNULL([strMargin],0))=0 OR ISNULL(CAST([strMargin] as numeric(18,6)),0)<0) 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Discount
	Update tblMFRecipeStage Set strMessage='Invalid Discount / Discount cannot be negative' 
	Where (ISNUMERIC(ISNULL([strDiscount],0))=0 OR ISNULL(CAST([strDiscount] as numeric(18,6)),0)<0) 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid One Line Print
	Update tblMFRecipeStage Set strMessage='Invalid One Line Print' 
	Where strOneLinePrint not in (Select strName From tblMFOneLinePrint) AND ISNULL(strOneLinePrint,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Set Default Values
	--Recipe Name
	Update tblMFRecipeStage Set strRecipeName=strItemNo
	Where ISNULL(strRecipeName,'')='' AND ISNULL(strItemNo,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	

	--Recipe Type
	Update tblMFRecipeStage Set strRecipeType='By Quantity'
	Where ISNULL(strRecipeType,'')='' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	

	Select @intMinId=MIN(intRecipeStageId) From tblMFRecipeStage Where strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	

	--Insert/Update recipe
	While (@intMinId is not null)
	Begin
		Set @intItemId=NULL
		Set @intVersionNo=NULL
		Set @strRecipeName=''
		Set @intLocationId=null
		Set @strLocationName=''
		Set @intRecipeId=null
		Set @strCustomer=null
		Set @intCustomerId=null
		Set @strFarmNumber=null
		Set @intFarmFieldId=null

		--Margin By
		Update tblMFRecipeStage Set strMarginBy='Amount'
		Where ISNULL(strMarginBy,'')='' AND ISNULL(CAST([strMargin] as numeric(18,6)),0)>0
		AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	AND intRecipeStageId=@intMinId	

		Select @strRecipeName=strRecipeName,@strItemNo=strItemNo,@intVersionNo=[strVersionNo],@strLocationName=strLocationName,@strCustomer=strCustomer,@strFarmNumber=strFarm 
		From tblMFRecipeStage Where intRecipeStageId=@intMinId
		Select @intItemId=intItemId From tblICItem Where strItemNo=@strItemNo
		Select @intLocationId=intCompanyLocationId From tblSMCompanyLocation Where strLocationName=@strLocationName
		Select TOP 1 @intCustomerId=intEntityId From vyuARCustomer Where strName=@strCustomer
		Select TOP 1 @intFarmFieldId=intFarmFieldId From tblEMEntityFarm Where intEntityId=@intCustomerId AND strFarmNumber=@strFarmNumber

		If ISNULL(@strFarmNumber,'')<>'' AND @intFarmFieldId is null
		Begin
			Update tblMFRecipeStage Set strMessage='Farm does not belong to customer.' Where intRecipeStageId=@intMinId
			GOTO NEXT_RECIPE			
		End

		If ISNULL(@strItemNo,'')<>'' --Production Recipe
			Select TOP 1 @intRecipeId=intRecipeId From tblMFRecipe Where intItemId=@intItemId AND intVersionNo=@intVersionNo AND intLocationId=@intLocationId 
		Else --Virtual Recipe
			Select TOP 1 @intRecipeId=intRecipeId From tblMFRecipe Where strName=@strRecipeName

		If @intRecipeId is null --insert
		Begin
			Insert Into tblMFRecipe(strName,intItemId,dblQuantity,intItemUOMId,intLocationId,intVersionNo,intRecipeTypeId,intManufacturingProcessId,ysnActive,
									intCustomerId,intFarmId,intCostTypeId,intMarginById,dblMargin,dblDiscount,intMarginUOMId,intOneLinePrintId,
									intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified)
			Select TOP 1 s.strRecipeName,i.intItemId,s.[strQuantity],iu.intItemUOMId,cl.intCompanyLocationId,s.[strVersionNo],rt.intRecipeTypeId,mp.intManufacturingProcessId,0,
									@intCustomerId,@intFarmFieldId,ct.intCostTypeId,m.intMarginById,s.[strMargin],s.[strDiscount],um.intUnitMeasureId,p.intOneLinePrintId,
									@intUserId,GETDATE(),@intUserId,GETDATE()
			From tblMFRecipeStage s
			Left Join tblICItem i on s.strItemNo=i.strItemNo
			Left Join tblICItemUOM iu  on i.intItemId=iu.intItemId AND iu.ysnStockUnit=1
			Left Join tblSMCompanyLocation cl on s.strLocationName=cl.strLocationName
			Left Join tblMFRecipeType rt on s.strRecipeType=rt.strName
			Left Join tblMFManufacturingProcess mp on s.strManufacturingProcess=mp.strProcessName
			Left Join tblMFCostType ct on s.strCostType=ct.strName
			Left Join tblMFMarginBy m on s.strMarginBy=m.strName
			Left Join tblICUnitMeasure um on s.strUOM=um.strUnitMeasure
			Left Join tblMFOneLinePrint p on s.strOneLinePrint=p.strName
			Where s.intRecipeStageId=@intMinId

			Select @intRecipeId=SCOPE_IDENTITY()

			--Add Default Output Item for production recipe
			If ISNULL(@strItemNo,'')<>''
				Insert Into tblMFRecipeItem(intRecipeId,intItemId,strDescription,dblQuantity,dblCalculatedQuantity,intItemUOMId,intRecipeItemTypeId,strItemGroupName,
											dblUpperTolerance,dblLowerTolerance,dblCalculatedUpperTolerance,dblCalculatedLowerTolerance,dblShrinkage,ysnScaled,
											intConsumptionMethodId,intStorageLocationId,dtmValidFrom,dtmValidTo,ysnYearValidationRequired,
											ysnMinorIngredient,ysnOutputItemMandatory,dblScrap,ysnConsumptionRequired,dblCostAllocationPercentage,intMarginById,dblMargin,
											ysnCostAppliedAtInvoice,intCommentTypeId,strDocumentNo,intSequenceNo,ysnPartialFillConsumption,
											intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified)
				Select TOP 1 @intRecipeId,@intItemId,'',s.[strQuantity],0,iu.intItemUOMId,2,'',0,0,s.[strQuantity],s.[strQuantity],0,0,null,null,null,null,0,
										0,1,0,1,100,null,0,0,null,null,null,1,@intUserId,GETDATE(),@intUserId,GETDATE()
				From tblMFRecipeStage s
				Left Join tblICItem i on s.strItemNo=i.strItemNo
				Left Join tblICItemUOM iu  on i.intItemId=iu.intItemId AND iu.ysnStockUnit=1
				Where s.intRecipeStageId=@intMinId

		End
		Else
		Begin --update
			Update r
			Set r.strName=t.strRecipeName,
				r.dblQuantity=t.[strQuantity],
				r.intManufacturingProcessId=t.intManufacturingProcessId,
				r.intCustomerId=@intCustomerId,
				r.intFarmId=@intFarmFieldId,
				r.intCostTypeId=t.intCostTypeId,
				r.intMarginById=t.intMarginById,
				r.dblMargin=t.[strMargin],
				r.dblDiscount=t.[strDiscount],
				r.intMarginUOMId=t.intUnitMeasureId,
				r.intOneLinePrintId=t.intOneLinePrintId,
				r.intLastModifiedUserId=@intUserId,
				r.dtmLastModified=GETDATE()
			From tblMFRecipe r Cross Join
			(
			Select TOP 1 s.strRecipeName,i.intItemId,s.[strQuantity],iu.intItemUOMId,cl.intCompanyLocationId,s.[strVersionNo],rt.intRecipeTypeId,mp.intManufacturingProcessId,
									ct.intCostTypeId,m.intMarginById,s.[strMargin],s.[strDiscount],um.intUnitMeasureId,p.intOneLinePrintId
			From tblMFRecipeStage s
			Left Join tblICItem i on s.strItemNo=i.strItemNo
			Left Join tblICItemUOM iu  on i.intItemId=iu.intItemId AND iu.ysnStockUnit=1
			Left Join tblSMCompanyLocation cl on s.strLocationName=cl.strLocationName
			Left Join tblMFRecipeType rt on s.strRecipeType=rt.strName
			Left Join tblMFManufacturingProcess mp on s.strManufacturingProcess=mp.strProcessName
			Left Join tblMFCostType ct on s.strCostType=ct.strName
			Left Join tblMFMarginBy m on s.strMarginBy=m.strName
			Left Join tblICUnitMeasure um on s.strUOM=um.strUnitMeasure
			Left Join tblMFOneLinePrint p on s.strOneLinePrint=p.strName
			Where s.intRecipeStageId=@intMinId
			) t
			Where r.intRecipeId=@intRecipeId
		End

		Update tblMFRecipeStage Set strMessage='Success' Where intRecipeStageId=@intMinId

		NEXT_RECIPE:
		Select @intMinId=MIN(intRecipeStageId) From tblMFRecipeStage Where intRecipeStageId > @intMinId AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	
	End

	Update tblMFRecipeStage Set strMessage='Skipped' Where strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	
End

--Recipe Item
If @strImportType='Recipe Item'
Begin
	
	--Recipe Name is required
	Update tblMFRecipeItemStage Set strMessage='Recipe Name is required' 
	Where ISNULL(strRecipeName,'')='' AND ISNULL(strRecipeHeaderItemNo,'')='' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	
	
	--Invalid Header Item
	Update tblMFRecipeItemStage Set strMessage='Invalid Recipe Header Item' 
	Where strRecipeHeaderItemNo not in (Select strItemNo From tblICItem) AND ISNULL(strRecipeHeaderItemNo,'')<>'' AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Version No
	Update tblMFRecipeItemStage Set strMessage='Invalid Version No'
	Where (ISNUMERIC(ISNULL([strVersionNo],0))=0 OR CHARINDEX('.',ISNULL([strVersionNo],0))>0 OR [strVersionNo]='0')
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	

	--Invalid Detail Item
	Update tblMFRecipeItemStage Set strMessage='Invalid Recipe Detail Item' 
	Where ISNULL(strRecipeItemNo,'') not in (Select strItemNo From tblICItem) AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Qty
	Update s Set s.strMessage='Quantity should be greater than 0' 
	From tblMFRecipeItemStage s Join tblICItem i on s.strRecipeItemNo=i.strItemNo 
	Where (ISNUMERIC(s.[strQuantity])=0 OR ISNULL(CAST(s.[strQuantity] as numeric(18,6)),0)<=0) AND i.strType not in ('Other Charge','Comment')
	AND s.strSessionId=@strSessionId AND ISNULL(s.strMessage,'')=''	

	--UOM is required
	Update s Set s.strMessage='UOM is required' 
	From tblMFRecipeItemStage s Join tblICItem i on s.strRecipeItemNo=i.strItemNo 
	Where ISNULL(strUOM,'')='' AND i.strType not in ('Other Charge','Comment')
	AND s.strSessionId=@strSessionId AND ISNULL(s.strMessage,'')=''	

	--Invalid UOM
	Update s Set s.strMessage='Invalid UOM' 
	From tblMFRecipeItemStage s Join tblICItem i on s.strRecipeItemNo=i.strItemNo 
	Where ISNULL(strUOM,'')<>'' AND strUOM not in (Select strUnitMeasure From tblICUnitMeasure) AND i.strType not in ('Other Charge','Comment')
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Recipe Item Type
	Update tblMFRecipeItemStage Set strMessage='Invalid Recipe Item Type (Possible values: INPUT,OUTPUT)' 
	Where strRecipeItemType not in (Select strName From tblMFRecipeItemType) AND ISNULL(strRecipeItemType,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Upper Tolerance
	Update tblMFRecipeItemStage Set strMessage='Invalid Upper Tolerance/Upper Tolerance cannot be negative' 
	Where (ISNUMERIC(ISNULL([strUpperTolerance],0))=0 OR ISNULL(CAST([strUpperTolerance] as numeric(18,6)),0)<0) 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Lower Tolerance
	Update tblMFRecipeItemStage Set strMessage='Invalid Lower Tolerance/Lower Tolerance cannot be negative' 
	Where (ISNUMERIC(ISNULL([strLowerTolerance],0))=0 OR ISNULL(CAST([strLowerTolerance] as numeric(18,6)),0)<0) 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Shrinkage
	Update tblMFRecipeItemStage Set strMessage='Invalid Shrinkage/Shrinkage cannot be negative' 
	Where (ISNUMERIC(ISNULL([strShrinkage],0))=0 OR ISNULL(CAST([strShrinkage] as numeric(18,6)),0)<0) 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Scale
	Update tblMFRecipeItemStage Set strMessage='Invalid Scale (Possible values: 1,0)' 
	Where ISNULL([strScaled],'') NOT IN ('1','0') AND ISNULL([strScaled],'')<>''
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Consumption Method
	Update tblMFRecipeItemStage Set strMessage='Invalid Consumption Method (Possible values: By Lot,By Location,FIFO,None)' 
	Where strConsumptionMethod not in (Select strName From tblMFConsumptionMethod) AND ISNULL(strConsumptionMethod,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Storage Location
	Update tblMFRecipeItemStage Set strMessage='Invalid Storage Location' 
	Where strStorageLocation not in (Select strName From tblICStorageLocation) AND ISNULL(strStorageLocation,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Valid From
	Update tblMFRecipeItemStage Set strMessage='Invalid Valid From (YYYY-MM-DD)' 
	Where ISDATE(ISNULL([strValidFrom],''))=0 AND ISNULL([strValidFrom],'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Valid To
	Update tblMFRecipeItemStage Set strMessage='Invalid Valid To (YYYY-MM-DD)' 
	Where ISDATE(ISNULL([strValidTo],''))=0 AND ISNULL([strValidTo],'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Year Validation
	Update tblMFRecipeItemStage Set strMessage='Invalid Year Validation (Possible values: 1,0)' 
	Where ISNULL([strYearValidationRequired],'') NOT IN ('1','0') AND ISNULL([strYearValidationRequired],'')<>''
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Minor Ingredient
	Update tblMFRecipeItemStage Set strMessage='Invalid Minor Ingredient (Possible values: 1,0)' 
	Where ISNULL([strMinorIngredient],'') NOT IN ('1','0') AND ISNULL([strMinorIngredient],'')<>''
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Output Item Mandatory
	Update tblMFRecipeItemStage Set strMessage='Invalid Output Item Mandatory (Possible values: 1,0)' 
	Where ISNULL([strOutputItemMandatory],'') NOT IN ('1','0') AND ISNULL([strOutputItemMandatory],'')<>''
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Scrap
	Update tblMFRecipeItemStage Set strMessage='Invalid Scrap / Scrap cannot be negative' 
	Where (ISNUMERIC(ISNULL([strScrap],0))=0 OR ISNULL(CAST([strScrap] as numeric(18,6)),0)<0) 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Consumption Required
	Update tblMFRecipeItemStage Set strMessage='Invalid Consumption Required (Possible values: 1,0)' 
	Where ISNULL([strConsumptionRequired],'') NOT IN ('1','0') AND ISNULL([strConsumptionRequired],'')<>''
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Cost Allocation Percentage
	Update tblMFRecipeItemStage Set strMessage='Invalid Cost Allocation Percentage / Cost Allocation Percentage cannot be negative' 
	Where (ISNUMERIC(ISNULL([strCostAllocationPercentage],0))=0 OR ISNULL(CAST([strCostAllocationPercentage] as numeric(18,6)),0)<0) 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Margin By
	Update tblMFRecipeItemStage Set strMessage='Invalid Margin By' 
	Where strMarginBy not in (Select strName From tblMFMarginBy) AND ISNULL(strMarginBy,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Margin
	Update tblMFRecipeItemStage Set strMessage='Invalid Margin / Margin cannot be negative' 
	Where (ISNUMERIC(ISNULL([strMargin],0))=0 OR ISNULL(CAST([strMargin] as numeric(18,6)),0)<0)  
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Cost Applied At Invoice
	Update tblMFRecipeItemStage Set strMessage='Invalid Cost Applied At Invoice (Possible values: 1,0)' 
	Where ISNULL([strCostAppliedAtInvoice],'') NOT IN ('1','0') AND ISNULL([strCostAppliedAtInvoice],'')<>''
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Comment Type
	Update tblMFRecipeItemStage Set strMessage='Invalid Comment Type' 
	Where strCommentType not in (Select strName From tblMFCommentType) AND ISNULL(strCommentType,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Partial Fill Consumption
	Update tblMFRecipeItemStage Set strMessage='Invalid Partial Fill Consumption (Possible values: 1,0)' 
	Where ISNULL([strPartialFillConsumption],'') NOT IN ('1','0') AND ISNULL([strPartialFillConsumption],'')<>''
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Set Default Values
	--Recipe Item Type
	Update tblMFRecipeItemStage Set strRecipeItemType='INPUT'
	Where ISNULL(strRecipeItemType,'')='' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	

	--Consumption Method
	Update tblMFRecipeItemStage Set strConsumptionMethod='By Lot'
	Where ISNULL(strConsumptionMethod,'')='' AND strRecipeItemType='INPUT'
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Comment Type
	Update s Set s.strCommentType='General'
	From tblMFRecipeItemStage s Join tblICItem i on s.strRecipeItemNo=i.strItemNo 
	Where ISNULL(strCommentType,'')='' AND i.strType='Comment'
	AND s.strSessionId=@strSessionId AND ISNULL(s.strMessage,'')=''	

	--Set Comment as Item Desc if empty
	Update s Set s.strDescription=i.strDescription
	From tblMFRecipeItemStage s Join tblICItem i on s.strRecipeItemNo=i.strItemNo 
	Where ISNULL(s.strDescription,'')='' AND i.strType='Comment'
	AND s.strSessionId=@strSessionId AND ISNULL(s.strMessage,'')=''	

	--Quantity=0,UOM=null for Other Charge,Comment items
	Update s Set s.[strQuantity]=0,s.strUOM=null
	From tblMFRecipeItemStage s Join tblICItem i on s.strRecipeItemNo=i.strItemNo 
	Where i.strType in ('Other Charge','Comment')
	AND s.strSessionId=@strSessionId AND ISNULL(s.strMessage,'')=''	

	Select @intMinId=MIN(intRecipeItemStageId) From tblMFRecipeItemStage Where strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	

	--Insert/Update recipe item
	While (@intMinId is not null)
	Begin
		Set @intItemId=NULL
		Set @intVersionNo=NULL
		Set @strRecipeName=''
		Set @intLocationId=null
		Set @intRecipeId=null
		Set @intRecipeDetailItemId=null
		Set @strRecipeDetailItemNo=''
		Set @intRecipeItemId=null
		Set @intRecipeTypeId=null

		--Margin By
		Update tblMFRecipeItemStage Set strMarginBy='Amount'
		Where ISNULL(strMarginBy,'')='' AND ISNULL(CAST([strMargin] as numeric(18,6)),0)>0
		AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	AND intRecipeItemStageId=@intMinId	

		--Valid From
		Update tblMFRecipeItemStage Set [strValidFrom]=CONVERT(VARCHAR,YEAR(GETDATE())) + '-01-01'
		Where ISNULL([strValidFrom],'')=''
		AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	AND intRecipeItemStageId=@intMinId	

		--Valid To
		Update tblMFRecipeItemStage Set [strValidTo]=CONVERT(VARCHAR,YEAR(GETDATE())) + '-12-31'
		Where ISNULL([strValidTo],'')=''
		AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	AND intRecipeItemStageId=@intMinId	

		Select @strRecipeName=strRecipeName,@strItemNo=strRecipeHeaderItemNo,@intVersionNo=[strVersionNo],@strRecipeDetailItemNo=strRecipeItemNo
		From tblMFRecipeItemStage Where intRecipeItemStageId=@intMinId
		Select @intItemId=intItemId From tblICItem Where strItemNo=@strItemNo
		Select @intRecipeDetailItemId=intItemId From tblICItem Where strItemNo=@strRecipeDetailItemNo

		If ISNULL(@strItemNo,'')<>'' --Production Recipe
			Select TOP 1 @intRecipeId=intRecipeId,@intRecipeTypeId=intRecipeTypeId,@intLocationId=intLocationId From tblMFRecipe Where intItemId=@intItemId AND intVersionNo=@intVersionNo
		Else --Virtual Recipe
			Select TOP 1 @intRecipeId=intRecipeId,@intRecipeTypeId=intRecipeTypeId,@intLocationId=intLocationId From tblMFRecipe Where strName=@strRecipeName

		If @intRecipeId is null
		Begin
			Update tblMFRecipeItemStage Set strMessage='No recipe found to add items.' Where intRecipeItemStageId=@intMinId
			GOTO NEXT_RECIPEITEM
		End

		Select TOp 1 @intRecipeItemId=intRecipeItemId from tblMFRecipeItem Where intRecipeId=@intRecipeId AND intItemId=@intRecipeDetailItemId

		If @intRecipeItemId is null --insert
		Begin
			Insert Into tblMFRecipeItem(intRecipeId,intItemId,strDescription,dblQuantity,dblCalculatedQuantity,intItemUOMId,intRecipeItemTypeId,strItemGroupName,
										dblUpperTolerance,dblLowerTolerance,dblCalculatedUpperTolerance,dblCalculatedLowerTolerance,dblShrinkage,ysnScaled,
										intConsumptionMethodId,intStorageLocationId,dtmValidFrom,dtmValidTo,ysnYearValidationRequired,
										ysnMinorIngredient,ysnOutputItemMandatory,dblScrap,ysnConsumptionRequired,dblCostAllocationPercentage,intMarginById,dblMargin,
										ysnCostAppliedAtInvoice,intCommentTypeId,strDocumentNo,intSequenceNo,ysnPartialFillConsumption,
										intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified)
			Select @intRecipeId,i.intItemId,CASE WHEN ct.intCommentTypeId>0 THEN s.strDescription ELSE '' END,s.[strQuantity],CASE WHEN s.strRecipeItemType='OUTPUT' THEN 0 ELSE dbo.fnMFCalculateRecipeItemQuantity(rt.intRecipeItemTypeId,s.[strQuantity],ISNULL(s.[strShrinkage],0)) END,iu.intItemUOMId,rt.intRecipeItemTypeId,s.strItemGroupName,
									s.[strUpperTolerance],s.[strLowerTolerance],dbo.fnMFCalculateRecipeItemUpperTolerance(@intRecipeTypeId,s.[strQuantity],ISNULL(s.[strShrinkage],0),ISNULL(s.[strUpperTolerance],0)),dbo.fnMFCalculateRecipeItemLowerTolerance(@intRecipeTypeId,s.[strQuantity],ISNULL(s.[strShrinkage],0),ISNULL(s.[strLowerTolerance],0)),ISNULL(s.[strShrinkage],0),ISNULL(s.[strScaled],1),
									CASE WHEN i.strType in ('Other Charge','Comment') THEN 4 Else cm.intConsumptionMethodId End intConsumptionMethodId,sl.intStorageLocationId,s.[strValidFrom],s.[strValidTo],ISNULL(s.[strYearValidationRequired],0),
									ISNULL(s.[strMinorIngredient],0),CASE WHEN i.intItemId=@intItemId THEN 1 ELSE ISNULL(s.[strOutputItemMandatory],0) END,ISNULL(s.[strScrap],0),CASE WHEN i.intItemId=@intItemId THEN 1 ELSE ISNULL(s.[strConsumptionRequired],0) END,ISNULL(s.[strCostAllocationPercentage],0),m.intMarginById,s.[strMargin],
									ISNULL(s.[strCostAppliedAtInvoice],0),ct.intCommentTypeId,s.strDocumentNo,null,ISNULL(s.[strPartialFillConsumption],1),
									@intUserId,GETDATE(),@intUserId,GETDATE()
			From tblMFRecipeItemStage s
			Left Join tblICItem i on s.strRecipeItemNo=i.strItemNo
			Left Join tblICUnitMeasure um on um.strUnitMeasure=s.strUOM
			Left Join tblICItemUOM iu  on i.intItemId=iu.intItemId AND iu.intUnitMeasureId=um.intUnitMeasureId
			Left Join tblMFRecipeItemType rt on s.strRecipeItemType=rt.strName
			Left Join tblMFConsumptionMethod cm on s.strConsumptionMethod=cm.strName
			Left Join tblICStorageLocation sl on sl.strName=s.strStorageLocation AND sl.intLocationId=@intLocationId
			Left Join tblMFMarginBy m on s.strMarginBy=m.strName
			Left Join tblMFCommentType ct on s.strCommentType=ct.strName
			Where s.intRecipeItemStageId=@intMinId
		End
		Else
		Begin --update
			Update ri
			Set ri.strDescription=t.strDescription,
				ri.dblQuantity=t.[strQuantity],
				ri.dblCalculatedQuantity=t.dblCalculatedQuantity,
				ri.intItemUOMId=t.intItemUOMId,
				ri.intRecipeItemTypeId=t.intRecipeItemTypeId,
				ri.strItemGroupName=t.strItemGroupName,
				ri.dblUpperTolerance=t.[strUpperTolerance],
				ri.dblLowerTolerance=t.[strLowerTolerance],
				ri.dblCalculatedUpperTolerance=t.dblCalculatedUpperTolerance,
				ri.dblCalculatedLowerTolerance=t.dblCalculatedLowerTolerance,
				ri.dblShrinkage=t.dblShrinkage,
				ri.ysnScaled=t.ysnScaled,
				ri.intConsumptionMethodId=t.intConsumptionMethodId,
				ri.intStorageLocationId=t.intStorageLocationId,
				ri.dtmValidFrom=t.[strValidFrom],
				ri.dtmValidTo=t.[strValidTo],
				ri.ysnYearValidationRequired=t.ysnYearValidationRequired,
				ri.ysnMinorIngredient=t.ysnMinorIngredient,
				ri.ysnOutputItemMandatory=t.ysnOutputItemMandatory,
				ri.dblScrap=t.dblScrap,
				ri.ysnConsumptionRequired=t.ysnConsumptionRequired,
				ri.dblCostAllocationPercentage=t.dblCostAllocationPercentage,
				ri.intMarginById=t.intMarginById,
				ri.dblMargin=t.[strMargin],
				ri.ysnCostAppliedAtInvoice=t.ysnCostAppliedAtInvoice,
				ri.intCommentTypeId=t.intCommentTypeId,
				ri.strDocumentNo=t.strDocumentNo,
				ri.intSequenceNo=t.intSequenceNo,
				ri.ysnPartialFillConsumption=t.ysnPartialFillConsumption,
				ri.intLastModifiedUserId=@intUserId,
				ri.dtmLastModified=GETDATE()
			From tblMFRecipeItem ri Cross Join
			(
			Select TOP 1 i.intItemId,CASE WHEN ct.intCommentTypeId>0 THEN s.strDescription ELSE '' END AS strDescription,s.[strQuantity],CASE WHEN s.strRecipeItemType='OUTPUT' THEN 0 ELSE dbo.fnMFCalculateRecipeItemQuantity(rt.intRecipeItemTypeId,s.[strQuantity],ISNULL(s.[strShrinkage],0)) END dblCalculatedQuantity,iu.intItemUOMId,rt.intRecipeItemTypeId,s.strItemGroupName,
									s.[strUpperTolerance],s.[strLowerTolerance],dbo.fnMFCalculateRecipeItemUpperTolerance(@intRecipeTypeId,s.[strQuantity],ISNULL(s.[strShrinkage],0),ISNULL(s.[strUpperTolerance],0)) dblCalculatedUpperTolerance,dbo.fnMFCalculateRecipeItemLowerTolerance(@intRecipeTypeId,s.[strQuantity],ISNULL(s.[strShrinkage],0),ISNULL(s.[strLowerTolerance],0)) dblCalculatedLowerTolerance,ISNULL(s.[strShrinkage],0) dblShrinkage,ISNULL(s.[strScaled],1) ysnScaled,
									CASE WHEN i.strType in ('Other Charge','Comment') THEN 4 Else cm.intConsumptionMethodId End intConsumptionMethodId,sl.intStorageLocationId,s.[strValidFrom],s.[strValidTo],ISNULL(s.[strYearValidationRequired],0) ysnYearValidationRequired,
									ISNULL(s.[strMinorIngredient],0) ysnMinorIngredient,CASE WHEN i.intItemId=@intItemId THEN 1 ELSE ISNULL(s.[strOutputItemMandatory],0) END ysnOutputItemMandatory,ISNULL(s.[strScrap],0) dblScrap,CASE WHEN i.intItemId=@intItemId THEN 1 ELSE ISNULL(s.[strConsumptionRequired],0) END ysnConsumptionRequired,ISNULL(s.[strCostAllocationPercentage],0) dblCostAllocationPercentage,m.intMarginById,s.[strMargin],
									ISNULL(s.[strCostAppliedAtInvoice],0) ysnCostAppliedAtInvoice,ct.intCommentTypeId,s.strDocumentNo,null intSequenceNo,ISNULL(s.[strPartialFillConsumption],1) ysnPartialFillConsumption
			From tblMFRecipeItemStage s
			Left Join tblICItem i on s.strRecipeItemNo=i.strItemNo
			Left Join tblICUnitMeasure um on um.strUnitMeasure=s.strUOM
			Left Join tblICItemUOM iu  on i.intItemId=iu.intItemId AND iu.intUnitMeasureId=um.intUnitMeasureId
			Left Join tblMFRecipeItemType rt on s.strRecipeItemType=rt.strName
			Left Join tblMFConsumptionMethod cm on s.strConsumptionMethod=cm.strName
			Left Join tblICStorageLocation sl on sl.strName=s.strStorageLocation AND sl.intLocationId=@intLocationId
			Left Join tblMFMarginBy m on s.strMarginBy=m.strName
			Left Join tblMFCommentType ct on s.strCommentType=ct.strName
			Where s.intRecipeItemStageId=@intMinId
			) t
			Where ri.intRecipeItemId=@intRecipeItemId
		End

		Update tblMFRecipeItemStage Set strMessage='Success' Where intRecipeItemStageId=@intMinId

		NEXT_RECIPEITEM:
		Select @intMinId=MIN(intRecipeItemStageId) From tblMFRecipeItemStage Where intRecipeItemStageId > @intMinId AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	
	End

	--Mark Recipe as Active if it has Input Items
	If (Select Count(1) From tblMFRecipeItem Where intRecipeId=@intRecipeId AND intRecipeItemTypeId=1)>1
		Update tblMFRecipe Set ysnActive=1 Where intRecipeId=@intRecipeId

	Update tblMFRecipeItemStage Set strMessage='Skipped' Where strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	
End

--Recipe Substitute Item
If @strImportType='Recipe Substitute Item'
Begin
	
	--Recipe Name is required
	Update tblMFRecipeSubstituteItemStage Set strMessage='Recipe Name is required' 
	Where ISNULL(strRecipeName,'')='' AND ISNULL(strRecipeHeaderItemNo,'')='' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	
	
	--Invalid Header Item
	Update tblMFRecipeSubstituteItemStage Set strMessage='Invalid Recipe Header Item' 
	Where strRecipeHeaderItemNo not in (Select strItemNo From tblICItem) AND ISNULL(strRecipeHeaderItemNo,'')<>'' 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Version No
	Update tblMFRecipeSubstituteItemStage Set strMessage='Invalid Version No'
	Where (ISNUMERIC(ISNULL([strVersionNo],0))=0 OR CHARINDEX('.',ISNULL([strVersionNo],0))>0 OR [strVersionNo]='0')
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	

	--Invalid Detail Item
	Update tblMFRecipeSubstituteItemStage Set strMessage='Invalid Recipe Detail Item' 
	Where ISNULL(strRecipeItemNo,'') not in (Select strItemNo From tblICItem) AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Substitute Item
	Update tblMFRecipeSubstituteItemStage Set strMessage='Invalid Substitute Item' 
	Where ISNULL(strSubstituteItemNo,'') not in (Select strItemNo From tblICItem) AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Substitute Ratio
	Update tblMFRecipeSubstituteItemStage Set strMessage='Invalid Substitute Ratio/Substitute Ratio cannot be negative' 
	Where (ISNUMERIC([strSubstituteRatio])=0 OR ISNULL(CAST([strSubstituteRatio] as numeric(18,6)),0)<0) 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	--Invalid Max Substitute Ratio
	Update tblMFRecipeSubstituteItemStage Set strMessage='Invalid Max Substitute/Max Substitute Ratio cannot be negative' 
	Where (ISNUMERIC([strMaxSubstituteRatio])=0 OR ISNULL(CAST([strMaxSubstituteRatio] as numeric(18,6)),0)<0) 
	AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''

	Select @intMinId=MIN(intRecipeSubstituteItemStageId) From tblMFRecipeSubstituteItemStage Where strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	

	--Insert/Update recipe sub item
	While (@intMinId is not null)
	Begin
		Set @intItemId=NULL
		Set @intVersionNo=NULL
		Set @strRecipeName=''
		Set @intLocationId=null
		Set @intRecipeId=null
		Set @intRecipeDetailItemId=null
		Set @strRecipeDetailItemNo=''
		Set @intRecipeItemId=null
		Set @intRecipeSubstituteItemId=null
		Set @intRecipeTypeId=null
		Set @intSubstituteItemId=null
		Set @strSubstituteItemNo=null
		Set @intInputItemUOMId=null
		Set @intSubstituteItemUOMId=null
		Set @dblRecipeDetailCalculatedQty=null
		Set @dblRecipeDetailUpperTolerance=null
		Set @dblRecipeDetailLowerTolerance=null

		Select @strRecipeName=strRecipeName,@strItemNo=strRecipeHeaderItemNo,@intVersionNo=[strVersionNo],@strRecipeDetailItemNo=strRecipeItemNo,@strSubstituteItemNo=strSubstituteItemNo
		From tblMFRecipeSubstituteItemStage Where intRecipeSubstituteItemStageId=@intMinId
		Select @intItemId=intItemId From tblICItem Where strItemNo=@strItemNo
		Select @intRecipeDetailItemId=intItemId From tblICItem Where strItemNo=@strRecipeDetailItemNo
		Select @intSubstituteItemId=intItemId From tblICItem Where strItemNo=@strSubstituteItemNo

		If ISNULL(@strItemNo,'')<>'' --Production Recipe
			Select TOP 1 @intRecipeId=intRecipeId,@intRecipeTypeId=intRecipeTypeId,@intLocationId=intLocationId From tblMFRecipe Where intItemId=@intItemId AND intVersionNo=@intVersionNo
		Else --Virtual Recipe
			Select TOP 1 @intRecipeId=intRecipeId,@intRecipeTypeId=intRecipeTypeId,@intLocationId=intLocationId From tblMFRecipe Where strName=@strRecipeName

		If @intRecipeId is null
		Begin
			Update tblMFRecipeSubstituteItemStage Set strMessage='No recipe found to add items.' Where intRecipeSubstituteItemStageId=@intMinId
			GOTO NEXT_SUBITEM
		End

		Select TOp 1 @intRecipeItemId=intRecipeItemId,@intInputItemUOMId=intItemUOMId,@dblRecipeDetailCalculatedQty=dblCalculatedQuantity,
		@dblRecipeDetailUpperTolerance=dblUpperTolerance,@dblRecipeDetailLowerTolerance=dblLowerTolerance
		from tblMFRecipeItem Where intRecipeId=@intRecipeId AND intItemId=@intRecipeDetailItemId

		If @intRecipeItemId is null
		Begin
			Update tblMFRecipeSubstituteItemStage Set strMessage='No recipe detail item found to add substitute items.' Where intRecipeSubstituteItemStageId=@intMinId
			GOTO NEXT_SUBITEM
		End

		--Get the Sub Item's Item UOM Id corresponding to the input item
		Select TOP 1 @intSubstituteItemUOMId=iu1.intItemUOMId 
		From tblICItemUOM iu Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICItemUOM iu1 on iu1.intUnitMeasureId=iu.intUnitMeasureId AND iu1.intItemId=@intSubstituteItemId
		Where iu.intItemUOMId=@intInputItemUOMId

		If @intSubstituteItemUOMId is null
		Begin
			Update tblMFRecipeSubstituteItemStage Set strMessage='UOM not found for substitute items.' Where intRecipeSubstituteItemStageId=@intMinId
			GOTO NEXT_SUBITEM
		End

		Select TOP 1 @intRecipeSubstituteItemId=intRecipeSubstituteItemId from tblMFRecipeSubstituteItem Where intRecipeId=@intRecipeId AND intRecipeItemId=@intRecipeItemId AND intSubstituteItemId=@intSubstituteItemId

		If @intRecipeSubstituteItemId is null --insert
		Begin
			Insert Into tblMFRecipeSubstituteItem(intRecipeItemId,intRecipeId,intItemId,intSubstituteItemId,dblQuantity,intItemUOMId,dblSubstituteRatio,dblMaxSubstituteRatio,
										dblCalculatedUpperTolerance,dblCalculatedLowerTolerance,intRecipeItemTypeId,
										intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified)
			Select  @intRecipeItemId,@intRecipeId,@intRecipeDetailItemId,i.intItemId,
									dbo.fnMFCalculateRecipeSubItemQuantity(@dblRecipeDetailCalculatedQty,s.[strSubstituteRatio],s.[strMaxSubstituteRatio]),@intSubstituteItemUOMId,s.[strSubstituteRatio],s.[strMaxSubstituteRatio],
									dbo.fnMFCalculateRecipeSubItemUpperTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(@dblRecipeDetailCalculatedQty,s.[strSubstituteRatio],s.[strMaxSubstituteRatio]),@dblRecipeDetailUpperTolerance),
									dbo.fnMFCalculateRecipeSubItemLowerTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(@dblRecipeDetailCalculatedQty,s.[strSubstituteRatio],s.[strMaxSubstituteRatio]),@dblRecipeDetailLowerTolerance),1,
									@intUserId,GETDATE(),@intUserId,GETDATE()
			From tblMFRecipeSubstituteItemStage s
			Left Join tblICItem i on s.strSubstituteItemNo=i.strItemNo
			Where s.intRecipeSubstituteItemStageId=@intMinId
		End
		Else
		Begin --update
			Update rs
			Set rs.dblQuantity=t.dblQuantity,
				rs.dblSubstituteRatio=t.[strSubstituteRatio],
				rs.dblMaxSubstituteRatio=t.[strMaxSubstituteRatio],
				rs.dblCalculatedUpperTolerance=t.dblUpperTolerance,
				rs.dblCalculatedLowerTolerance=t.dblLowerTolerance,
				rs.intLastModifiedUserId=@intUserId,
				rs.dtmLastModified=GETDATE()
			From tblMFRecipeSubstituteItem rs Cross Join
			(
			Select TOP 1 dbo.fnMFCalculateRecipeSubItemQuantity(@dblRecipeDetailCalculatedQty,s.[strSubstituteRatio],s.[strMaxSubstituteRatio]) dblQuantity,s.[strSubstituteRatio],s.[strMaxSubstituteRatio],
					dbo.fnMFCalculateRecipeSubItemUpperTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(@dblRecipeDetailCalculatedQty,s.[strSubstituteRatio],s.[strMaxSubstituteRatio]),@dblRecipeDetailUpperTolerance) dblUpperTolerance,
					dbo.fnMFCalculateRecipeSubItemLowerTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(@dblRecipeDetailCalculatedQty,s.[strSubstituteRatio],s.[strMaxSubstituteRatio]),@dblRecipeDetailLowerTolerance) dblLowerTolerance
			From tblMFRecipeSubstituteItemStage s
			Where s.intRecipeSubstituteItemStageId=@intMinId
			) t
			Where rs.intRecipeSubstituteItemId=@intRecipeSubstituteItemId
		End

		Update tblMFRecipeSubstituteItemStage Set strMessage='Success' Where intRecipeSubstituteItemStageId=@intMinId

		NEXT_SUBITEM:
		Select @intMinId=MIN(intRecipeSubstituteItemStageId) From tblMFRecipeSubstituteItemStage Where intRecipeSubstituteItemStageId > @intMinId AND strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	
	End

	Update tblMFRecipeSubstituteItemStage Set strMessage='Skipped' Where strSessionId=@strSessionId AND ISNULL(strMessage,'')=''	
End
