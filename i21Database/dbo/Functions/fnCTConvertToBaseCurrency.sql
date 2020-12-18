CREATE FUNCTION [dbo].[fnCTConvertToBaseCurrency](  
 @MainCurrencyId INT  
 ,@Amount NUMERIC(38, 20)  
)  
RETURNS NUMERIC(38,20)  
AS   
BEGIN   
 DECLARE @CurrencyId INT  
  ,@SubCurrency BIT  
  ,@Cent   INT  
  
 SELECT  
   @CurrencyId = [intCurrencyID]  
  ,@SubCurrency  = [ysnSubCurrency]  
  ,@Cent    = [intCent]  
 FROM  
  tblSMCurrency  
 WHERE  
  [intMainCurrencyId] = @MainCurrencyId  
    
  
 IF ISNULL(@SubCurrency,0) = 0  
  RETURN @Amount  
    
 IF @CurrencyId = @MainCurrencyId  
  RETURN @Amount  
    
 IF @CurrencyId <> @MainCurrencyId AND ISNULL(@Cent,0) <> 0  
  RETURN @Amount/@Cent  
    
 RETURN @Amount  
END