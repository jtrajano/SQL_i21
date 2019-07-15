CREATE VIEW [dbo].[vyuTRLoadBatchPostList]
	AS 
SELECT DISTINCT 
	'Transport Load' COLLATE Latin1_General_CI_AS AS strTransactionType,
	LH.intLoadHeaderId AS intTransactionId,
	LH.strTransaction AS strTransactionId,
	0 AS dblAmount,
	'' COLLATE Latin1_General_CI_AS AS strVendorInvoiceNumber, 
	LH.intSellerId AS intEntityVendorId, 
	CASE WHEN LH.intUserId IS NULL THEN (SELECT TOP 1 intEntityId FROM tblSMUserSecurity) ELSE LH.intUserId END AS intEntityId,
	LH.dtmLoadDateTime AS dtmDate,
	''  COLLATE Latin1_General_CI_AS AS strDescription, 
	NULL AS intCompanyLocationId,
	LH.ysnPosted
FROM tblTRLoadHeader LH
INNER JOIN tblTRLoadReceipt LR ON LR.intLoadHeaderId = LH.intLoadHeaderId
INNER JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = LH.intLoadHeaderId
INNER JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
