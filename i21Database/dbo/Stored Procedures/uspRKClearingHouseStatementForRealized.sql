﻿CREATE PROC uspRKClearingHouseStatementForRealized	
			@strName nvarchar(100) = null,
			@strAccountNumber nvarchar(100) = null,
		    @dtmTransactionFromDate datetime = null,
		    @dtmTransactionToDate datetime = null
AS

--Sanitize the parameters, set to null if empty string. We are catching it on where clause by isnull function
IF @strName = ''
BEGIN
	SET @strName = NULL
END

IF @strAccountNumber = ''
BEGIN
	SET @strAccountNumber = NULL
END



SELECT strFutMarketName,Left(replace(convert(varchar(9), dtmLTransDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmLTransDate, 8),9) dtmLTransDate,
	   Left(replace(convert(varchar(9), dtmSTransDate, 6), ' ', '-') + ' ' + convert(varchar(8), dtmSTransDate, 8),9) dtmSTransDate,
	   strFutureMonth,convert(int,dblMatchQty) dblMatchQty,dblLPrice,dblSPrice,-dblGrossPL dblGrossPL,dblFutCommission,
	   isnull(dblLPrice,0)-isnull(dblSPrice,0) dblPriceDiff,isnull(dblGrossPL,0)-isnull(abs(dblFutCommission),0) dblTotal	  
FROM vyuRKRealizedPnL 
WHERE  strName=isnull(@strName,strName) 
AND strAccountNumber = isnull(@strAccountNumber,strAccountNumber)
AND CONVERT(VARCHAR(10), dtmMatchDate, 110) between CONVERT(VARCHAR(10), @dtmTransactionFromDate, 110) and CONVERT(VARCHAR(10), @dtmTransactionToDate, 110) 
ORDER BY dtmLTransDate
