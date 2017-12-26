CREATE PROCEDURE [dbo].[uspSTGenerateShelfTags]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	--START Handle xml Param
	DECLARE @strXmlString 	   NVARCHAR(MAX)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	--Declare xmlParam holder
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			[condition]		NVARCHAR(20),        
			[from]			NVARCHAR(MAX), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  

	DECLARE @xmlDocumentId INT

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT ,@xmlParam

	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
			[fieldname]		NVARCHAR(50),  
			[condition]		NVARCHAR(20),        
			[from]			NVARCHAR(MAX), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  

	--strItemAndLocation
	SELECT @strXmlString = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strXmlString'



	-- Create table to handle column and values
	DECLARE @tblTempColumnAndValue TABLE 
	(  
			[strDescription]	NVARCHAR(150),  
			[strLongUPCCode]	NVARCHAR(50),
			[dblStandardCost]	NVARCHAR(20)
	)  

	INSERT INTO @tblTempColumnAndValue
	SELECT 
		dbo.fnSTSeparateStringToColumns(Item, 1, '|') strDescription,
		dbo.fnSTSeparateStringToColumns(Item, 2, '|') strLongUPCCode,
		dbo.fnSTSeparateStringToColumns(Item, 3, '|') dblStandardCost
	FROM dbo.fnSplitString(@strXmlString, ',')


    SELECT * FROM @tblTempColumnAndValue

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
END CATCH