CREATE PROCEDURE [dbo].[uspLGInterCompanyTransaction]
	@intLoadId INT,
	@strRowState NVARCHAR(100)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg					NVARCHAR(MAX)
	DECLARE @strFromTransactionType	NVARCHAR(100)
	DECLARE @intFromCompanyId		INT
	DECLARE @intFromProfitCenterId	INT
	DECLARE @strToTransactionType	NVARCHAR(100)
	DECLARE @intToCompanyId			INT
	DECLARE @intToProfitCenterId	INT
	DECLARE @intToEntityId			INT
	DECLARE @strInsert				NVARCHAR(100)
	DECLARE @strUpdate			    NVARCHAR(100)
	DECLARE @intScreenId			INT
	DECLARE @intShipmentType		INT
	DECLARE @strShipmentType		NVARCHAR(200)
	DECLARE @intPurchaseSale		INT
	DECLARE @strPurchaseSale		NVARCHAR(200)
	DECLARE @strTransactionType		NVARCHAR(100)
	DECLARE @intToCompanyLocationId	INT
	DECLARE @intToBookId			INT
	DECLARE @intToSubBookId			INT

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblLGLoad WHERE intLoadId = @intLoadId)
	BEGIN
		RETURN;
	END

	SELECT @intPurchaseSale = intPurchaseSale
		,@strPurchaseSale = CASE intPurchaseSale
			WHEN 1
				THEN 'Inbound'
			WHEN 2
				THEN 'Outbound'
			WHEN 3
				THEN 'Drop Ship'
			END
		,@intShipmentType = intShipmentType
		,@strShipmentType = CASE intShipmentType
			WHEN 1
				THEN 'Shipment'
			WHEN 2
				THEN 'Shipping Instruction'
			WHEN 3
				THEN 'Vessel Nomination'
			ELSE ''
			END
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	SET @strTransactionType = @strPurchaseSale + ' ' + @strShipmentType

	IF EXISTS (
			SELECT 1
			FROM tblSMInterCompanyTransactionConfiguration CTC
			JOIN [tblSMInterCompanyTransactionType] CTTF ON CTC.[intFromTransactionTypeId] = CTTF.intInterCompanyTransactionTypeId
			JOIN [tblSMInterCompanyTransactionType] CTTT ON CTC.[intToTransactionTypeId] = CTTT.intInterCompanyTransactionTypeId
			WHERE CTTF.strTransactionType = @strTransactionType
			)
	BEGIN

		SELECT 
			@strFromTransactionType = CTTF.strTransactionType --strFromTransactionType
			,@intFromCompanyId = intFromCompanyId
			,@intFromProfitCenterId = intFromBookId
			,@strToTransactionType = CTTT.strTransactionType
			,@intToCompanyId = intToCompanyId
			,@intToProfitCenterId = intToBookId
			,@strInsert = strInsert
			,@strUpdate = strUpdate
			,@intToCompanyLocationId = intCompanyLocationId
			,@intToBookId = intToBookId
			,@intToSubBookId = @intToSubBookId
		FROM tblSMInterCompanyTransactionConfiguration CTC
		JOIN [tblSMInterCompanyTransactionType] CTTF ON CTC.[intFromTransactionTypeId] = CTTF.intInterCompanyTransactionTypeId -- WHERE strFromTransactionType = @strTransactionType
		JOIN [tblSMInterCompanyTransactionType] CTTT ON CTC.[intToTransactionTypeId] = CTTT.intInterCompanyTransactionTypeId -- WHERE strFromTransactionType = @strTransactionType
		WHERE CTTF.strTransactionType = @strTransactionType

	 --    SELECT 
		-- @strFromTransactionType = strFromTransactionType 
		--,@intFromCompanyId		 = intFromCompanyId		 
		--,@intFromProfitCenterId	 = intFromProfitCenterId	 
		--,@strToTransactionType	 = strToTransactionType	 
		--,@intToCompanyId		 = intToCompanyId		 
		--,@intToProfitCenterId	 = intToProfitCenterId	 
		--,@intToEntityId			 = intToEntityId			 
		--,@strInsert				 = strInsert				 
		--,@strUpdate			   	 = strUpdate
		--FROM tblSMInterCompanyTransactionConfiguration WHERE strFromTransactionType = @strTransactionType
		
		IF @strInsert = 'Insert' AND @strRowState = 'Added'
		BEGIN
			IF EXISTS(SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND intConcurrencyId =1)
			BEGIN
			      EXEC uspLGPopulateLoadXML @intLoadId,
											@strToTransactionType,
											@intToCompanyId,
											@strRowState,
											@intToCompanyLocationId,
											@intToBookId
			END
		END
		
		IF @strUpdate = 'Update' AND @strRowState = 'Modified'
		BEGIN
			IF EXISTS(SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId)
			BEGIN
			      EXEC uspLGPopulateLoadUpdateXML @intLoadId,
												  @strToTransactionType,
												  @intToCompanyId,
												  @strRowState
			END
		END
	END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH