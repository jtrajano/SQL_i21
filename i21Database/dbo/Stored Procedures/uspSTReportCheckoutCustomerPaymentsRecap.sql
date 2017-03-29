﻿CREATE PROCEDURE [dbo].[uspSTReportCheckoutCustomerPaymentsRecap]
		@intCheckoutId INT 
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	
	
    select B.strCustomerNumber, A.strName, A.intInvoice,A.dblAmount ,A.strComment ,A.strType, A.strCheckNo,
	SUM(case when A.strType = 'P' then A.dblAmount  else 0 end) over() as TotalCash, SUM(case when A.strType <> 'P' then A.dblAmount else 0 end) over() as TotalOther
	from tblSTCheckoutCustomerPayments A JOIN tblARCustomer B ON B.[intEntityId] = A.intCustomerId  
	where A.intCheckoutId = @intCheckoutId
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH