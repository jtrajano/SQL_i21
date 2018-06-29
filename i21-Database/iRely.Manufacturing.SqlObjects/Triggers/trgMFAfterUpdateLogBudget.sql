CREATE TRIGGER [dbo].[trgMFAfterUpdateLogBudget]
    ON [dbo].[tblMFBudget]
    AFTER UPDATE
    AS
    BEGIN
        SET NoCount ON

		Declare @intYear INT,
				@intLocationId INT,
				@intItemId INT,
				@intBudgetTypeId INT,
				@intUserId INT,
				@dtmCurrentDate DATETIME=GETDATE(),
				@strNote nvarchar(max),
				@strItemNo nvarchar(50),
				@strBudgetTypeDesc nvarchar(100)

		Declare @dblOldJan numeric(18,6),
				@dblOldFeb numeric(18,6),
				@dblOldMar numeric(18,6),
				@dblOldApr numeric(18,6),
				@dblOldMay numeric(18,6),
				@dblOldJun numeric(18,6),
				@dblOldJul numeric(18,6),
				@dblOldAug numeric(18,6),
				@dblOldSep numeric(18,6),
				@dblOldOct numeric(18,6),
				@dblOldNov numeric(18,6),
				@dblOldDec numeric(18,6)

		Declare @dblNewJan numeric(18,6),
				@dblNewFeb numeric(18,6),
				@dblNewMar numeric(18,6),
				@dblNewApr numeric(18,6),
				@dblNewMay numeric(18,6),
				@dblNewJun numeric(18,6),
				@dblNewJul numeric(18,6),
				@dblNewAug numeric(18,6),
				@dblNewSep numeric(18,6),
				@dblNewOct numeric(18,6),
				@dblNewNov numeric(18,6),
				@dblNewDec numeric(18,6)

		Select @dblOldJan=ISNULL(dblJan,0),
				@dblOldFeb=ISNULL(dblFeb,0),
				@dblOldMar=ISNULL(dblMar,0),
				@dblOldApr=ISNULL(dblApr,0),
				@dblOldMay=ISNULL(dblMay,0),
				@dblOldJun=ISNULL(dblJun,0),
				@dblOldJul=ISNULL(dblJul,0),
				@dblOldAug=ISNULL(dblAug,0),
				@dblOldSep=ISNULL(dblSep,0),
				@dblOldOct=ISNULL(dblOct,0),
				@dblOldNov=ISNULL(dblNov,0),
				@dblOldDec=ISNULL(dblDec,0),
				@intYear=intYear,
				@intLocationId=intLocationId,
				@intItemId=intItemId,
				@intBudgetTypeId=intBudgetTypeId,
				@intUserId=intLastModifiedUserId
		 From deleted

		 		Select @dblNewJan=ISNULL(dblJan,0),
				@dblNewFeb=ISNULL(dblFeb,0),
				@dblNewMar=ISNULL(dblMar,0),
				@dblNewApr=ISNULL(dblApr,0),
				@dblNewMay=ISNULL(dblMay,0),
				@dblNewJun=ISNULL(dblJun,0),
				@dblNewJul=ISNULL(dblJul,0),
				@dblNewAug=ISNULL(dblAug,0),
				@dblNewSep=ISNULL(dblSep,0),
				@dblNewOct=ISNULL(dblOct,0),
				@dblNewNov=ISNULL(dblNov,0),
				@dblNewDec=ISNULL(dblDec,0)
		 From tblMFBudget Where intYear=@intYear AND intLocationId=@intLocationId AND intItemId=@intItemId AND intBudgetTypeId=@intBudgetTypeId

		 Select @strItemNo=strItemNo From tblICItem Where intItemId=@intItemId
		 Select @strBudgetTypeDesc=strDescription From tblMFBudgetType Where intBudgetTypeId=@intBudgetTypeId
		 Select @strNote='Adjustment to Item - ' + @strItemNo + ' - ' + @strBudgetTypeDesc

		IF ISNULL(@dblOldJan,0) <> ISNULL(@dblNewJan,0)
			INSERT INTO tblMFBudgetLog(intYear,intLocationId,strNote,intItemId,intBudgetTypeId,strMonth,dblOldValue,dblNewValue,intLastModifiedUserId,dtmLastModified)
			Select @intYear,@intLocationId,@strNote,@intItemId,@intBudgetTypeId,'Jan',@dblOldJan,@dblNewJan,@intUserId,@dtmCurrentDate

		IF ISNULL(@dblOldFeb,0) <> ISNULL(@dblNewFeb,0)
			INSERT INTO tblMFBudgetLog(intYear,intLocationId,strNote,intItemId,intBudgetTypeId,strMonth,dblOldValue,dblNewValue,intLastModifiedUserId,dtmLastModified)
			Select @intYear,@intLocationId,@strNote,@intItemId,@intBudgetTypeId,'Feb',@dblOldFeb,@dblNewFeb,@intUserId,@dtmCurrentDate		 

		IF ISNULL(@dblOldMar,0) <> ISNULL(@dblNewMar,0)
			INSERT INTO tblMFBudgetLog(intYear,intLocationId,strNote,intItemId,intBudgetTypeId,strMonth,dblOldValue,dblNewValue,intLastModifiedUserId,dtmLastModified)
			Select @intYear,@intLocationId,@strNote,@intItemId,@intBudgetTypeId,'Mar',@dblOldMar,@dblNewMar,@intUserId,@dtmCurrentDate

		IF ISNULL(@dblOldApr,0) <> ISNULL(@dblNewApr,0)
			INSERT INTO tblMFBudgetLog(intYear,intLocationId,strNote,intItemId,intBudgetTypeId,strMonth,dblOldValue,dblNewValue,intLastModifiedUserId,dtmLastModified)
			Select @intYear,@intLocationId,@strNote,@intItemId,@intBudgetTypeId,'Apr',@dblOldApr,@dblNewApr,@intUserId,@dtmCurrentDate

		IF ISNULL(@dblOldMay,0) <> ISNULL(@dblNewMay,0)
			INSERT INTO tblMFBudgetLog(intYear,intLocationId,strNote,intItemId,intBudgetTypeId,strMonth,dblOldValue,dblNewValue,intLastModifiedUserId,dtmLastModified)
			Select @intYear,@intLocationId,@strNote,@intItemId,@intBudgetTypeId,'May',@dblOldMay,@dblNewMay,@intUserId,@dtmCurrentDate

		IF ISNULL(@dblOldJun,0) <> ISNULL(@dblNewJun,0)
			INSERT INTO tblMFBudgetLog(intYear,intLocationId,strNote,intItemId,intBudgetTypeId,strMonth,dblOldValue,dblNewValue,intLastModifiedUserId,dtmLastModified)
			Select @intYear,@intLocationId,@strNote,@intItemId,@intBudgetTypeId,'Jun',@dblOldJun,@dblNewJun,@intUserId,@dtmCurrentDate

		IF ISNULL(@dblOldJul,0) <> ISNULL(@dblNewJul,0)
			INSERT INTO tblMFBudgetLog(intYear,intLocationId,strNote,intItemId,intBudgetTypeId,strMonth,dblOldValue,dblNewValue,intLastModifiedUserId,dtmLastModified)
			Select @intYear,@intLocationId,@strNote,@intItemId,@intBudgetTypeId,'Jul',@dblOldJul,@dblNewJul,@intUserId,@dtmCurrentDate

		IF ISNULL(@dblOldAug,0) <> ISNULL(@dblNewAug,0)
			INSERT INTO tblMFBudgetLog(intYear,intLocationId,strNote,intItemId,intBudgetTypeId,strMonth,dblOldValue,dblNewValue,intLastModifiedUserId,dtmLastModified)
			Select @intYear,@intLocationId,@strNote,@intItemId,@intBudgetTypeId,'Aug',@dblOldAug,@dblNewAug,@intUserId,@dtmCurrentDate

		IF ISNULL(@dblOldSep,0) <> ISNULL(@dblNewSep,0)
			INSERT INTO tblMFBudgetLog(intYear,intLocationId,strNote,intItemId,intBudgetTypeId,strMonth,dblOldValue,dblNewValue,intLastModifiedUserId,dtmLastModified)
			Select @intYear,@intLocationId,@strNote,@intItemId,@intBudgetTypeId,'Sep',@dblOldSep,@dblNewSep,@intUserId,@dtmCurrentDate

		IF ISNULL(@dblOldOct,0) <> ISNULL(@dblNewOct,0)
			INSERT INTO tblMFBudgetLog(intYear,intLocationId,strNote,intItemId,intBudgetTypeId,strMonth,dblOldValue,dblNewValue,intLastModifiedUserId,dtmLastModified)
			Select @intYear,@intLocationId,@strNote,@intItemId,@intBudgetTypeId,'Oct',@dblOldOct,@dblNewOct,@intUserId,@dtmCurrentDate

		IF ISNULL(@dblOldNov,0) <> ISNULL(@dblNewNov,0)
			INSERT INTO tblMFBudgetLog(intYear,intLocationId,strNote,intItemId,intBudgetTypeId,strMonth,dblOldValue,dblNewValue,intLastModifiedUserId,dtmLastModified)
			Select @intYear,@intLocationId,@strNote,@intItemId,@intBudgetTypeId,'Nov',@dblOldNov,@dblNewNov,@intUserId,@dtmCurrentDate

		IF ISNULL(@dblOldDec,0) <> ISNULL(@dblNewDec,0)
			INSERT INTO tblMFBudgetLog(intYear,intLocationId,strNote,intItemId,intBudgetTypeId,strMonth,dblOldValue,dblNewValue,intLastModifiedUserId,dtmLastModified)
			Select @intYear,@intLocationId,@strNote,@intItemId,@intBudgetTypeId,'Dec',@dblOldDec,@dblNewDec,@intUserId,@dtmCurrentDate

    END