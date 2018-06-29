CREATE PROCEDURE [dbo].[uspSTReportPromotionSalesListDetail]

	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @intPromoSalesListId    INT,
			@xmlDocumentId			INT 
			
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
    
	SELECT	@intPromoSalesListId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intPromoSalesListId' 

	SELECT	adj2.intPromoItemListNo,adj2.strPromoItemListId,adj1.intQuantity,adj1.dblPrice
	FROM	tblSTPromotionSalesListDetail adj1 JOIN tblSTPromotionItemList adj2 
	ON adj1.intPromoItemListId = adj2.intPromoItemListId
	WHERE	adj1.intPromoSalesListId = @intPromoSalesListId
	
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspSTReportMixORMatchSalesListDetail - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH