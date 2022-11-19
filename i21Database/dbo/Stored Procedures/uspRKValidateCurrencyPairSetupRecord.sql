CREATE PROCEDURE [dbo].[uspRKValidateCurrencyPairSetupRecord]
	@intCurrencyPairId INT = NULL,
	@intFromCurrencyId INT = NULL,
	@intToCurrencyId INT = NULL
AS

BEGIN TRY
DECLARE @ErrMsg1 NVARCHAR(MAX)
	, @strFromCurrency NVARCHAR(100)
	, @strToCurrency NVARCHAR(100)

IF @intFromCurrencyId = @intToCurrencyId
BEGIN
	SELECT @ErrMsg1 = 'From and To Currency cannot have same value.'

	RAISERROR(@ErrMsg1, 16,1)
	RETURN
END 
  
IF EXISTS (SELECT TOP 1 1 FROM vyuRKCurrencyPairSetup
			WHERE intFromCurrencyId = @intFromCurrencyId 
			AND intToCurrencyId = @intToCurrencyId
			AND intCurrencyPairId <> ISNULL(@intCurrencyPairId, intCurrencyPairId)
		)
BEGIN
	SELECT TOP 1 
		  @strFromCurrency = strFromCurrency 
		, @strToCurrency = strToCurrency
	FROM vyuRKCurrencyPairSetup
	WHERE intFromCurrencyId = @intFromCurrencyId 
	AND intToCurrencyId = @intToCurrencyId
	AND intCurrencyPairId <> ISNULL(@intCurrencyPairId, intCurrencyPairId)

	SELECT @ErrMsg1 = 'From (' + @strFromCurrency + ') and To(' + @strToCurrency + ') Currency Pair Setup is already existing.'

	RAISERROR(@ErrMsg1, 16,1)
	RETURN
END

END TRY
BEGIN CATCH  
	SET @ErrMsg1 = ERROR_MESSAGE()  
	If @ErrMsg1 != ''   
	BEGIN  
		RAISERROR(@ErrMsg1, 16, 1, 'WITH NOWAIT')  
	END  
END CATCH 