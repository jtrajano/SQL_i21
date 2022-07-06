CREATE PROCEDURE [dbo].[uspQMUpdateSampleOnEmail]
	  @strSampleIds		NVARCHAR(MAX)	= NULL
	, @dtmDate			DATETIME		= NULL
AS 

IF ISNULL(@strSampleIds, '') = ''
	RETURN

UPDATE S
SET dtmRequestedDate	= ISNULL(@dtmDate, GETDATE())
FROM tblQMSample S
INNER JOIN dbo.fnGetRowsFromDelimitedValues(@strSampleIds) SS ON S.intSampleId = SS.intID