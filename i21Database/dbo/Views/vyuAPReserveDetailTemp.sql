CREATE VIEW [dbo].[vyuAPReserveDetailTemp]
AS
SELECT
	 APPP.intBillId
	,APPP.strVendorIdName
	,dblCreditLimit			= 0.00
	,APPP.strBillId
	,strGLLocation			= ISNULL(GLLA.strDescription, '')
	,strGLLineOfBusiness	= ISNULL(GLLOB.strDescription, '')
	,dbl30Days				= APPP.dblAmountDue
	,dbl60Days				= 0.00
	,dbl90Days				= 0.00
	,dbl120Days				= 0.00
FROM vyuAPPrepaidPayables APPP
LEFT JOIN vyuGLLocationAccountId GLLA ON APPP.intAccountId = GLLA.intAccountId
LEFT JOIN (
	SELECT TOP 1 GLASM.intAccountId, GLAS.strDescription
	FROM tblGLAccountSegmentMapping GLASM
	INNER JOIN tblGLAccountSegment GLAS ON GLAS.intAccountSegmentId = GLASM.intAccountSegmentId
	INNER JOIN  tblGLAccountStructure GLASt ON GLASt.intAccountStructureId = GLAS.intAccountStructureId
	WHERE GLASt.intStructureType = 5

) GLLOB ON APPP.intAccountId = GLLOB.intAccountId
WHERE ysnPaid = 0
AND intPrepaidRowType = 1