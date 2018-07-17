GO
	UPDATE t SET dtmDiscountDate = CAST(t.dtmDiscountDate AS DATE), dtmDueDate = CAST(t.dtmDueDate AS DATE)
	FROM tblSMTerm t 
	WHERE t.strType = 'Specific Date'
GO