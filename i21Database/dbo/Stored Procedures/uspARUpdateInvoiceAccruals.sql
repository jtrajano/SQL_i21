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

/* UPDATE Unequal Accrual Amount */
IF(@ysnBalanceTotal = 0)
BEGIN
	UPDATE A
	SET A.dblAmount = I.dblInvoiceSubtotal / @intAccrualEntriesCNT
	FROM tblARInvoiceAccrual A
	INNER JOIN tblARInvoice I
		ON A.intInvoiceId = I.intInvoiceId
	WHERE A.intInvoiceId = @intInvoiceId
END

/* UPDATE missing Accrual Item entries */
IF((SELECT COUNT(DISTINCT IC.intItemId) FROM tblARInvoiceAccrual A
	INNER JOIN tblARInvoiceDetail ID
		ON A.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblICItem IC
		ON ID.intItemId = IC.intItemId
	WHERE A.intInvoiceId = @intInvoiceId) != (SELECT COUNT(DISTINCT IC.intItemId) FROM tblARInvoiceDetail AD
	INNER JOIN tblICItem IC
		ON AD.intItemId = IC.intItemId
	WHERE intInvoiceId = @intInvoiceId))
BEGIN	
	DELETE FROM tblARInvoiceAccrual WHERE intInvoiceId = @intInvoiceId
	
	INSERT INTO tblARInvoiceAccrual(intInvoiceId,intInvoiceDetailId,dtmAccrualDate,dblAmount,intConcurrencyId)
	SELECT I.intInvoiceId,intInvoiceDetailId, dtmAccrualMonth, (dblInvoiceSubtotal/@intAccrualEntriesCNT), 1 dblAmount
	FROM tblARInvoiceDetail ID
		INNER JOIN tblARInvoice I
			ON I.intInvoiceId = ID.intInvoiceId
	CROSS APPLY(SELECT TOP (@intPeriodsToAccrue) DATEADD(m, ROW_NUMBER() OVER(ORDER BY Id),DATEADD(MONTH, -1, dtmPostDate)) dtmAccrualMonth	FROM sysobjects
				OUTER APPLY tblARInvoice
				WHERE intInvoiceId = @intInvoiceId) AccrualDate
	WHERE I.intInvoiceId = @intInvoiceId
	ORDER BY dtmAccrualMonth
END
