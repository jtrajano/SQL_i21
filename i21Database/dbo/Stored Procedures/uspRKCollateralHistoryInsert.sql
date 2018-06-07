CREATE PROCEDURE uspRKCollateralHistoryInsert
	 @intCollateralId INT
	,@action NVARCHAR(20)
	,@userId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION 



-- Create the entry for Collateral History
IF @action = 'ADD' OR @action = 'DELETE'
BEGIN
	INSERT INTO tblRKCollateralHistory(
		 intCollateralId
		,intReceiptNo
		,dtmOpenDate
		,strType
		,intCommodityId
		,intLocationId
		,strCustomer
		,dblOldOriginalQuantity
		,dblOriginalQuantity
		,dblRemainingQuantity
		,intUnitMeasureId
		,intContractHeaderId
		,intTransNo
		,strComments
		,intCollateralAdjustmentId
		,dtmOldAdjustmentDate
		,dtmAdjustmentDate
		,dblOldAdjustmentAmount
		,dblAdjustmentAmount
		,strAdjustmentNo
		,dtmTransactionDate
		,strUserName
		,strAction

	)
	SELECT
		 C.intCollateralId
		,C.intReceiptNo
		,C.dtmOpenDate
		,C.strType
		,C.intCommodityId
		,C.intLocationId
		,C.strCustomer
		,NULL --dblOldOriginalQuantity set to null when newly added and delete 
		,CASE WHEN @action = 'ADD' THEN C.dblOriginalQuantity ELSE 0 END --Set the 0 if the action is delete
		,CASE WHEN @action = 'ADD' THEN C.dblRemainingQuantity ELSE 0 END --Set the 0 if the action is delete 
		,C.intUnitMeasureId
		,C.intContractHeaderId
		,C.intTransNo
		,C.strComments 	
		,CA.intCollateralAdjustmentId
		,NULL --dtmOldAdjustmentDate set to null when newly added and delete
		,CA.dtmAdjustmentDate
		,NULL --dblOldAdjustmentAmount set to null when newly added and delete
		,CASE WHEN @action = 'ADD' THEN CA.dblAdjustmentAmount ELSE 0 END --Set the to 0 if the action is delete
		,CA.strAdjustmentNo
		,GETDATE()
		,(SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = @userId)
		,@action
	FROM 
	tblRKCollateral C
	LEFT JOIN tblRKCollateralAdjustment CA ON C.intCollateralId = CA.intCollateralId
	WHERE C.intCollateralId = @intCollateralId

	IF @@ERROR <> 0	GOTO _Rollback
END
ELSE IF @action = 'UPDATE'
BEGIN

	--Check if there are newly added detail record
	DECLARE @newDetailCount AS INT

	SELECT	
		@newDetailCount =  COUNT(CA.intCollateralAdjustmentId)
	FROM 
	tblRKCollateral C
	INNER JOIN tblRKCollateralAdjustment CA ON C.intCollateralId = CA.intCollateralId
	WHERE C.intCollateralId = @intCollateralId
		AND intCollateralAdjustmentId NOT IN (SELECT intCollateralAdjustmentId FROM tblRKCollateralHistory)

	IF @newDetailCount > 0 --Newly added detail record
	BEGIN
		INSERT INTO tblRKCollateralHistory(
			 intCollateralId
			,intReceiptNo
			,dtmOpenDate
			,strType
			,intCommodityId
			,intLocationId
			,strCustomer
			,dblOldOriginalQuantity
			,dblOriginalQuantity
			,dblRemainingQuantity
			,intUnitMeasureId
			,intContractHeaderId
			,intTransNo
			,strComments
			,intCollateralAdjustmentId
			,dtmOldAdjustmentDate
			,dtmAdjustmentDate
			,dblOldAdjustmentAmount
			,dblAdjustmentAmount
			,strAdjustmentNo
			,dtmTransactionDate
			,strUserName
			,strAction

		)
		SELECT
			 C.intCollateralId
			,C.intReceiptNo
			,C.dtmOpenDate
			,C.strType
			,C.intCommodityId
			,C.intLocationId
			,C.strCustomer
			,NULL --dblOldOriginalQuantity set to null when newly added and delete 
			, C.dblOriginalQuantity 
			,C.dblRemainingQuantity
			,C.intUnitMeasureId
			,C.intContractHeaderId
			,C.intTransNo
			,C.strComments 	
			,CA.intCollateralAdjustmentId
			,NULL --dtmOldAdjustmentDate set to null when newly added and delete
			,CA.dtmAdjustmentDate
			,NULL --dblOldAdjustmentAmount set to null when newly added and delete
			,CA.dblAdjustmentAmount
			,CA.strAdjustmentNo
			,GETDATE()
			,(SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = @userId)
			,'ADD'
		FROM 
		tblRKCollateral C
		INNER JOIN tblRKCollateralAdjustment CA ON C.intCollateralId = CA.intCollateralId
		WHERE C.intCollateralId = @intCollateralId 
			AND intCollateralAdjustmentId NOT IN (SELECT intCollateralAdjustmentId FROM tblRKCollateralHistory)
	
		IF @@ERROR <> 0	GOTO _Rollback
		
	END
	ELSE --For Update
		INSERT INTO tblRKCollateralHistory(
			 intCollateralId
			,intReceiptNo
			,dtmOpenDate
			,strType
			,intCommodityId
			,intLocationId
			,strCustomer
			,dblOldOriginalQuantity
			,dblOriginalQuantity
			,dblRemainingQuantity
			,intUnitMeasureId
			,intContractHeaderId
			,intTransNo
			,strComments
			,intCollateralAdjustmentId
			,dtmOldAdjustmentDate
			,dtmAdjustmentDate
			,dblOldAdjustmentAmount
			,dblAdjustmentAmount
			,strAdjustmentNo
			,dtmTransactionDate
			,strUserName
			,strAction

		)
		SELECT
			 C.intCollateralId
			,C.intReceiptNo
			,C.dtmOpenDate
			,C.strType
			,C.intCommodityId
			,C.intLocationId
			,C.strCustomer
			,(SELECT TOP 1 dblOriginalQuantity from tblRKCollateralHistory WHERE intCollateralAdjustmentId = CA.intCollateralAdjustmentId ORDER BY dtmTransactionDate DESC) --get the history value
			,C.dblOriginalQuantity
			,C.dblRemainingQuantity
			,C.intUnitMeasureId
			,C.intContractHeaderId
			,C.intTransNo
			,C.strComments 	
			,CA.intCollateralAdjustmentId
			,(SELECT TOP 1 dtmAdjustmentDate from tblRKCollateralHistory WHERE intCollateralAdjustmentId = CA.intCollateralAdjustmentId ORDER BY dtmTransactionDate DESC) --get the history value
			,CA.dtmAdjustmentDate
			,(SELECT TOP 1 dblAdjustmentAmount from tblRKCollateralHistory WHERE intCollateralAdjustmentId = CA.intCollateralAdjustmentId ORDER BY dtmTransactionDate DESC) --get the history value
			,CA.dblAdjustmentAmount
			,CA.strAdjustmentNo
			,GETDATE()
			,(SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = @userId)
			,'UPDATE'
		FROM 
		tblRKCollateral C
		LEFT JOIN tblRKCollateralAdjustment CA ON C.intCollateralId = CA.intCollateralId
		WHERE C.intCollateralId = @intCollateralId
	
		IF @@ERROR <> 0	GOTO _Rollback
END

	

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
_Commit:
	COMMIT TRANSACTION
	GOTO _Exit
	
_Rollback:
	ROLLBACK TRANSACTION

_Exit: