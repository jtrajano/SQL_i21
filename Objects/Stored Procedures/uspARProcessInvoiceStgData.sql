CREATE PROCEDURE uspARProcessInvoiceStgData
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intId INT
	DECLARE @intLoadId INT
	DECLARE @intLoadRefId INT
	DECLARE @strInvoiceNumber NVARCHAR(100)
	DECLARE @intToBookId INT
	DECLARE @intBillId INT
	DECLARE @intEntityUserSecurityId INT = 1

	SELECT @intId = MIN(intStgId)
	FROM tblARIntrCompanyInvoiceStg
	WHERE strFeedStatus IS NULL

	WHILE ISNULL(@intId, 0) > 0
	BEGIN
		SET @intLoadId = NULL
		SET @intLoadRefId = NULL
		SET @strInvoiceNumber = NULL

		SELECT @intLoadId = intLoadId
			,@strInvoiceNumber = strInvoiceNumber
			,@intToBookId = intToBookId
		FROM tblARIntrCompanyInvoiceStg
		WHERE intStgId = @intId

		SELECT @intLoadRefId = intLoadId
		FROM tblLGLoad
		WHERE intLoadRefId = @intLoadId

		EXEC uspLGCreateVoucherForInbound @intLoadId = @intLoadRefId
			,@intEntityUserSecurityId = @intEntityUserSecurityId
			,@intBillId = @intBillId OUTPUT

		UPDATE tblAPBill
		SET strVendorOrderNumber = @strInvoiceNumber,
			intBookId = @intToBookId
		WHERE intBillId = @intBillId

		UPDATE tblARIntrCompanyInvoiceStg
		SET strFeedStatus = 'Processed'
		WHERE intStgId = @intId

		SELECT @intId = MIN(intStgId)
		FROM tblARIntrCompanyInvoiceStg
		WHERE strFeedStatus IS NULL
			AND intStgId > @intId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH