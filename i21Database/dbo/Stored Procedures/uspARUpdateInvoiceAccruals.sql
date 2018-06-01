CREATE PROCEDURE [dbo].[uspARUpdateInvoiceAccruals] 
	 @intInvoiceId	INT 
AS  

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF
 
DECLARE @ysnBalanceTotal BIT = 0
DECLARE @intPeriodsToAccrue AS INT
DECLARE @intAccrualEntriesCNT as INT
SELECT @intPeriodsToAccrue = intPeriodsToAccrue, @intAccrualEntriesCNT = (intPeriodsToAccrue * (COUNT(DISTINCT D.intItemId))) FROM tblARInvoice I
INNER JOIN tblARInvoiceDetail D
	ON D.intInvoiceId = I.intInvoiceId
WHERE I.intInvoiceId = @intInvoiceId
GROUP BY intPeriodsToAccrue
IF ((SELECT intPeriodsToAccrue FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId) <= 1)
BEGIN
	RETURN;
END

SELECT @ysnBalanceTotal = CASE WHEN SUM(A.dblAmount) =  I.dblInvoiceSubtotal THEN 1 ELSE 0 END FROM tblARInvoiceAccrual A
INNER JOIN tblARInvoice I
	ON I.intInvoiceId = A.intInvoiceId
WHERE I.intInvoiceId = @intInvoiceId
GROUP BY dblInvoiceSubtotal
IF (@ysnBalanceTotal != 1)
BEGIN
	DELETE FROM tblARInvoiceAccrual WHERE intInvoiceId = @intInvoiceId
	
	INSERT INTO tblARInvoiceAccrual(intInvoiceId,intInvoiceDetailId,dtmAccrualDate,dblAmount,intConcurrencyId)
	SELECT I.intInvoiceId,intInvoiceDetailId, dtmAccrualMonth, ROUND(ID.dblPrice/@intPeriodsToAccrue,2,1) , 1 
	FROM tblARInvoiceDetail ID
		INNER JOIN tblARInvoice I
			ON I.intInvoiceId = ID.intInvoiceId
	CROSS APPLY(SELECT TOP (@intPeriodsToAccrue) DATEADD(m, ROW_NUMBER() OVER(ORDER BY Id),DATEADD(MONTH, -1, dtmPostDate)) dtmAccrualMonth	FROM sysobjects
				OUTER APPLY tblARInvoice
				WHERE intInvoiceId = @intInvoiceId) AccrualDate
	WHERE I.intInvoiceId = @intInvoiceId
	ORDER BY dtmAccrualMonth

	IF (@ysnBalanceTotal != 1)
	BEGIN
		DECLARE @difference AS DECIMAL(16,1)
		SELECT @difference = SUM(A.dblAmount) -  I.dblInvoiceSubtotal FROM tblARInvoiceAccrual A
		INNER JOIN tblARInvoice I
			ON I.intInvoiceId = A.intInvoiceId
		WHERE I.intInvoiceId = @intInvoiceId
		GROUP BY dblInvoiceSubtotal;

		WITH Invoice_AccrualList AS (
			SELECT TOP 1 * FROM tblARInvoiceAccrual WHERE intInvoiceId = @intInvoiceId ORDER BY dtmAccrualDate DESC
		)
		UPDATE Invoice_AccrualList
			SET dblAmount  = dblAmount - (@difference) 
	END

END
