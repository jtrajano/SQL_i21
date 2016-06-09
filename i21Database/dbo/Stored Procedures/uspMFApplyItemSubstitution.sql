CREATE PROCEDURE [dbo].[uspMFApplyItemSubstitution]
	@intItemSubstitutionId int,
	@intUserId int
AS
Begin Try

Declare @intMinRecipe int
Declare @intMinSubstitutionDetail int
Declare @intRecipeId int
Declare @intRecipeTypeId int
Declare @strRecipeItemNo nvarchar(100)
Declare @intInputRecipeItemId int
Declare @intInputItemId int 
Declare @intItemSubstitutionTypeId int
Declare @dtmDate DATETIME=GETDATE()
Declare @intDayOfYear INT=DATEPART(dy, @dtmDate)
Declare @dtmInputRecipeItemValidFrom DateTime
Declare @dtmInputRecipeItemValidTo DateTime
Declare @ysnInputRecipeItemYearValidationRequired bit
Declare @ysnProcessed bit 
Declare @ysnCancelled bit 
Declare @ErrMsg nvarchar(Max)
Declare @intNewRecipeItemId int
Declare @dtmValidFrom DateTime
Declare @dtmValidTo DateTime
Declare @dblPercent numeric(18,6)
Declare @intItemId int
Declare @intItemUOMId int
Declare @ysnYearValidationRequired bit
Declare @dblSubstituteRatio numeric(18,6)
Declare @dblMaxSubstituteRatio numeric(18,6)
Declare @strItemNo nvarchar(50)

Select @intInputItemId=intItemId,@intItemSubstitutionTypeId=intItemSubstitutionTypeId,@ysnProcessed=ISNULL(ysnProcessed,0),@ysnCancelled=ISNULL(ysnCancelled,0)  
From tblMFItemSubstitution Where intItemSubstitutionId=@intItemSubstitutionId

if @ysnProcessed=1
	RaisError('The Substitution is already processed.',16,1)

if @ysnCancelled=1
	RaisError('The Substitution is cancelled.',16,1)

Select @intMinRecipe=Min(intItemSubstitutionRecipeId) from tblMFItemSubstitutionRecipe Where intItemSubstitutionId=@intItemSubstitutionId And ysnApplied=1

Begin Tran

