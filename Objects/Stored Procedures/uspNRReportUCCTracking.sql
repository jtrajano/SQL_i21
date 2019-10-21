CREATE PROCEDURE [dbo].[uspNRReportUCCTracking]
AS
BEGIN

	SELECT N.strNoteNumber AS [Note #], N.strUCCFileRefNo AS [UCC File #]
	, N.dtmUCCFiledOn AS [Date Filed], N.dtmUCCLastRenewalOn AS [Last Renewal]
	, N.dtmUCCReleasedOn AS [Date Released], N.strUCCComment AS [Comment]
	FROM dbo.tblNRNote N
	WHERE N.strUCCFileRefNo != ''

END
