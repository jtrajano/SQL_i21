IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICImportInventoryReceipts]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICImportInventoryReceipts]; 
GO

CREATE PROCEDURE [dbo].[uspICImportInventoryReceipts]
	@Checking BIT = 0,
	@UserId INT = 0,
	@Total INT = 0 OUTPUT,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

BEGIN
	-- Create the trigger that creates the receipt id. 
	EXEC uspICImportInventoryReceipts_CreateTrigger; 

	--================================================
	--     ONE TIME INVOICE SYNCHRONIZATION	
	--================================================
	IF (@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0)
	BEGIN
		SET @StartDate = NULL
		SET @EndDate = NULL
	END			
	
	DECLARE @EntityId INT

	SELECT  TOP 1 
			@EntityId = intEntityUserSecurityId 
	FROM	tblSMUserSecurity 
	WHERE	intEntityUserSecurityId = @UserId

	DECLARE @ysnAG BIT = 0
    DECLARE @ysnPT BIT = 0

	SELECT	TOP 1 
			@ysnAG = CASE WHEN ISNULL(coctl_ag, '') = 'Y' THEN 1 ELSE 0 END
			, @ysnPT = CASE WHEN ISNULL(coctl_pt, '') = 'Y' THEN 1 ELSE 0 END 
	FROM	coctlmst		

	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agphsmst')
		EXEC uspICImportInventoryReceiptsAG
			@Checking 
			,@EntityId 
			,@Total OUTPUT
			,@StartDate 
			,@EndDate

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptphsmst')
		EXEC uspICImportInventoryReceiptsPT
			@Checking 
			,@EntityId 
			,@Total OUTPUT
			,@StartDate 
			,@EndDate
				 			
	IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trgReceiptNumber]'))
		DROP TRIGGER [dbo].trgReceiptNumber		  		
END