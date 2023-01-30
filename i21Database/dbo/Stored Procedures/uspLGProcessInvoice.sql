﻿CREATE PROCEDURE uspLGProcessInvoice
	@intLoadId INT,
	@intEntityUserSecurityId INT,
	@intType INT = 1, /* 1 - Direct, 2 - Provisional, 3 - Proforma */
	@intBankAccountId INT = NULL,
	@intNewInvoiceId INT OUTPUT
AS	
BEGIN TRY
	DECLARE @intPurchaseSale INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @ysnUnShip BIT
	DECLARE @NewInvoiceId INT
	DECLARE @strErrMsg NVARCHAR(MAX)

	SELECT @intPurchaseSale = intPurchaseSale
		,@strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF @intPurchaseSale = 2
	BEGIN
		EXEC uspLGCreateInvoiceForShipment
				@intLoadId = @intLoadId,
				@intUserId = @intEntityUserSecurityId,
				@intType = @intType,
				@intBankAccountId = @intBankAccountId,
				@NewInvoiceId = @NewInvoiceId OUTPUT
	END
	ELSE IF @intPurchaseSale = 3
	BEGIN
		EXEC uspLGCreateInvoiceForDropShip
				@intLoadId = @intLoadId ,
				@intUserId = @intEntityUserSecurityId,
				@intType = @intType,
				@Post = 0,
				@NewInvoiceId = @NewInvoiceId OUTPUT
	END

	SELECT @intNewInvoiceId = @NewInvoiceId
END TRY
BEGIN CATCH  
  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @strErrMsg = ERROR_MESSAGE()      
 RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')     
  
END CATCH 