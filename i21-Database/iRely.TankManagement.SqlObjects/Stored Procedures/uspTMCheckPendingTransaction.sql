CREATE PROCEDURE uspTMCheckPendingTransaction 
	@strDate NVARCHAR(10)
	,@hasPending BIT = 0 OUTPUT 
AS
BEGIN
	IF((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblTMCOBOLWRITE WHERE CONVERT(INT, InvoiceDate) <= CONVERT(INT,@strDate))
		BEGIN
			SET @hasPending = 1
		END
		ELSE
		BEGIN
			SET @hasPending = 0
		END
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT TOP 1 1 
				  FROM tblARInvoiceDetail A
				  INNER JOIN tblARInvoice B 
					ON A.intInvoiceId = B.intInvoiceId
				  WHERE A.intSiteId IS NOT NULL 
					AND B.ysnPosted <> 1
					AND B.dtmDate <= CONVERT(DATETIME,@strDate))
		BEGIN
			SET @hasPending = 1
		END 
		ELSE
		BEGIN
			SET @hasPending = 0
		END
	END
END
GO