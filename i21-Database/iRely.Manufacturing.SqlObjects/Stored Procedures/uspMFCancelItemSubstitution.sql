CREATE PROCEDURE [dbo].[uspMFCancelItemSubstitution]
	@intItemSubstitutionId int,
	@intUserId int
AS
Begin Try
Declare @ErrMsg nvarchar(Max)
Declare @ysnProcessed bit 
Declare @ysnCancelled bit 
Declare @intInputItemId int
Declare @intItemSubstitutionTypeId int
Declare @intMinRecipe int
Declare @intRecipeId int
Declare @strRecipeItemNo nvarchar(100)
Declare @intInputRecipeItemId int
Declare @dtmInputRecipeItemValidFrom DateTime
Declare @dtmInputRecipeItemValidTo DateTime
Declare @ysnInputRecipeItemYearValidationRequired bit
Declare @dtmDate DateTime=GETDATE()

Select @intInputItemId=intItemId,@intItemSubstitutionTypeId=intItemSubstitutionTypeId,@ysnProcessed=ISNULL(ysnProcessed,0),@ysnCancelled=ISNULL(ysnCancelled,0)  
From tblMFItemSubstitution Where intItemSubstitutionId=@intItemSubstitutionId

if @ysnProcessed=0
	RaisError('The Substitution is not processed.',16,1)

if @ysnCancelled=1
	RaisError('The Substitution is already cancelled.',16,1)


Select @intMinRecipe=Min(intItemSubstitutionRecipeId) from tblMFItemSubstitutionRecipe Where intItemSubstitutionId=@intItemSubstitutionId And ysnApplied=1

Begin Tran

While(@intMinRecipe is not null) --Recipe Loop
Begin
	Select @intRecipeId=intRecipeId from tblMFItemSubstitutionRecipe where intItemSubstitutionRecipeId=@intMinRecipe
	Select @strRecipeItemNo=i.strItemNo 
	From tblMFRecipe r Join tblICItem i on r.intItemId=i.intItemId Where r.intRecipeId=@intRecipeId

	--Get the existing repice item details
	Select TOP 1 @intInputRecipeItemId=intRecipeItemId,@dtmInputRecipeItemValidFrom=dtmValidFrom,@dtmInputRecipeItemValidTo=dtmValidTo,
	@ysnInputRecipeItemYearValidationRequired=ysnYearValidationRequired
	From tblMFItemSubstitutionRecipe Where intItemSubstitutionRecipeId=@intMinRecipe

	If @intItemSubstitutionTypeId=1 --Replacement
	Begin
		--Remove the replaced recipe items
		Delete From tblMFRecipeItem Where intRecipeId=@intRecipeId And intRecipeItemId in 
		(Select intRecipeItemId From tblMFItemSubstitutionRecipeDetail Where intItemSubstitutionRecipeId=@intMinRecipe)
		
		--Update the recipe item with its previous alues
		Update tblMFRecipeItem Set dtmValidFrom=@dtmInputRecipeItemValidFrom,dtmValidTo=@dtmInputRecipeItemValidTo,ysnYearValidationRequired=@ysnInputRecipeItemYearValidationRequired 
		Where intRecipeItemId=@intInputRecipeItemId
	End

	If @intItemSubstitutionTypeId=2 --Substitute
	Begin
		--Remove the substituted recipe items
		Delete From tblMFRecipeSubstituteItem Where intRecipeId=@intRecipeId And intRecipeSubstituteItemId in 
		(Select intRecipeItemId From tblMFItemSubstitutionRecipeDetail Where intItemSubstitutionRecipeId=@intMinRecipe)
	End

	Select @intMinRecipe=Min(intItemSubstitutionRecipeId) from tblMFItemSubstitutionRecipe where intItemSubstitutionId=@intItemSubstitutionId 
	And intItemSubstitutionRecipeId>@intMinRecipe And ysnApplied=1
End --End Recipe Loop

	Update tblMFItemSubstitution Set ysnCancelled=1,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmDate 
	Where intItemSubstitutionId=@intItemSubstitutionId

Commit Tran

End Try
Begin Catch
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch	