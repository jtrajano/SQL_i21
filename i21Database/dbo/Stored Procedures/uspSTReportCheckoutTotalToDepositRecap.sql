CREATE PROCEDURE [dbo].[uspSTReportCheckoutTotalToDepositRecap]
       @xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
   DECLARE @ErrMsg NVARCHAR(MAX)

	DECLARE @strCompanyName			NVARCHAR(500),
			@strAddress				NVARCHAR(500),
			@strCounty				NVARCHAR(500),
			@strCity				NVARCHAR(500),
			@strState				NVARCHAR(500),
			@strZip					NVARCHAR(500),
			@strCountry				NVARCHAR(500),
			@intCheckoutId          INT,
			@xmlDocumentId			INT,
			@strContractDocuments	NVARCHAR(MAX),
			@Store                  INT,
			@CheckoutDate           NVARCHAR(50),
			@ShitNo                 INT 
			
	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  
  
  
	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  
    
	SELECT	@intCheckoutId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intCheckoutId' 

   SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(strCounty)) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = '' THEN NULL ELSE LTRIM(RTRIM(strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(strCountry)) END
    FROM	tblSMCompanySetup

   select @Store = B.intStoreNo , @CheckoutDate = (CONVERT(VARCHAR(50),A.dtmCheckoutDate,101)), @ShitNo = A.intShiftNo 
   from tblSTCheckoutHeader A JOIN tblSTStore B ON A.intStoreId = B.intStoreId 
   where A.intCheckoutId = @intCheckoutId

   select @strCompanyName as CompanyName, @Store as Store, @CheckoutDate as checkoutDate, @ShitNo as ShiftNo,
   ISNULL (SUM(A.dblTotalSalesAmount) OVER (), 0) as CategoryTotalSale,
   ISNULL(C.dblTotalTax, 0) as TotalTax, ISNULL(D.dblAmount,0)  as TotalPayment,
   ISNULL(E.dblAmount,0)  as TotalCustomerCharges, ISNULL(F.dblAmount,0)  as TotalCustomerPayments,
   (ISNULL(SUM (A.dblTotalSalesAmount) over(),0) + ISNULL(C.dblTotalTax,0) - ISNULL(D.dblAmount,0)  -
   ISNULL(E.dblAmount,0) + ISNULL(F.dblAmount,0))  as TotalToDeposit
   from tblSTCheckoutDepartmetTotals A  LEFT OUTER JOIN tblICCategory B ON A.intCategoryId = B.intCategoryId 
   LEFT OUTER JOIN (select intCheckoutId , SUM(dblTotalTax) as dblTotalTax from tblSTCheckoutSalesTaxTotals 
   group by intCheckoutId) C ON A.intCheckoutId = C.intCheckoutId 
   LEFT OUTER JOIN (select intCheckoutId , SUM(dblAmount) as dblAmount from tblSTCheckoutPaymentOptions 
   group by intCheckoutId) D  ON A.intCheckoutId = D.intCheckoutId 
   LEFT OUTER JOIN (select intCheckoutId , SUM(dblAmount) as dblAmount from tblSTCheckoutCustomerCharges 
   group by intCheckoutId) E  ON A.intCheckoutId = E.intCheckoutId 
   LEFT OUTER JOIN (select intCheckoutId , SUM(dblAmount) as dblAmount from tblSTCheckoutCustomerPayments 
   group by intCheckoutId) F  ON A.intCheckoutId = F.intCheckoutId 
   where A.intCheckoutId = @intCheckoutId 
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH