GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPCreateMissingPaymentOfBills')
	DROP PROCEDURE uspAPCreateMissingPaymentOfBills
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
		EXEC ('
		CREATE PROCEDURE [dbo].[uspAPCreateMissingPaymentOfBills]
		AS
		BEGIN

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON
		SET XACT_ABORT ON
		SET ANSI_WARNINGS OFF

		IF OBJECT_ID(''tempdb..##TempBillsError'') IS NOT NULL DROP TABLE ##TempBillsError
		--Find Bills without Payment where ysnPaid = 1 and ysnOrigin =1
		SELECT * INTO ##TempBillsError FROM tblAPBill 
		WHERE ysnPaid = 1
			AND ysnOrigin = 1
			AND intBillId not in (SELECT intBillId FROM tblAPPaymentDetail WHERE ysnOrigin = 1 )


		IF OBJECT_ID(''tempdb..##OriginChecks'') IS NOT NULL DROP TABLE ##OriginChecks

		--Join Origin Tables with the Bills
		SELECT D.intBillId, D.strBillId, D.strVendorOrderNumber, A.apivc_ivc_no, E.intBankAccountId, E.intGLAccountId, A.apivc_trans_type, D.intTransactionType, D.dtmDate, D.dtmDueDate, A.apivc_due_rev_dt, A.apivc_chk_rev_dt 
		INTO ##OriginChecks
		FROM apivcmst A
			LEFT JOIN apcbkmst B
			ON A.apivc_cbk_no = B.apcbk_no
	
			INNER JOIN tblAPVendor C
			ON A.apivc_vnd_no = C.strVendorId COLLATE Latin1_General_CS_AS
		
			INNER JOIN ##TempBillsError D
			on D.intEntityVendorId = C.intEntityVendorId
	
			INNER JOIN tblCMBankAccount E
			on E.strBankAccountNo = B.apcbk_bank_acct_no COLLATE Latin1_General_CS_AS

		WHERE A.apivc_status_ind = ''P''
		AND D.strVendorOrderNumber  = A.apivc_ivc_no  COLLATE Latin1_General_CS_AS



		IF OBJECT_ID(''tempdb..##TempAPCreatedPaymentFROMBills'') IS NOT NULL DROP TABLE ##TempAPCreatedPaymentFROMBills
		--Create temp table that will be used for inserting payment.

		SELECT 
		intAccountId = B.intGLAccountId
		,intBankAccountId = B.intBankAccountId
		,intPaymentMethodId = 3
		,intCurrencyId =3
		,strPaymentInfo = ''not found''
		,strNotes  = A.strBillId
		,dtmDatePaid = ((substring(convert(varchar(10),B.apivc_chk_rev_dt),5,2)  
						+''/''+substring(convert(varchar(10),B.apivc_chk_rev_dt),7,2)
						+''/''+substring(convert(varchar(10),B.apivc_chk_rev_dt),1,4))) 
		,dblAmountPaid = A.dblTotal
		,dblUnapplied = 0
		,ysnPosted = 1
		,strPaymentRecordNum = ''not found''
		,dblWithheld = 0
		,intUserId =  A.intEntityId
		,intEntityId = A.intEntityId
		,intEntityVendorId = A.intEntityVendorId
		,ysnOrigin =1
		,ysnVoid =0
		,ysnPrinted = 0
		,ysnDeleted = 1
		,dtmDateDeleted = NULL
		,dtmDateCreated  = GETDATE()
		,A.intBillId
		,A.strBillId 
		INTO ##TempAPCreatedPaymentFROMBills
		FROM tblAPBill A
			INNER JOIN ##OriginChecks B
			on A.intBillId = B.intBillId
			WHERE  B.intBillId in (SELECT intBillId FROM ##TempBillsError)

		--Insert Payment Header
		INSERT INTO tblAPPayment
			(
			intAccountId
			,intBankAccountId
			,intPaymentMethodId
			,intCurrencyId
			,strPaymentInfo
			,strNotes
			,dtmDatePaid
			,dblAmountPaid
			,dblUnapplied
			,ysnPosted
			,strPaymentRecordNum
			,dblWithheld
			,intUserId
			,intEntityId
			,intEntityVendorId
			,ysnOrigin
			,ysnVoid
			,ysnPrinted
			,ysnDeleted
			,dtmDateDeleted
			,dtmDateCreated
			)

		SELECT
			intAccountId
			,intBankAccountId
			,intPaymentMethodId
			,intCurrencyId
			,strPaymentInfo
			,strNotes
			,dtmDatePaid
			,dblAmountPaid
			,dblUnapplied
			,ysnPosted
			,strPaymentRecordNum
			,dblWithheld
			,intUserId
			,intEntityId
			,intEntityVendorId
			,ysnOrigin
			,ysnVoid
			,ysnPrinted
			,ysnDeleted
			,dtmDateDeleted
			,dtmDateCreated
		FROM ##TempAPCreatedPaymentFROMBills 


		IF OBJECT_ID(''tempdb..##Tempi21APPaymentFROMBillOrigin'') IS NOT NULL DROP TABLE ##Tempi21APPaymentFROMBillOrigin
		--Find Payment Header without Payment detail.
		SELECT * INTO  ##Tempi21APPaymentFROMBillOrigin 
		FROM tblAPPayment WHERE intPaymentId  in 
			(SELECT intPaymentId FROM  tblAPPayment 
			WHERE intPaymentId not in (SELECT intPaymentId FROM tblAPPaymentDetail) AND strPaymentInfo = ''not found'')

		--Update Record no.
		UPDATE A set strPaymentRecordNum  =  ''PAY-'' + convert (NVARCHAR,B.intPaymentId)
		FROM tblAPPayment A
		INNER JOIN ##Tempi21APPaymentFROMBillOrigin B
		on A.intPaymentId  = B.intPaymentId 

		--Update the Starting Number + 1 to the last prefix id inserted.
		UPDATE tblSMStartingNumber 
		SET intNumber = (select top 1 intPaymentId from ##Tempi21APPaymentFROMBillOrigin order by intPaymentId DESC) + 1
		where strPrefix =''PAY-''



		--Insert PaymentDetail
		INSERT INTO tblAPPaymentDetail 
		(
		intPaymentId
		,intBillId
		,intAccountId
		,dblDiscount
		,dblAmountDue
		,dblPayment
		,dblInterest
		,dblTotal
		,dblWithheld

		)
		OUTPUT inserted.intPaymentId

		SELECT 
		A.intPaymentId 
		,C.intBillId
		,D.intBankAccountId
		,0
		,0
		,A.dblAmountPaid
		,0
		,A.dblAmountPaid
		,0
		 FROM  ##Tempi21APPaymentFROMBillOrigin A
		 INNER JOIN tblAPBill C
		 on C.strBillId = A.strNotes
 
		 INNER JOIN ##OriginChecks D
		 ON D.apivc_ivc_no = C.strVendorOrderNumber   COLLATE Latin1_General_CS_AS

		END
	')
END