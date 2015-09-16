CREATE PROCEDURE [dbo].[uspSCFullSheetDistributionDetail]
	@xmlParam NVARCHAR(MAX) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strDistributionOption NVARCHAR(3)
DECLARE @spotPrice DECIMAL (13, 3) 
DECLARE @intCommdityId INT
DECLARE @Distributions TABLE 
(  
		Id		     INT IDENTITY,  
		percentage	 NVARCHAR(7),        
		name		 NVARCHAR(30), 
		distribution NVARCHAR(12),  
		detail		 NVARCHAR(21),
		intTicketId  INT 
) 

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intTicketId	        INT,
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
	SELECT	@intTicketId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intTicketId'

SELECT @strDistributionOption = strDistributionOption, @spotPrice = dblUnitPrice + dblUnitBasis, 
@intCommdityId = intCommodityId FROM tblSCTicket WHERE intTicketId = @intTicketId

IF(@strDistributionOption = 'SPL')
BEGIN
INSERT INTO @Distributions ([percentage], [name], [distribution], [detail], [intTicketId])
SELECT DISTINCT CAST (TS.dblSplitPercent AS nvarchar) + '%', ET.strName, 
CASE	WHEN	TS.strDistributionOption  =	'CNT'	
		THEN	'CONTRACT'
		WHEN	TS.strDistributionOption  =	'SPT'
		THEN	'SPOT SALE'
		WHEN	TS.strDistributionOption  !='SPT' AND TS.strDistributionOption  !='CNT'
		THEN	ST.strStorageTypeDescription
END		AS	strConfirm,
CASE	WHEN	TS.strDistributionOption  ='SPT'
		THEN	'Price/' + ICU.strSymbol + ': ' + CAST (@spotPrice AS nvarchar)
END		AS	strDetail,
@intTicketId
 FROM tblSCTicketSplit TS
LEFT JOIN tblEntity ET on ET.intEntityId = TS.intCustomerId
LEFT JOIN tblGRStorageType ST on ST.strStorageTypeCode = TS.strDistributionOption
LEFT JOIN tblICCommodityUnitMeasure TCU on TCU.intCommodityId = @intCommdityId AND TCU.ysnStockUnit = 1
LEFT JOIN tblICUnitMeasure ICU on ICU.intUnitMeasureId = TCU.intUnitMeasureId
WHERE TS.intTicketId = @intTicketId
END
ELSE
BEGIN
INSERT INTO @Distributions ([percentage], [name], [distribution], [detail], [intTicketId])
SELECT DISTINCT '100%', ET.strName, 
CASE	WHEN	TIC.strDistributionOption  =	'CNT'	
		THEN	'CONTRACT'
		WHEN	TIC.strDistributionOption  =	'SPT'
		THEN	'SPOT SALE'
		WHEN	TIC.strDistributionOption  !='SPT' AND TIC.strDistributionOption  !='CNT'
		THEN	ST.strStorageTypeDescription
END		AS	strConfirm,
CASE	WHEN	TIC.strDistributionOption  ='SPT'
		THEN	'Price/' + ICU.strSymbol + ': ' + CAST (@spotPrice AS nvarchar)
END		AS	strDetail,
@intTicketId
FROM tblSCTicket TIC
LEFT JOIN tblEntity ET on ET.intEntityId = TIC.intEntityId
LEFT JOIN tblGRStorageType ST on ST.strStorageTypeCode = TIC.strDistributionOption
LEFT JOIN tblICCommodityUnitMeasure TCU on TCU.intCommodityId = TIC.intCommodityId AND TCU.ysnStockUnit = 1
LEFT JOIN tblICUnitMeasure ICU on ICU.intUnitMeasureId = TCU.intUnitMeasureId 
WHERE TIC.intTicketId = @intTicketId
END

SELECT * FROM @Distributions