While(@intMinRecipe is not null) --Recipe Loop
Begin
	Select @intRecipeId=intRecipeId from tblMFItemSubstitutionRecipe where intItemSubstitutionRecipeId=@intMinRecipe
	Select @intRecipeTypeId=r.intRecipeTypeId,@strRecipeItemNo=i.strItemNo 
	From tblMFRecipe r Join tblICItem i on r.intItemId=i.intItemId Where r.intRecipeId=@intRecipeId

	--Get the existing repice item details
	Select TOP 1 @intInputRecipeItemId=intRecipeItemId,@dtmInputRecipeItemValidFrom=dtmValidFrom,@dtmInputRecipeItemValidTo=dtmValidTo,
	@ysnInputRecipeItemYearValidationRequired=ysnYearValidationRequired
	From tblMFRecipeItem ri Where ri.intRecipeId=@intRecipeId And ri.intItemId=@intInputItemId And
	((ri.ysnYearValidationRequired = 1 AND @dtmDate BETWEEN ri.dtmValidFrom AND ri.dtmValidTo)
	OR (ri.ysnYearValidationRequired = 0 AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom) AND DATEPART(dy, ri.dtmValidTo)))

	If ISNULL(@intInputRecipeItemId,0)=0
	Begin
		Set @ErrMsg='No Active Item found for recipe ' + @strRecipeItemNo
		RaisError(@ErrMsg,16,1)
	End

	If @intItemSubstitutionTypeId=1 --Replacement
	Begin
		Select @intMinSubstitutionDetail=Min(intItemSubstitutionDetailId) From tblMFItemSubstitutionDetail Where intItemSubstitutionId=@intItemSubstitutionId

		While(@intMinSubstitutionDetail is not null) --Substitution Detail Loop
		Begin
			--Get the substitute item details
			Select @intItemId=intItemId,@dtmValidFrom=dtmValidFrom,@dtmValidTo=dtmValidTo,
			@ysnYearValidationRequired=ysnYearValidationRequired,@dblPercent=dblPercent
			From tblMFItemSubstitutionDetail Where intItemSubstitutionDetailId=@intMinSubstitutionDetail

			--Get Stock UOM
			Select @intItemUOMId=intItemUOMId From tblICItemUOM Where intItemId=@intItemId And ysnStockUnit=1

			--insert the new recipe item
			Insert Into tblMFRecipeItem(intRecipeId,intItemId,dblQuantity,dblCalculatedQuantity,intItemUOMId,intRecipeItemTypeId,strItemGroupName,
			dblUpperTolerance,dblLowerTolerance,dblCalculatedUpperTolerance,dblCalculatedLowerTolerance,dblShrinkage,ysnScaled,
			intConsumptionMethodId,intStorageLocationId,dtmValidFrom,dtmValidTo,ysnYearValidationRequired,ysnMinorIngredient,
			intReferenceRecipeId,ysnOutputItemMandatory,dblScrap,ysnConsumptionRequired,dblCostAllocationPercentage,intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified)
			Select @intRecipeId,@intItemId,(ri.dblQuantity * (@dblPercent/100)) AS dblQuantity,
			dbo.fnMFCalculateRecipeItemQuantity(@intRecipeTypeId,(ri.dblQuantity * (@dblPercent/100)),ri.dblShrinkage) AS dblCalculatedQuantity,
			@intItemUOMId,1,ri.strItemGroupName,
			ri.dblUpperTolerance,ri.dblLowerTolerance,
			dbo.fnMFCalculateRecipeItemUpperTolerance(@intRecipeTypeId,(ri.dblQuantity * (@dblPercent/100)),ri.dblShrinkage,ri.dblUpperTolerance) AS dblCalculatedUpperTolerance,
			dbo.fnMFCalculateRecipeItemLowerTolerance(@intRecipeTypeId,(ri.dblQuantity * (@dblPercent/100)),ri.dblShrinkage,ri.dblLowerTolerance) AS dblCalculatedLowerTolerance,
			ri.dblShrinkage,ri.ysnScaled,ri.intConsumptionMethodId,ri.intStorageLocationId,@dtmValidFrom,@dtmValidTo,@ysnYearValidationRequired,ri.ysnMinorIngredient,
			null intReferenceRecipeId,ri.ysnOutputItemMandatory,ri.dblScrap,ri.ysnConsumptionRequired,ri.dblCostAllocationPercentage,@intUserId,@dtmDate,@intUserId,@dtmDate
			From tblMFRecipeItem ri 
			Where ri.intRecipeItemId=@intInputRecipeItemId
	
			Select @intNewRecipeItemId=SCOPE_IDENTITY()

			--insert new recipe items to Substitution Recipe recipe table
			Insert Into tblMFItemSubstitutionRecipeDetail(intItemSubstitutionId,intItemSubstitutionDetailId,intItemSubstitutionRecipeId,intRecipeItemId)
			Select @intItemSubstitutionId,sd.intItemSubstitutionDetailId,@intMinRecipe,@intNewRecipeItemId
			From tblMFItemSubstitutionDetail sd 
			Where sd.intItemSubstitutionDetailId=@intMinSubstitutionDetail

			Select @intMinSubstitutionDetail=Min(intItemSubstitutionDetailId) From tblMFItemSubstitutionDetail 
			Where intItemSubstitutionId=@intItemSubstitutionId And intItemSubstitutionDetailId>@intMinSubstitutionDetail
		End --End Substitution Detail Loop

		--Update the old recipeitem as inactive
		Update tblMFRecipeItem Set dtmValidFrom='2000-01-01',dtmValidTo=str(year(@dtmDate)-1) + '-12-31',ysnYearValidationRequired=1 
		Where intRecipeItemId=@intInputRecipeItemId

		--Update old recipe item details in Substitution Recipe table
		Update tblMFItemSubstitutionRecipe Set intRecipeItemId=@intInputRecipeItemId,dtmValidFrom=@dtmInputRecipeItemValidFrom,dtmValidTo=@dtmInputRecipeItemValidTo,ysnYearValidationRequired=@ysnInputRecipeItemYearValidationRequired
		Where intItemSubstitutionRecipeId=@intMinRecipe
	End

	If @intItemSubstitutionTypeId=2 --Substitute
	Begin
		Select @intMinSubstitutionDetail=Min(intItemSubstitutionDetailId) From tblMFItemSubstitutionDetail Where intItemSubstitutionId=@intItemSubstitutionId

		While(@intMinSubstitutionDetail is not null) --Substitution Detail Loop
		Begin
			--Get the substitute item details
			Select @intItemId=intItemId,@dblSubstituteRatio=dblSubstituteRatio,@dblMaxSubstituteRatio=dblMaxSubstituteRatio
			From tblMFItemSubstitutionDetail Where intItemSubstitutionDetailId=@intMinSubstitutionDetail

			If Exists(Select 1 From tblMFRecipeItem Where intRecipeId=@intRecipeId And intItemId=@intItemId)
			Begin
				Select @strItemNo=strItemNo From tblICItem Where intItemId=@intItemId
				Set @ErrMsg='The specified substitute item ' + @strItemNo + ' can not be added as it is one of the input item for recipe ' + @strRecipeItemNo
				RaisError(@ErrMsg,16,1)
			End

			--Get Stock UOM
			Select @intItemUOMId=intItemUOMId From tblICItemUOM Where intItemId=@intInputItemId And ysnStockUnit=1

			--insert the new recipe substitute item
			Insert Into tblMFRecipeSubstituteItem(intRecipeItemId,intRecipeId,intItemId,intSubstituteItemId,dblQuantity,intItemUOMId,dblSubstituteRatio,
			dblMaxSubstituteRatio,dblCalculatedUpperTolerance,dblCalculatedLowerTolerance,intRecipeItemTypeId,intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified)
			Select @intInputRecipeItemId,@intRecipeId,@intInputItemId,@intItemId,dbo.fnMFCalculateRecipeSubItemQuantity(ri.dblCalculatedQuantity,@dblSubstituteRatio,@dblMaxSubstituteRatio) AS dblQuantity,
			@intItemUOMId,@dblSubstituteRatio,@dblMaxSubstituteRatio,
			dbo.fnMFCalculateRecipeSubItemUpperTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(ri.dblCalculatedQuantity,@dblSubstituteRatio,@dblMaxSubstituteRatio),ri.dblUpperTolerance) AS dblCalculatedUpperTolerance,
			dbo.fnMFCalculateRecipeSubItemLowerTolerance(dbo.fnMFCalculateRecipeSubItemQuantity(ri.dblCalculatedQuantity,@dblSubstituteRatio,@dblMaxSubstituteRatio),ri.dblLowerTolerance) AS dblCalculatedLowerTolerance,
			1,@intUserId,@dtmDate,@intUserId,@dtmDate
			From tblMFRecipeItem ri 
			Where ri.intRecipeItemId=@intInputRecipeItemId
	
			Select @intNewRecipeItemId=SCOPE_IDENTITY()

			--insert new recipe items to Substitution Recipe recipe table
			Insert Into tblMFItemSubstitutionRecipeDetail(intItemSubstitutionId,intItemSubstitutionDetailId,intItemSubstitutionRecipeId,intRecipeItemId)
			Select @intItemSubstitutionId,sd.intItemSubstitutionDetailId,@intMinRecipe,@intNewRecipeItemId
			From tblMFItemSubstitutionDetail sd 
			Where sd.intItemSubstitutionDetailId=@intMinSubstitutionDetail

			Select @intMinSubstitutionDetail=Min(intItemSubstitutionDetailId) From tblMFItemSubstitutionDetail 
			Where intItemSubstitutionId=@intItemSubstitutionId And intItemSubstitutionDetailId>@intMinSubstitutionDetail
		End --End Substitution Detail Loop

		--Update input recipe item details in Substitution Recipe table
		Update tblMFItemSubstitutionRecipe Set intRecipeItemId=@intInputRecipeItemId,dtmValidFrom=@dtmInputRecipeItemValidFrom,dtmValidTo=@dtmInputRecipeItemValidTo,ysnYearValidationRequired=@ysnInputRecipeItemYearValidationRequired
		Where intItemSubstitutionRecipeId=@intMinRecipe
	End

	Select @intMinRecipe=Min(intItemSubstitutionRecipeId) from tblMFItemSubstitutionRecipe where intItemSubstitutionId=@intItemSubstitutionId 
	And intItemSubstitutionRecipeId>@intMinRecipe And ysnApplied=1
End --End Recipe Loop

	Update tblMFItemSubstitution Set ysnProcessed=1,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmDate 
	Where intItemSubstitutionId=@intItemSubstitutionId

Commit Tran

End Try
Begin Catch
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch	


