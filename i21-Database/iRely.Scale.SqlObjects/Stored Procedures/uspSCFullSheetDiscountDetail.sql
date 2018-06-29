CREATE PROCEDURE [dbo].[uspSCFullSheetDiscountDetail]
	@xmlParam NVARCHAR(MAX) = NULL 
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strDiscountID NVARCHAR(10)
	DECLARE @intTicketId	        INT,
			@xmlDocumentId			INT,
			@ysnCustomerCopy        BIT = 0 
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
	SELECT	@intTicketId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intTicketId'

	SELECT @strDiscountID = DISC.strDiscountId FROM tblSCTicket TIC
	LEFT JOIN tblGRDiscountId DISC ON  TIC.intDiscountId = DISC.intDiscountId
	WHERE TIC.intTicketId = @intTicketId

	SELECT TD.intTicketId as intTicketId, @strDiscountID as DiscountId, Item.strItemNo as DisountDescription, TD.dblGradeReading, TD.dblDiscountAmount, TD.dblShrinkPercent FROM tblSCTicketDiscount TD 
	LEFT JOIN tblGRDiscountScheduleCode SC ON SC.intDiscountScheduleCodeId = TD.intDiscountScheduleCodeId
	JOIN tblICItem Item ON Item.intItemId=SC.intItemId
	WHERE TD.intTicketId = @intTicketId