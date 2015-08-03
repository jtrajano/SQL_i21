CREATE PROCEDURE [dbo].[uspSTReportPromotionItemListDetail]

	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @intPromoItemListId	    INT,
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
    
	SELECT	@intPromoItemListId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intPromoItemListId' 

	SELECT	adj2.strUpcCode,adj1.strUpcDescription,adj1.dblRetailPrice
	FROM	tblSTPromotionItemListDetail adj1 JOIN tblICItemUOM adj2 
	ON adj1.intItemUOMId = adj2.intItemUOMId
	WHERE	adj1.intPromoItemListId	=	@intPromoItemListId
	
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspSTReportPromotionItemListDetail - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH