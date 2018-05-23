CREATE PROCEDURE [dbo].[uspGRUnPostUnPricedSpotTicket]
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intUnPricedId INT
	DECLARE @UserId INT
	DECLARE @strTicketType NVARCHAR(50)
	DECLARE @intBillKey INT
	DECLARE @intBillId INT
	DECLARE @intInvoiceKey INT
	DECLARE @intInvoiceId INT	
	DECLARE @tblBill AS TABLE 
	(
		 intBillKey INT IDENTITY(1, 1)
		,intBillId INT NULL
	)
	DECLARE @tblInvoice AS TABLE 
	(
		 intInvoiceKey INT IDENTITY(1, 1)
		,intInvoiceId INT NULL
	)

	EXEC sp_xml_preparedocument @idoc OUTPUT,@strXml

	SELECT @intUnPricedId = intUnPricedId
		  ,@UserId = intEntityUserSecurityId
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(
			 intUnPricedId INT
			,intEntityUserSecurityId INT
	)

	SELECT @strTicketType = strTicketType
	FROM tblGRUnPriced
	WHERE intUnPricedId = @intUnPricedId

	IF @strTicketType = 'Inbound'
	BEGIN
		INSERT INTO @tblBill (intBillId)
		SELECT DISTINCT intBillId
		FROM tblGRUnPricedSpotTicket
		WHERE intUnPricedId = @intUnPricedId

		SELECT @intBillKey = MIN(intBillKey)
		FROM @tblBill

		WHILE @intBillKey > 0
		BEGIN
			SET @intBillId = NULL

			SELECT @intBillId = intBillId
			FROM @tblBill
			WHERE intBillKey = @intBillKey

			IF EXISTS (
					SELECT 1
					FROM tblAPBill
					WHERE intBillId = @intBillId
						AND ISNULL(ysnPosted, 0) = 1
					)
			BEGIN
				EXEC uspAPPostBill @post = 0
					,@recap = 0
					,@isBatch = 0
					,@param = @intBillId
					,@userId = @UserId
			END

			BEGIN
				EXEC uspAPDeleteVoucher @intBillId
					,@UserId
			END

			SELECT @intBillKey = MIN(intBillKey)
			FROM @tblBill
			WHERE intBillKey > @intBillKey
		END
		
	END
	ELSE
	BEGIN
		INSERT INTO @tblInvoice (intInvoiceId)
		SELECT DISTINCT intInvoiceId
		FROM tblGRUnPricedSpotTicket
		WHERE intUnPricedId = @intUnPricedId

		SELECT @intInvoiceKey = MIN(intInvoiceKey)
		FROM @tblInvoice

		WHILE @intInvoiceKey > 0
		BEGIN
			SET @intInvoiceId = NULL

			SELECT @intInvoiceId = intInvoiceId
			FROM @tblInvoice
			WHERE intInvoiceKey = @intInvoiceKey

			--IF EXISTS (
			--	SELECT 1
			--	FROM tblAPBill
			--	WHERE intInvoiceId = @intInvoiceId AND ISNULL(ysnPosted, 0) = 1
			--  )
			--	BEGIN
			--		EXEC uspAPPostBill 
			--			 @post = 0
			--			,@recap = 0
			--			,@isBatch = 0
			--			,@param = @intInvoiceId
			--			,@userId = @UserId
			--	END						
			EXEC uspARDeleteInvoice @intInvoiceId
				,@UserId

			SELECT @intInvoiceKey = MIN(intInvoiceKey)
			FROM @tblInvoice
			WHERE intInvoiceKey > @intInvoiceKey
		END

	END

	UPDATE SC
	SET dblUnitPrice = 0
		,dblUnitBasis = 0
	FROM tblGRUnPricedSpotTicket SpotTicket
	JOIN tblSCTicket SC ON SC.intTicketId = SpotTicket.intTicketId
	WHERE SpotTicket.intUnPricedId = @intUnPricedId

	UPDATE tblGRUnPriced 
	SET ysnPosted = 0
	WHERE intUnPricedId = @intUnPricedId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
