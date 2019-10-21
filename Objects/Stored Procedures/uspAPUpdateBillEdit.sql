CREATE PROCEDURE [dbo].[uspAPUpdateBillEdit]
	@billId NVARCHAR(MAX),
	@userId INT	= NULL,
	@all BIT = 0,
	@add BIT = 0
AS

BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ids AS Id;
	DECLARE @billCount INT;

	INSERT INTO @ids
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@billId)

	SELECT @billCount = COUNT(*) FROM @ids

	--FILTER BILL ID
	--EXCLUDE voucher with contract
	--EXCLUDE voucher if vendor have restrict the term setup, if not should be valid
	-- DELETE A
	-- FROM @ids A
	-- INNER JOIN tblAPBill A2 ON A.intId = A2.intBillId
	-- CROSS APPLY tblAPBillEditField A3
	-- OUTER APPLY (
	-- 	SELECT TOP 1 intContractDetailId FROM tblAPBillDetail B 
	-- 	WHERE 
	-- 		B.intBillId = A.intId 
	-- 	AND B.intContractDetailId > 0
	-- ) details
	-- OUTER APPLY (
	-- 	SELECT C.intTermId, restrictedTerm.intCount FROM tblAPVendorTerm C 
	-- 	OUTER APPLY (
	-- 		SELECT COUNT(*) intCount FROM tblAPVendorTerm C2 WHERE C2.intEntityVendorId = A2.intEntityVendorId
	-- 	) restrictedTerm
	-- 	WHERE 
	-- 		C.intEntityVendorId = A2.intEntityVendorId
	-- ) vendorTerm
	-- WHERE
	-- 	details.intContractDetailId > 0
	-- OR (vendorTerm.intTermId = A3.intTermsId AND vendorTerm.intCount > 0)
	-- OR (vendorTerm.intTermId IS NULL AND vendorTerm.intCount = 0)

	IF @add = 1
	BEGIN
		IF @billCount > 0
		BEGIN
			INSERT INTO tblAPBillEdit(intBillId, intEntityId, strField)
			SELECT
				intId,
				@userId,
				'strField'
			FROM @ids
		END
		-- ELSE
		-- BEGIN
		-- 	INSERT INTO tblAPBillEdit(intBillId, intEntityId, strField)
		-- 	SELECT
		-- 		A.intBillId,
		-- 		@userId,
		-- 		'strField'
		-- 	FROM vyuAPVoucherForEdit A
		-- 	WHERE A.ysnSelected = 0
		-- END
	END
	ELSE
	BEGIN
		IF @all = 0 AND @billCount > 0
		BEGIN
			DELETE A
			FROM tblAPBillEdit A
			INNER JOIN @ids B ON A.intBillId = B.intId AND A.intEntityId = @userId
		END
		ELSE
		BEGIN
			DELETE A
			FROM tblAPBillEdit A
			WHERE A.intEntityId = @userId
		END
	END
END