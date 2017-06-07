CREATE PROCEDURE [dbo].[uspPOCreateApprover]
	@poId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @approverListId INT;
DECLARE @approverCursor AS CURSOR;
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

SELECT
	@approverListId = ISNULL(A.intApprovalListId, C.intApprovalListId)
FROM tblAPVendor A
INNER JOIN tblPOPurchase B ON A.[intEntityId] = B.intEntityVendorId
OUTER APPLY tblAPCompanyPreference C
WHERE B.intPurchaseId = @poId AND B.ysnForApproval = 1

IF @approverListId IS NULL OR @approverListId <= 0 RAISERROR('Please setup approver either in vendor or company configuration.', 16, 1);

DELETE FROM tblPOApprover WHERE intPurchaseId = @poId;

INSERT INTO tblPOApprover
(
	[intPurchaseId]				, 
	[intApproverId]				,
	[intAlternateApproverId]	, 
	[ysnApproved]				, 
	[intApproverLevel]			, 
	[dtmDateApproved]			
)
SELECT DISTINCT
	[intPurchaseId]				=	@poId, 
	[intApproverId]				=	A.intEntityUserSecurityId,
	[intAlternateApprover]		=	A.intAlternateEntityUserSecurityId, 
	[ysnApproved]				=	0, 
	[intApproverLevel]			=	A.intApproverLevel,
	[dtmDateApproved]			=	NULL
FROM tblSMApprovalListUserSecurity A
CROSS APPLY tblPOPurchase B
WHERE B.intPurchaseId = @poId
AND 1 = (CASE WHEN B.dblTotal <= A.dblAmountLessThanEqual OR B.dblTotal > A.dblAmountOver THEN 1 ELSE 0 END)
AND A.intApprovalListId = @approverListId
ORDER BY A.intApproverLevel

IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH