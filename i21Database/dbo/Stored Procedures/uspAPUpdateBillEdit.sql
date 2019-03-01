CREATE PROCEDURE [dbo].[uspAPUpdateBillEdit]
	@billId INT,
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

	IF @add = 1
	BEGIN
		IF @all = 0 AND @billId > 0
		BEGIN
			INSERT INTO tblAPBillEdit(intBillId, intEntityId, strField)
			VALUES(@billId, @userId, 'strField')
		END
		ELSE
		BEGIN
			INSERT INTO tblAPBillEdit(intBillId, intEntityId, strField)
			SELECT
				A.intBillId,
				@userId,
				'strField'
			FROM vyuAPVoucherForEdit A
			WHERE A.ysnSelected = 0
		END
	END
	ELSE
	BEGIN
		IF @all = 0 AND @billId > 0
		BEGIN
			DELETE A
			FROM tblAPBillEdit A
			WHERE A.intBillId = @billId AND A.intEntityId = @userId
		END
		ELSE
		BEGIN
			DELETE A
			FROM tblAPBillEdit A
			WHERE A.intEntityId = @userId
		END
	END
END