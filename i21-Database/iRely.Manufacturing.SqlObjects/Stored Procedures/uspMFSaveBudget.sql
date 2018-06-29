CREATE PROCEDURE [dbo].[uspMFSaveBudget]
	@strXml nVarchar(Max)
AS
Begin Try

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @idoc int 
Declare @ErrMsg nVarchar(Max)
Declare @dtmCurrentDate DateTime=GETDATE()

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml

Declare @tblBudget table
(
	intBudgetId int,
	intYear int,
	intLocationId int,
	intItemId int,
	intBudgetTypeId int,
	dblJan numeric(18,6),
	dblFeb numeric(18,6),
	dblMar numeric(18,6),
	dblApr numeric(18,6),
	dblMay numeric(18,6),
	dblJun numeric(18,6),
	dblJul numeric(18,6),
	dblAug numeric(18,6),
	dblSep numeric(18,6),
	dblOct numeric(18,6),
	dblNov numeric(18,6),
	dblDec numeric(18,6),
	intUserId int,
	intConcurrencyId int
)

INSERT INTO @tblBudget(intBudgetId,intYear,intLocationId,
 intItemId,intBudgetTypeId,dblJan,dblFeb,dblMar,dblApr,dblMay,dblJun,dblJul,  
 dblAug,dblSep,dblOct,dblNov,dblDec,intUserId,intConcurrencyId)
 Select intBudgetId,intYear,intLocationId,
 intItemId,intBudgetTypeId,NULLIF(dblJan,''),NULLIF(dblFeb,''),NULLIF(dblMar,''),NULLIF(dblApr,''),NULLIF(dblMay,''),NULLIF(dblJun,''),NULLIF(dblJul,''),  
 NULLIF(dblAug,''),NULLIF(dblSep,''),NULLIF(dblOct,''),NULLIF(dblNov,''),NULLIF(dblDec,''),intUserId,intConcurrencyId
 FROM OPENXML(@idoc, 'root/budget', 2)  
 WITH (
		intBudgetId int,
		intYear int,
		intLocationId int,
		intItemId int,
		intBudgetTypeId int,
		dblJan nvarchar(50),
		dblFeb nvarchar(50),
		dblMar nvarchar(50),
		dblApr nvarchar(50),
		dblMay nvarchar(50),
		dblJun nvarchar(50),
		dblJul nvarchar(50),
		dblAug nvarchar(50),
		dblSep nvarchar(50),
		dblOct nvarchar(50),
		dblNov nvarchar(50),
		dblDec nvarchar(50),
		intUserId int,
		intConcurrencyId int
	)

If Exists (Select 1 From tblMFBudget bg Join @tblBudget tbg on bg.intBudgetId=tbg.intBudgetId Where bg.intConcurrencyId > tbg.intConcurrencyId And bg.intBudgetId > 0)
Begin
	RaisError('Budget data already modified by other user. Please refresh.',16,1)
End

Begin Tran

Insert Into tblMFBudget(intYear,intLocationId,
 intItemId,intBudgetTypeId,dblJan,dblFeb,dblMar,dblApr,dblMay,dblJun,dblJul,  
 dblAug,dblSep,dblOct,dblNov,dblDec,intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified,intConcurrencyId)
 Select intYear,intLocationId,
 intItemId,intBudgetTypeId,dblJan,dblFeb,dblMar,dblApr,dblMay,dblJun,dblJul,  
 dblAug,dblSep,dblOct,dblNov,dblDec,intUserId,@dtmCurrentDate,intUserId,@dtmCurrentDate,intConcurrencyId + 1 
 From @tblBudget Where ISNULL(intBudgetId,0)=0

 Update bg Set bg.dblJan=tbg.dblJan,
 bg.dblFeb=tbg.dblFeb,
 bg.dblMar=tbg.dblMar,
 bg.dblApr=tbg.dblApr,
 bg.dblMay=tbg.dblMay,
 bg.dblJun=tbg.dblJun,
 bg.dblJul=tbg.dblJul,
 bg.dblAug=tbg.dblAug,
 bg.dblSep=tbg.dblSep,
 bg.dblOct=tbg.dblOct,
 bg.dblNov=tbg.dblNov,
 bg.dblDec=tbg.dblDec, 
 bg.intLastModifiedUserId=tbg.intUserId,
 bg.dtmLastModified=@dtmCurrentDate,
 bg.intConcurrencyId=tbg.intConcurrencyId + 1
 From tblMFBudget bg Join @tblBudget tbg on bg.intBudgetId=tbg.intBudgetId Where bg.intBudgetId > 0

Commit Tran

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
END CATCH	
