CREATE PROCEDURE [dbo].[uspGRItemsSettlementReport]
	@intEntityId INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @ysnShowOpenContract BIT
			, @ysnShowStorage BIT
	SELECT @ysnShowStorage = ysnShowStorage
			, @ysnShowOpenContract = ysnShowOpenContract
	FROM tblGRCompanyPreference

	IF @ysnShowStorage = 1 AND @ysnShowOpenContract = 1				
		SELECT * FROM vyuGRItemsSettlementStorageReport WHERE intEntityVendorId = @intEntityId
		UNION ALL
		SELECT * FROM vyuGRItemsSettlementOpenContractReport WHERE intEntityId = @intEntityId
	ELSE IF @ysnShowStorage = 1 AND @ysnShowOpenContract = 0
		SELECT * FROM vyuGRItemsSettlementStorageReport WHERE intEntityVendorId = @intEntityId
	ELSE IF @ysnShowStorage = 0 AND @ysnShowOpenContract = 1
		SELECT * FROM vyuGRItemsSettlementOpenContractReport WHERE intEntityId = @intEntityId	
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH