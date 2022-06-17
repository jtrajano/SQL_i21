CREATE PROCEDURE [uspAPUpdateAccountOnPost]
	@param AS NVARCHAR(MAX)	= NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ids Id;

	DECLARE	@OverrideCompanySegment BIT,
			@OverrideLocationSegment BIT,
			@OverrideLineOfBusinessSegment BIT

	SELECT TOP 1 @OverrideCompanySegment = ISNULL([ysnOverrideCompanySegment], 0),
				 @OverrideLocationSegment = ISNULL([ysnOverrideLocationSegment], 0),
				 @OverrideLineOfBusinessSegment = ISNULL([ysnOverrideLineOfBusinessSegment], 0)
	FROM tblAPCompanyPreference

	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION
		INSERT INTO @ids
		SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)

		--DETAIL
		UPDATE BD
		SET BD.intAccountId = OVERRIDESEGMENT.intOverrideAccount
		FROM tblAPBill B
		INNER JOIN @ids ID ON ID.intId = B.intBillId
		INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
		OUTER APPLY (
			SELECT intOverrideAccount
			FROM dbo.[fnARGetOverrideAccount](B.intAccountId, BD.intAccountId, @OverrideCompanySegment, @OverrideLocationSegment, @OverrideLineOfBusinessSegment)
		) OVERRIDESEGMENT

		--TAXES
		UPDATE BDT
		SET BDT.intAccountId = OVERRIDESEGMENT.intOverrideAccount
		FROM tblAPBill B
		INNER JOIN @ids ID ON ID.intId = B.intBillId
		INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
		INNER JOIN tblAPBillDetailTax BDT ON BDT.intBillDetailId = BD.intBillDetailId
		OUTER APPLY (
			SELECT intOverrideAccount
			FROM dbo.[fnARGetOverrideAccount](B.intAccountId, BDT.intAccountId, @OverrideCompanySegment, @OverrideLocationSegment, @OverrideLineOfBusinessSegment)
		) OVERRIDESEGMENT

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