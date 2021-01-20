﻿CREATE VIEW [dbo].[vyuAPRptCheckRegister]
	AS 
		SELECT  
			APP.strPaymentRecordNum,
			CMBT.ysnCheckVoid,
			CMBT.ysnClr,
			'AP' AS strSystem,
			CMBA.intBankId,
			CMBTT.strBankTransactionTypeName,
			dtmDateReconciled AS dtmClearedDate,
			ISNULL((SELECT SUM(dblDiscount) 
					FROM tblAPPaymentDetail 
					WHERE intPaymentId = APP.intPaymentId),0) as dblDiscount,
			ISNULL(APP.dblWithheld,0) AS dblWithheldAmount,
			ISNULL(CMBT.dblAmount,0) AS dblAmount,
			CMBA.strCbkNo,
			--CMBT.strMemo, --Remove Field notes from CM
			APP.strNotes,
			CMBT.dtmDate,
			CMBT.strReferenceNo AS chkNo,
			CMBT.strPayee,
			(SELECT strBankName FROM tblCMBank WHERE intBankId = CMBA.intBankId) as strBankName
		FROM 
			dbo.tblCMBankTransaction CMBT 
		INNER JOIN tblCMBankTransactionType CMBTT
			ON CMBT.intBankTransactionTypeId =  CMBTT.intBankTransactionTypeId
		INNER JOIN tblCMBankAccount CMBA
			ON CMBA.intBankAccountId =  CMBT.intBankAccountId
		INNER JOIN tblAPPayment APP
			ON CMBT.strTransactionId = APP.strPaymentRecordNum
		WHERE 
			CMBTT.strBankTransactionTypeName IN ('AP Payment','AP eCheck','Void Check','Void ACH','ACH','Void AP Payment')